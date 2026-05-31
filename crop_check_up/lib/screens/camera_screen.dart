import 'dart:async';

import 'package:flutter/material.dart';

import '../ui/theme/theme_ext.dart';
import '../ui/tokens/typography.dart';
import '../ui/tokens/size_tokens.dart';
import '../ui/tokens/spacing_tokens.dart';
import '../ui/tokens/radius_tokens.dart';
import '../ui/tokens/motion_tokens.dart';
import '../ui/copy/app_copy.dart';
import '../services/camera_session.dart';
import '../ui/components/camera/app_camera_viewfinder.dart';
import '../ui/flow/diagnosis_flow_coordinator.dart';
import '../ui/app_design_system.dart';
import '../ui/components/layout/layout.dart';
import '../widgets/camera_overlay.dart';

/// Live camera viewfinder for plant disease diagnosis.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _session = CameraSession();
  final _coordinator = DiagnosisFlowCoordinator();

  bool _isInitialising = true;
  String? _initError;
  bool _isDiagnosing = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _session.stop();
    _coordinator.dispose();
    super.dispose();
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
        _coordinator.init(),
        _session.start(),
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

    final frame = _session.captureFrame();
    if (frame == null) {
      if (mounted) {
        AppFeedback.showError(context, AppCopy.camera.captureFailed);
      }
      return;
    }

    setState(() => _isDiagnosing = true);
    await _coordinator.startCameraDiagnosis(context, frame);
    if (mounted) {
      setState(() => _isDiagnosing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isInitialising) {
      return AppPageShell(
        backgroundColor: context.appColors.background,
        child: AppLoadingState(message: AppCopy.home.initLoading),
      );
    }

    if (_initError != null) {
      return AppPageShell(
        backgroundColor: context.appColors.background,
        child: AppErrorState(
          message: _initError ?? AppCopy.home.initErrorTitle,
          onRetry: _bootstrap,
        ),
      );
    }

    const sizes = SizeTokens();
    const spacing = SpacingTokens();
    const radius = RadiusTokens();

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          AppCameraViewfinder(
            session: _session,
            onResume: _bootstrap,
          ),

          // Overlay
          const CameraOverlay(),

          // Top action bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppSafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.m,
                  vertical: spacing.s,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppIconButton.translucent(
                      icon: Icons.close_rounded,
                      tooltip: AppCopy.shared.backAction,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'CropCheckUp',
                      style: context.typography.title.copyWith(
                        color: context.appColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          context.cameraTokens.glow,
                        ],
                      ),
                    ),
                    AppIconButton.translucent(
                      icon: _session.isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      tooltip: _session.isFlashOn
                          ? AppCopy.camera.semanticFlashOff
                          : AppCopy.camera.semanticFlashOn,
                      onPressed: () async {
                        await _session.toggleFlash();
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppSafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shared instruction chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.l,
                      vertical: spacing.s,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.cameraScrim,
                      borderRadius: BorderRadius.circular(radius.pill),
                      border: Border.all(
                        color: context.appColors.subtleBorder,
                      ),
                    ),
                    child: Text(
                      AppCopy.camera.captureReady,
                      style: context.typography.label.copyWith(
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  // Capture control
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.xl),
                    child: Semantics(
                      button: true,
                      label: AppCopy.camera.semanticCaptureAction,
                      child: GestureDetector(
                        onTap: _isDiagnosing ? null : _captureAndDiagnose,
                        child: AnimatedContainer(
                        duration: MotionTokens.durationNormal,
                        width: sizes.cameraCaptureSize,
                        height: sizes.cameraCaptureSize,
                        decoration: context.cameraTokens.captureControlStyling,
                        child: Padding(
                          padding: EdgeInsets.all(spacing.s),
                          child: AnimatedContainer(
                            duration: MotionTokens.durationNormal,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isDiagnosing
                                  ? context.appColors.disabled
                                  : context.appColors.brand,
                            ),
                            child: Center(
                              child: _isDiagnosing
                                  ? SizedBox(
                                      width: sizes.iconMedium,
                                      height: sizes.iconMedium,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: context.appColors.raisedSurface,
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt_rounded,
                                      color: context.appColors.raisedSurface,
                                      size: sizes.iconLarge,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isDiagnosing)
            AppProcessingOverlay(message: AppCopy.home.loadingOverlayTitle),
        ],
      ),
    );
  }
}
