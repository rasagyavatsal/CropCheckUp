import 'package:flutter/material.dart';
import '../ui/tokens/typography.dart';
import '../ui/flow/diagnosis_flow_coordinator.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/app_components.dart';
import '../ui/components/layout/layout.dart';
import '../ui/adaptive/app_adaptive.dart';
import '../ui/tokens/spacing_tokens.dart';
import '../ui/tokens/radius_tokens.dart';
import '../ui/theme/theme_ext.dart';
import '../ui/theme/app_theme.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _coordinator = DiagnosisFlowCoordinator();
  
  bool _isInitialising = true;
  String? _initError;
  bool _isDiagnosing = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isInitialising = true;
      _initError = null;
    });

    try {
      await _coordinator.init();
    } catch (e) {
      _initError = e.toString();
    } finally {
      if (mounted) setState(() => _isInitialising = false);
    }
  }

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    const radius = RadiusTokens();

    if (_isInitialising) {
      return AppPageShell(
        child: AppLoadingState(message: AppCopy.home.initLoading),
      );
    }

    if (_initError != null) {
      return AppPageShell(
        child: AppErrorState(
          message: '${AppCopy.home.initErrorTitle}\n$_initError',
          onRetry: _bootstrap,
        ),
      );
    }

    final colors = context.appColors;

    return Stack(
      children: [
        AppPageShell(
          applySafeArea: true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.l, vertical: spacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppScreenHeader(
                  title: 'CropCheckUp',
                  titleIcon: Icons.eco_rounded,
                  centerTitle: false,
                  trailing: _buildThemeToggle(context),
                ),
                const Spacer(flex: 1),
                
                // Welcome Text
                Text(
                  'Diagnose Plant Health',
                  style: context.typography.headline.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a leaf image to detect diseases instantly.',
                  style: context.typography.body.copyWith(
                    color: colors.mutedText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 1),

                // Specimen Panel (without outlines)
                SizedBox(
                  height: 320,
                  child: AppCard.panel(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle center leaf halo
                        Positioned(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.brand.withValues(alpha: 0.03),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(spacing.l),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 64,
                                color: colors.brand.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 28),
                              
                              // Camera Scan Button (no outline)
                              Semantics(
                                button: true,
                                label: AppCopy.home.semanticScanAction,
                                child: AppButton.primary(
                                  isFullWidth: true,
                                  icon: Icons.photo_camera_rounded,
                                  label: 'Start Camera Scan',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      AppRoute.standard(builder: (_) => const CameraScreen()),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Gallery Upload Button (no outline)
                              Semantics(
                                button: true,
                                label: AppCopy.home.semanticUploadAction,
                                child: AppButton.secondary(
                                  isFullWidth: true,
                                  icon: Icons.image_rounded,
                                  label: 'Upload from Gallery',
                                  onPressed: () async {
                                    setState(() => _isDiagnosing = true);
                                    await _coordinator.startGalleryDiagnosis(context);
                                    if (mounted) setState(() => _isDiagnosing = false);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 1),

                // Tiny Concise Tips Banner
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(radius.l),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: colors.brand),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tips: Bright lighting • Clear background • Single leaf focus',
                          style: context.typography.caption.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),

                // Subtle copyright/version info
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    'v1.0.0',
                    style: context.typography.caption.copyWith(
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isDiagnosing) AppProcessingOverlay(message: AppCopy.home.loadingOverlayTitle),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, mode, _) {
        final isCurrentlyDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        
        return AppHeaderAction(
          icon: Icon(
            isCurrentlyDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: context.appColors.brand,
          ),
          tooltip: isCurrentlyDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          onPressed: () {
            AppTheme.themeModeNotifier.value =
                isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
          },
        );
      },
    );
  }
}
