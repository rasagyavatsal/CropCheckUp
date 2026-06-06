import 'package:flutter/material.dart';
import '../ui/tokens/typography.dart';
import '../ui/flow/diagnosis_flow_coordinator.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/app_components.dart';
import '../ui/components/layout/layout.dart';
import '../ui/adaptive/app_adaptive.dart';
import '../ui/tokens/spacing_tokens.dart';
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

  Future<void> _startGalleryDiagnosis() async {
    setState(() => _isDiagnosing = true);
    await _coordinator.startGalleryDiagnosis(context);
    if (mounted) setState(() => _isDiagnosing = false);
  }

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
          message: '${AppCopy.home.initErrorTitle}\n$_initError',
          onRetry: _bootstrap,
        ),
      );
    }

    const spacing = SpacingTokens();

    return Stack(
      children: [
        AppPageShell(
          applySafeArea: true,
          child: AppGridBackground(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                spacing.l,
                spacing.m,
                spacing.l,
                spacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppScreenHeader(
                    title: 'CropCheckUp',
                    brandMark: const AppBrandMark(),
                    centerTitle: false,
                    trailing: _buildThemeToggle(context),
                  ),
                  SizedBox(height: spacing.xl),
                  const _HomeStatusHeader(),
                  SizedBox(height: spacing.l),
                  _DiagnosisActionPanel(
                    onCameraPressed: () {
                      Navigator.push(
                        context,
                        AppRoute.standard(builder: (_) => const CameraScreen()),
                      );
                    },
                    onGalleryPressed: _startGalleryDiagnosis,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isDiagnosing)
          AppProcessingOverlay(message: AppCopy.home.loadingOverlayTitle),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, mode, _) {
        final isCurrentlyDark =
            mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        return AppHeaderAction(
          icon: Icon(
            isCurrentlyDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: context.appColors.brand,
          ),
          tooltip:
              isCurrentlyDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          onPressed: () {
            AppTheme.themeModeNotifier.value =
                isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
          },
        );
      },
    );
  }
}

class _HomeStatusHeader extends StatelessWidget {
  const _HomeStatusHeader();

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppCopy.home.diagnoseTitle,
          style: context.typography.display.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: spacing.s),
        Text(
          'Take or choose a clear leaf photo to get a quick diagnosis.',
          style: context.typography.body.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _DiagnosisActionPanel extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const _DiagnosisActionPanel({
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();

    return AppCard.panel(
      padding: EdgeInsets.all(spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: AppCopy.home.semanticScanAction,
            child: AppButton.primary(
              isFullWidth: true,
              icon: Icons.photo_camera_rounded,
              label: AppCopy.home.actionCameraTitle,
              onPressed: onCameraPressed,
            ),
          ),
          SizedBox(height: spacing.sm),
          Semantics(
            button: true,
            label: AppCopy.home.semanticUploadAction,
            child: AppButton.secondary(
              isFullWidth: true,
              icon: Icons.image_rounded,
              label: AppCopy.home.actionUploadTitle,
              onPressed: onGalleryPressed,
            ),
          ),
        ],
      ),
    );
  }
}
