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

    final colors = context.appColors;
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
                  SizedBox(height: spacing.l),
                  const _CaptureChecklist(),
                  SizedBox(height: spacing.l),
                  const _ModelFacts(),
                  SizedBox(height: spacing.l),
                  Text(
                    AppCopy.home.footerText,
                    style: context.typography.caption.copyWith(
                      color: colors.mutedText,
                    ),
                    textAlign: TextAlign.center,
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
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.s,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.subtleBorder),
            borderRadius: BorderRadius.circular(const RadiusTokens().l),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 16, color: colors.success),
              SizedBox(width: spacing.s),
              Text(
                'Model ready',
                style: context.typography.label.copyWith(
                  color: colors.brandSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.m),
        Text(
          AppCopy.home.diagnoseTitle,
          style: context.typography.display.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: spacing.s),
        Text(
          'Camera or gallery input for crop leaf triage.',
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
    final colors = context.appColors;

    return AppCard.panel(
      padding: EdgeInsets.all(spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(const RadiusTokens().l),
                ),
                child: Icon(
                  Icons.document_scanner_rounded,
                  color: colors.brand,
                ),
              ),
              SizedBox(width: spacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New diagnosis', style: context.typography.title),
                    SizedBox(height: spacing.xs),
                    Text(
                      'Single leaf image required',
                      style: context.typography.caption.copyWith(
                        color: colors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.l),
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

class _CaptureChecklist extends StatelessWidget {
  const _CaptureChecklist();

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppCopy.home.tipsTitle, style: context.typography.title),
        SizedBox(height: spacing.sm),
        const _ChecklistRow(
          icon: Icons.wb_sunny_rounded,
          label: 'Bright light',
          value: 'Avoid shadows and glare',
        ),
        SizedBox(height: spacing.s),
        const _ChecklistRow(
          icon: Icons.filter_center_focus_rounded,
          label: 'One leaf',
          value: 'Fill most of the frame',
        ),
        SizedBox(height: spacing.s),
        const _ChecklistRow(
          icon: Icons.layers_clear_rounded,
          label: 'Clear background',
          value: 'Keep other plants out',
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ChecklistRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.brandSecondary),
          SizedBox(width: spacing.m),
          Expanded(
            child: Text(
              label,
              style: context.typography.label.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: context.typography.caption.copyWith(
                color: colors.mutedText,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelFacts extends StatelessWidget {
  const _ModelFacts();

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing.s * 2) / 3;

        return Wrap(
          spacing: spacing.s,
          runSpacing: spacing.s,
          children:
              [
                _FactTile(width: itemWidth, value: '68', label: 'labels'),
                _FactTile(width: itemWidth, value: '224', label: 'input px'),
                _FactTile(
                  width: itemWidth,
                  value: 'TFLite',
                  label: 'local model',
                ),
              ].map((tile) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.subtleBorder),
                    borderRadius: BorderRadius.circular(const RadiusTokens().l),
                  ),
                  child: tile,
                );
              }).toList(),
        );
      },
    );
  }
}

class _FactTile extends StatelessWidget {
  final double width;
  final String value;
  final String label;

  const _FactTile({
    required this.width,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s,
          vertical: spacing.m,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: context.typography.title.copyWith(color: colors.brand),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing.xs),
            Text(
              label,
              style: context.typography.caption.copyWith(
                color: colors.mutedText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
