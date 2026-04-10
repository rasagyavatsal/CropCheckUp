import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/diagnosis_result.dart';
import '../services/camera_service.dart';
import '../services/plant_classifier.dart';
import '../theme/app_theme.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/diagnosis_sheet.dart';

/// Live camera viewfinder that runs continuous plant‑disease inference.
///
/// The screen shows the camera feed with a targeting overlay.  Every
/// [_inferenceInterval] it grabs the latest decoded frame, runs the classifier,
/// and — when a confident result is ready — presents the [DiagnosisSheet].
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
  Timer? _inferenceTimer;
  DiagnosisResult? _lastResult;

  static const _inferenceInterval = Duration(milliseconds: 800);

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
    _inferenceTimer?.cancel();
    _cameraService.stop();
    _classifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraService.isRunning) return;
    if (state == AppLifecycleState.inactive) {
      _inferenceTimer?.cancel();
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
      _startInferenceLoop();
    } catch (e) {
      _initError = e.toString();
    } finally {
      if (mounted) setState(() => _isInitialising = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Inference loop
  // ---------------------------------------------------------------------------

  void _startInferenceLoop() {
    _inferenceTimer?.cancel();
    _inferenceTimer = Timer.periodic(_inferenceInterval, (_) => _runOnce());
  }

  Future<void> _runOnce() async {
    if (_isDiagnosing) return;
    final frame = _cameraService.captureFrame();
    if (frame == null) return;

    _isDiagnosing = true;
    try {
      final result = _classifier.classifyImage(frame);
      if (mounted) {
        setState(() => _lastResult = result);
      }
    } finally {
      _isDiagnosing = false;
    }
  }

  void _showDiagnosis() {
    if (_lastResult == null) return;
    _inferenceTimer?.cancel();
    DiagnosisSheet.show(context, _lastResult!);
    // Resume inference after a short delay.
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _startInferenceLoop();
    });
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
            child: Center(child: _buildStatusChip()),
          ),

          // Capture / diagnose button
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: _CaptureButton(
                hasResult: _lastResult != null,
                onTap: _showDiagnosis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    if (_lastResult == null) {
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
                color: AppTheme.warningAmber,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Scanning…  Move closer or improve lighting',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final color =
        _lastResult!.isHealthy ? AppTheme.healthyGreen : AppTheme.dangerRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12),
        ],
      ),
      child: Text(
        '${_lastResult!.displayLabel}  •  ${_lastResult!.confidencePercent}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
  final bool hasResult;
  final VoidCallback onTap;

  const _CaptureButton({required this.hasResult, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasResult ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasResult ? AppTheme.healthyGreen : Colors.white38,
            width: 4,
          ),
          boxShadow: hasResult
              ? [
                  BoxShadow(
                    color: AppTheme.healthyGreen.withValues(alpha: 0.5),
                    blurRadius: 16,
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
              color: hasResult ? AppTheme.healthyGreen : Colors.white24,
            ),
            child: Icon(
              hasResult ? Icons.search_rounded : Icons.camera_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
