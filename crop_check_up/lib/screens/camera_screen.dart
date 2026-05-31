import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/background_removal_service.dart';
import '../ui/tokens/typography.dart';
import '../services/camera_service.dart';
import '../services/plant_classifier.dart';
import '../theme/app_theme.dart';
import '../ui/tokens/app_tokens.dart';
import '../ui/tokens/motion_tokens.dart';
import '../widgets/camera_overlay.dart';
import 'diagnosis_result_screen.dart';
import 'segmentation_preview_screen.dart';

/// Live camera viewfinder for plant disease diagnosis.
///
/// The screen shows the camera feed with a targeting overlay. When the user
/// clicks the capture button, it grabs the latest decoded frame, runs the 
/// classifier, and presents the [DiagnosisResultScreen] with the result.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final _cameraService = CameraService();
  final _classifier = PlantClassifier();
  final _bgRemover = BackgroundRemovalService();

  bool _isInitialising = true;
  String? _initError;
  bool _isDiagnosing = false;


  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.stop();
    _classifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraService.isRunning) return;
    if (state == AppLifecycleState.inactive) {
      _cameraService.stop();
    } else if (state == AppLifecycleState.resumed) {
      _bootstrap();
    }
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> _bootstrap() async {
    setState(() {
      _isInitialising = true;
      _initError = null;
    });

    try {
      await Future.wait([
        _classifier.init(),
        _bgRemover.init(),
        _cameraService.start(),
      ]);
    } catch (e) {
      _initError = e.toString();
    } finally {
      if (mounted) setState(() => _isInitialising = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Inference loop
  // ---------------------------------------------------------------------------

  Future<void> _captureAndDiagnose() async {
    if (_isDiagnosing) return;
    
    final frame = _cameraService.captureFrame();
    if (frame == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture frame, please try again.')),
        );
      }
      return;
    }

    setState(() => _isDiagnosing = true);
    try {
      final processedFrame = await _bgRemover.processImageObj(frame);
      if (processedFrame == null) {
          throw Exception("Background removal failed.");
      }

      // Resize to 224x224 before showing preview or model inference
      final (resizedImage, resizedBytes) = await _classifier.resizeForModel(processedFrame.image);

      // Show preview for user confirmation
      if (mounted) {
        final confirmed = await SegmentationPreviewScreen.show(
          context, 
          resizedBytes, // Show resized version
        );
        
        if (confirmed != true) {
          return; // User wanted to retry
        }
      }

      final result = _classifier.classifyImage(resizedImage);
      if (result != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DiagnosisResultScreen(
              result: result,
              imageBytes: resizedBytes,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not confidently diagnose. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDiagnosing = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isInitialising) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.healthyGreen),
              const SizedBox(height: 16),
              Text(
                'Loading AI model…',
                style: context.typography.body.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (_initError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.dangerRed),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialise',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _initError!,
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _bootstrap,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_cameraService.controller != null)
            CameraPreview(_cameraService.controller!),

          // Overlay
          const CameraOverlay(),

          // Top action bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // App title
                Text(
                  'CropCheckUp',
                  style: context.typography.title.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        shadows: const [
                          Shadow(blurRadius: 12, color: Colors.black54),
                        ],
                      ),
                ),
                // Flash toggle
                _CircleButton(
                  icon: _cameraService.isFlashOn
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  onTap: () async {
                    await _cameraService.toggleFlash();
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          ),

          // Live status chip
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: _isDiagnosing 
                  ? _buildProcessingChip() 
                  : _buildReadyChip(),
            ),
          ),

          // Capture / diagnose button
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: _CaptureButton(
                isProcessing: _isDiagnosing,
                onTap: _captureAndDiagnose,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.healthyGreen,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Analyzing Specimen...',
            style: context.typography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        'Align leaf and tap to capture',
        style: context.typography.label.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sub‑widgets
// -----------------------------------------------------------------------------

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onTap;

  const _CaptureButton({required this.isProcessing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: AnimatedContainer(
        duration: MotionTokens.durationNormal,
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isProcessing ? Colors.white24 : Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.healthyGreen.withValues(alpha: isProcessing ? 0 : 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: MotionTokens.durationNormal,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isProcessing 
                  ? null 
                  : context.gradient.cameraOverlay,
              color: isProcessing ? Colors.white24 : null,
            ),
            child: Center(
              child: isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white70,
                      ),
                    )
                  : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
