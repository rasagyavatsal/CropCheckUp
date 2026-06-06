import 'dart:async';

import 'package:flutter/material.dart';

import '../ui/theme/theme_ext.dart';

import '../ui/tokens/spacing_tokens.dart';
import '../ui/tokens/radius_tokens.dart';
import '../ui/tokens/typography.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/app_components.dart';
import '../services/camera_session.dart';
import '../ui/components/camera/app_camera_viewfinder.dart';
import '../ui/flow/diagnosis_flow_coordinator.dart';
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
      await Future.wait([_coordinator.init(), _session.start()]);
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
        child: AppLoadingState(message: AppCopy.home.initLoading),
      );
    }

    if (_initError != null) {
      return AppPageShell(
        child: AppErrorState(
          message: _initError ?? AppCopy.home.initErrorTitle,
          onRetry: _bootstrap,
        ),
      );
    }

    const spacing = SpacingTokens();
    final colors = context.appColors;

    return Stack(
      children: [
        AppPageShell(
          applySafeArea: false,
          child: AppGridBackground(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.l,
                  spacing.m,
                  spacing.l,
                  spacing.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppScreenHeader(
                      title: 'Scanner',
                      leading: AppHeaderAction(
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: AppCopy.shared.backAction,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      trailing: AppHeaderAction(
                        icon: Icon(
                          _session.isFlashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color:
                              _session.isFlashOn
                                  ? colors.brand
                                  : colors.textPrimary,
                        ),
                        tooltip:
                            _session.isFlashOn
                                ? AppCopy.camera.semanticFlashOff
                                : AppCopy.camera.semanticFlashOn,
                        onPressed: () async {
                          await _session.toggleFlash();
                          if (mounted) setState(() {});
                        },
                      ),
                    ),
                    SizedBox(height: spacing.l),
                    Expanded(
                      child: AppCard.panel(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppCameraViewfinder(
                              session: _session,
                              onResume: _bootstrap,
                            ),
                            const CameraOverlay(),
                            Positioned(
                              left: spacing.m,
                              right: spacing.m,
                              top: spacing.m,
                              child: _ViewfinderLabel(
                                label: AppCopy.camera.captureReady,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.m),
                    _CapturePanel(
                      isDiagnosing: _isDiagnosing,
                      onCapture: _captureAndDiagnose,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isDiagnosing)
          AppProcessingOverlay(message: AppCopy.home.loadingOverlayTitle),
      ],
    );
  }
}

class _ViewfinderLabel extends StatelessWidget {
  final String label;

  const _ViewfinderLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.46),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        borderRadius: BorderRadius.circular(const RadiusTokens().l),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.m,
          vertical: spacing.s,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.center_focus_strong_rounded,
              size: 16,
              color: colors.brand,
            ),
            SizedBox(width: spacing.s),
            Flexible(
              child: Text(
                label,
                style: context.typography.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapturePanel extends StatelessWidget {
  final bool isDiagnosing;
  final VoidCallback onCapture;

  const _CapturePanel({required this.isDiagnosing, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.all(spacing.m),
      decoration: BoxDecoration(
        color: colors.raisedSurface,
        border: Border.all(color: colors.subtleBorder),
        borderRadius: BorderRadius.circular(const RadiusTokens().l),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: AppCopy.camera.semanticCaptureAction,
            child: AppButton.primary(
              isFullWidth: true,
              isLoading: isDiagnosing,
              icon: Icons.camera_rounded,
              label: isDiagnosing ? 'Analyzing...' : 'Capture leaf',
              onPressed: onCapture,
            ),
          ),
        ],
      ),
    );
  }
}
