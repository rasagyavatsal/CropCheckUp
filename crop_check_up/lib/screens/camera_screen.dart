import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


import '../services/camera_service.dart';
import '../services/plant_classifier.dart';
import '../theme/app_theme.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/diagnosis_sheet.dart';

/// Live camera viewfinder for plant disease diagnosis.
///
/// The screen shows the camera feed with a targeting overlay. When the user
/// clicks the capture button, it grabs the latest decoded frame, runs the 
/// classifier, and presents the [DiagnosisSheet] with the result.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final _cameraService = CameraService();
  final _classifier = PlantClassifier();

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
      final result = _classifier.classifyImage(frame);
      if (result != null && mounted) {
        DiagnosisSheet.show(context, result);
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
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.healthyGreen),
              SizedBox(height: 16),
              Text(
                'Loading AI model…',
                style: TextStyle(color: Colors.white70, fontSize: 16),
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
                  style: const TextStyle(color: Colors.white60),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: const [
                          Shadow(blurRadius: 8, color: Colors.black87),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.healthyGreen,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Analyzing Image...',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Align leaf and tap to capture',
        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
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
        duration: const Duration(milliseconds: 250),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isProcessing ? Colors.white38 : Colors.white,
            width: 4,
          ),
          boxShadow: !isProcessing
              ? [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isProcessing ? Colors.white24 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
