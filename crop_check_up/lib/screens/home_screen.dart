import 'package:flutter/material.dart';
import '../ui/tokens/typography.dart';
import '../ui/flow/diagnosis_flow_coordinator.dart';
import '../ui/copy/app_copy.dart';

import '../widgets/header_background.dart';
import '../ui/adaptive/app_adaptive.dart';
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
    if (_isInitialising) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                AppCopy.home.initLoading,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  AppCopy.home.initErrorTitle,
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
                  child: Text(AppCopy.feedback.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const _HomeAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SectionHeader(title: AppCopy.home.diagnoseTitle),
                    const SizedBox(height: 16),
                    _buildActionCards(context),
                    const SizedBox(height: 32),
                    _SectionHeader(title: AppCopy.home.tipsTitle),
                    const SizedBox(height: 16),
                    _buildTipsList(),
                    const SizedBox(height: 40),
                    _buildFooter(context),
                  ]),
                ),
              ),
            ],
          ),
          if (_isDiagnosing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: AppCopy.home.actionCameraTitle,
            subtitle: AppCopy.home.actionCameraSubtitle,
            icon: Icons.camera_alt_rounded,
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.push(
                context,
                AppRoute.standard(builder: (_) => const CameraScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            title: AppCopy.home.actionUploadTitle,
            subtitle: AppCopy.home.actionUploadSubtitle,
            icon: Icons.image_rounded,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () async {
              setState(() => _isDiagnosing = true);
              await _coordinator.startGalleryDiagnosis(context);
              if (mounted) setState(() => _isDiagnosing = false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTipsList() {
    final tips = [
      ('Good Lighting', 'Ensure the leaf is well-lit for better accuracy.', Icons.light_mode_rounded),
      ('Single Leaf', 'Focus on one leaf at a time for precise diagnosis.', Icons.filter_center_focus_rounded),
      ('Clear Background', 'A plain background helps the AI segment the plant.', Icons.layers_clear_rounded),
    ];

    return Column(
      children: tips.map((tip) => _TipTile(tip: tip)).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          children: [
            const Icon(Icons.eco_outlined, size: 24),
            const SizedBox(height: 8),
            Text(
              AppCopy.home.footerText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  AppCopy.home.loadingOverlayTitle,
                  style: context.typography.title.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppCopy.home.loadingOverlaySubtitle,
                  style: context.typography.label.copyWith(
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'CropCheckUp',
          style: context.typography.title.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        background: const HeaderBackground(title: 'CropCheckUp'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: context.typography.title.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                subtitle,
                style: context.typography.label.copyWith(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final (String, String, IconData) tip;

  const _TipTile({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(tip.$3, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.$1,
                    style: context.typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    tip.$2,
                    style: context.typography.label.copyWith(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
