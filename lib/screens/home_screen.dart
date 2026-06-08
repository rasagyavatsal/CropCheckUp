import 'dart:async';

import 'package:flutter/material.dart';
import '../models/diagnosis_history_entry.dart';
import '../services/app_metadata_service.dart';
import '../services/diagnosis_history_repository.dart';
import '../ui/tokens/typography.dart';
import '../ui/flow/diagnosis_flow_coordinator.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/app_components.dart';
import '../ui/components/history/recent_diagnoses_section.dart';
import '../ui/components/layout/layout.dart';
import '../ui/adaptive/app_adaptive.dart';
import '../ui/tokens/spacing_tokens.dart';
import '../ui/theme/theme_ext.dart';
import '../ui/theme/app_theme.dart';
import 'camera_screen.dart';
import 'diagnosis_result_screen.dart';

class HomeScreen extends StatefulWidget {
  final DiagnosisFlowCoordinator? coordinator;
  final DiagnosisHistoryRepository? historyRepository;
  final WidgetBuilder? cameraScreenBuilder;
  final Future<String?> Function()? appVersionLoader;

  const HomeScreen({
    super.key,
    this.coordinator,
    this.historyRepository,
    this.cameraScreenBuilder,
    this.appVersionLoader,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DiagnosisHistoryRepository _historyRepository;
  late final DiagnosisFlowCoordinator _coordinator;
  late final Future<String?> Function() _appVersionLoader;
  late final bool _ownsCoordinator;

  bool _isInitialising = true;
  String? _initError;
  String? _appVersion;
  bool _isDiagnosing = false;
  bool _isHistoryLoading = true;
  String? _historyError;
  List<DiagnosisHistoryEntry> _recentDiagnoses = const [];
  int _historyLoadRequest = 0;

  @override
  void initState() {
    super.initState();
    _historyRepository =
        widget.historyRepository ?? DiagnosisHistoryRepository();
    _coordinator =
        widget.coordinator ??
        DiagnosisFlowCoordinator(historyRepository: _historyRepository);
    _appVersionLoader =
        widget.appVersionLoader ?? const AppMetadataService().loadVersion;
    _ownsCoordinator = widget.coordinator == null;
    _bootstrap();
    unawaited(_loadAppVersion());
    unawaited(_loadRecentDiagnoses(showLoading: false));
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

  Future<void> _loadAppVersion() async {
    try {
      final version = await _appVersionLoader();
      if (!mounted || version == null) return;
      setState(() => _appVersion = version);
    } catch (_) {
      // Version is supplementary metadata; the home workflow should not block.
    }
  }

  @override
  void dispose() {
    if (_ownsCoordinator) {
      _coordinator.dispose();
    }
    super.dispose();
  }

  Future<void> _startGalleryDiagnosis() async {
    if (_isDiagnosing) return;

    setState(() => _isDiagnosing = true);
    DiagnosisOutcome outcome = DiagnosisOutcome.failed;

    try {
      outcome = await _coordinator.startGalleryDiagnosis(context);
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(context, AppCopy.camera.diagnosisFailed);
      }
    } finally {
      if (mounted) setState(() => _isDiagnosing = false);
    }

    if (mounted && outcome == DiagnosisOutcome.success) {
      unawaited(_loadRecentDiagnoses());
    }
  }

  Future<void> _startCameraDiagnosis() async {
    await Navigator.push<void>(
      context,
      AppRoute.standard(
        builder:
            (context) =>
                widget.cameraScreenBuilder?.call(context) ??
                const CameraScreen(),
      ),
    );

    if (mounted) {
      unawaited(_loadRecentDiagnoses());
    }
  }

  Future<void> _loadRecentDiagnoses({bool showLoading = true}) async {
    final request = ++_historyLoadRequest;

    if (showLoading && mounted) {
      setState(() {
        _isHistoryLoading = true;
        _historyError = null;
      });
    }

    try {
      final entries = await _historyRepository.loadRecent(limit: 10);
      if (!mounted || request != _historyLoadRequest) return;
      setState(() {
        _recentDiagnoses = entries;
        _historyError = null;
        _isHistoryLoading = false;
      });
    } catch (e) {
      if (!mounted || request != _historyLoadRequest) return;
      setState(() {
        _historyError = e.toString();
        _isHistoryLoading = false;
      });
    }
  }

  void _openHistoryEntry(DiagnosisHistoryEntry entry) {
    Navigator.of(context).push(
      AppRoute.standard<void>(
        builder:
            (_) => DiagnosisResultScreen(
              result: entry.result,
              imageBytes: entry.imageBytes,
            ),
      ),
    );
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
          applySafeArea: false,
          child: AppGridBackground(
            child: SafeArea(
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
                      onCameraPressed: _startCameraDiagnosis,
                      onGalleryPressed: _startGalleryDiagnosis,
                    ),
                    SizedBox(height: spacing.l),
                    RecentDiagnosesSection(
                      entries: _recentDiagnoses,
                      isLoading: _isHistoryLoading,
                      error: _historyError,
                      onRetry: _loadRecentDiagnoses,
                      onEntryTap: _openHistoryEntry,
                    ),
                    if (_appVersion != null) ...[
                      SizedBox(height: spacing.l),
                      _AppVersionFooter(version: _appVersion!),
                    ],
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

class _AppVersionFooter extends StatelessWidget {
  final String version;

  const _AppVersionFooter({required this.version});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Align(
      alignment: Alignment.center,
      child: Text(
        AppCopy.home.versionLabel(version),
        style: context.typography.caption.copyWith(color: colors.mutedText),
      ),
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
