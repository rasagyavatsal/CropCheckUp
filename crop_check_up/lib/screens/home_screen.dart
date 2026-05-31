import 'package:flutter/material.dart';
import '../ui/tokens/typography.dart';
import '../ui/flow/diagnosis_flow_coordinator.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/app_components.dart';
import '../ui/components/layout/layout.dart';
import '../ui/components/cards/app_card.dart';

import '../ui/adaptive/app_adaptive.dart';
import '../ui/tokens/spacing_tokens.dart';
import '../ui/tokens/radius_tokens.dart';
import '../ui/theme/theme_ext.dart';
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
      // Background removal and classifier services can be implicitly initialized
      // but to preserve the loading screen we can pre-warm them.
      // We'll leave it as is, or we can just delay slightly if not needed.
      // Wait, DiagnosisWorkflowService had an init() method which called services' init.
      // I can let DiagnosisFlowCoordinator expose an init() or I can let services init lazily.
      // The issue says: Coordinator uses existing background-removal and classifier services internally.
      // I'll call them via the coordinator if needed, but the services are singletons.
      // Actually, I'll add an init() to DiagnosisFlowCoordinator.
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

    return Stack(
      children: [
        AppPageShell.sliver(
          slivers: [
            const AppBrandHeader(
              title: 'CropCheckUp',
            ),
            SliverPadding(
              padding: EdgeInsets.all(spacing.l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    AppCopy.home.diagnoseTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  SizedBox(height: spacing.m),
                  _buildActionCards(context, spacing, radius),
                  SizedBox(height: spacing.xl),
                  Text(
                    AppCopy.home.tipsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  SizedBox(height: spacing.m),
                  _buildTipsList(context, spacing),
                  SizedBox(height: spacing.xxl),
                  _buildFooter(context, spacing),
                ]),
              ),
            ),
          ],
        ),
        if (_isDiagnosing) AppProcessingOverlay(message: AppCopy.home.loadingOverlayTitle),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, SpacingTokens spacing, RadiusTokens radius) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Row(
      children: [
        Expanded(
          child: AppCard.action(
            onTap: () {
              Navigator.push(
                context,
                AppRoute.standard(builder: (_) => const CameraScreen()),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(radius.l),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: primaryColor, size: 28),
                ),
                SizedBox(height: spacing.m),
                Text(
                  AppCopy.home.actionCameraTitle,
                  style: context.typography.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  AppCopy.home.actionCameraSubtitle,
                  style: context.typography.label.copyWith(
                    color: context.appColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: spacing.m),
        Expanded(
          child: AppCard.action(
            onTap: () async {
              setState(() => _isDiagnosing = true);
              await _coordinator.startGalleryDiagnosis(context);
              if (mounted) setState(() => _isDiagnosing = false);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(radius.l),
                  ),
                  child: Icon(Icons.image_rounded, color: secondaryColor, size: 28),
                ),
                SizedBox(height: spacing.m),
                Text(
                  AppCopy.home.actionUploadTitle,
                  style: context.typography.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  AppCopy.home.actionUploadSubtitle,
                  style: context.typography.label.copyWith(
                    color: context.appColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsList(BuildContext context, SpacingTokens spacing) {
    final tips = [
      ('Good Lighting', 'Ensure the leaf is well-lit for better accuracy.', Icons.light_mode_rounded),
      ('Single Leaf', 'Focus on one leaf at a time for precise diagnosis.', Icons.filter_center_focus_rounded),
      ('Clear Background', 'A plain background helps the AI segment the plant.', Icons.layers_clear_rounded),
    ];

    return Column(
      children: tips.map((tip) => Padding(
        padding: EdgeInsets.only(bottom: spacing.sm),
        child: AppCard.info(
          child: Row(
            children: [
              Icon(tip.$3, color: Theme.of(context).colorScheme.primary, size: 24),
              SizedBox(width: spacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.$1,
                      style: context.typography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tip.$2,
                      style: context.typography.label.copyWith(
                        color: context.appColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildFooter(BuildContext context, SpacingTokens spacing) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          children: [
            const Icon(Icons.eco_outlined, size: 24),
            SizedBox(height: spacing.s),
            Text(
              AppCopy.home.footerText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

