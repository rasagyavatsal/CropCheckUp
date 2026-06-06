import 'package:flutter/material.dart';

import 'package:crop_check_up/models/diagnosis_history_entry.dart';
import 'package:crop_check_up/ui/components/app_components.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';

class RecentDiagnosesSection extends StatelessWidget {
  final List<DiagnosisHistoryEntry> entries;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<DiagnosisHistoryEntry> onEntryTap;

  const RecentDiagnosesSection({
    super.key,
    required this.entries,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    Widget body;
    if (isLoading) {
      body = const _RecentDiagnosesLoading();
    } else if (error != null) {
      body = _RecentDiagnosesError(onRetry: onRetry);
    } else if (entries.isEmpty) {
      body = const _RecentDiagnosesEmptyState();
    } else {
      body = _RecentDiagnosesCarousel(entries: entries, onEntryTap: onEntryTap);
    }

    return Semantics(
      container: true,
      child: Column(
        key: const ValueKey('recent-diagnoses-section'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppCopy.home.recentDiagnosesTitle,
            style: context.typography.title.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: spacing.sm),
          body,
        ],
      ),
    );
  }
}

class _RecentDiagnosesLoading extends StatelessWidget {
  const _RecentDiagnosesLoading();

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return AppCard.panel(
      key: const ValueKey('recent-diagnoses-loading'),
      padding: EdgeInsets.all(spacing.m),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.brand,
            ),
          ),
          SizedBox(width: spacing.m),
          Expanded(
            child: Text(
              AppCopy.home.recentLoading,
              style: context.typography.label.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentDiagnosesEmptyState extends StatelessWidget {
  const _RecentDiagnosesEmptyState();

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return AppCard.info(
      key: const ValueKey('recent-diagnoses-empty'),
      padding: EdgeInsets.all(spacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history_rounded, color: colors.mutedText, size: 24),
          SizedBox(width: spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppCopy.home.recentEmptyTitle,
                  style: context.typography.label.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  AppCopy.home.recentEmptyMessage,
                  style: context.typography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentDiagnosesError extends StatelessWidget {
  final VoidCallback onRetry;

  const _RecentDiagnosesError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return AppCard.info(
      key: const ValueKey('recent-diagnoses-error'),
      padding: EdgeInsets.all(spacing.m),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.warning, size: 24),
          SizedBox(width: spacing.m),
          Expanded(
            child: Text(
              AppCopy.home.recentError,
              style: context.typography.label.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: spacing.s),
          AppButton.ghost(label: AppCopy.feedback.retry, onPressed: onRetry),
        ],
      ),
    );
  }
}

class _RecentDiagnosesCarousel extends StatelessWidget {
  final List<DiagnosisHistoryEntry> entries;
  final ValueChanged<DiagnosisHistoryEntry> onEntryTap;

  const _RecentDiagnosesCarousel({
    required this.entries,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();

    return SizedBox(
      key: const ValueKey('recent-diagnoses-carousel'),
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        primary: false,
        itemCount: entries.length,
        separatorBuilder: (_, _) => SizedBox(width: spacing.m),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return SizedBox(
            width: 184,
            child: _RecentDiagnosisCard(
              entry: entry,
              onTap: () => onEntryTap(entry),
            ),
          );
        },
      ),
    );
  }
}

class _RecentDiagnosisCard extends StatelessWidget {
  final DiagnosisHistoryEntry entry;
  final VoidCallback onTap;

  const _RecentDiagnosisCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;
    final result = entry.result;
    final statusColor = result.isHealthy ? colors.success : colors.danger;
    final statusLabel = result.isHealthy ? 'Healthy' : result.diseaseName;

    return Semantics(
      button: true,
      label: 'Open diagnosis for ${result.cropName}, $statusLabel',
      child: AppCard.action(
        key: ValueKey('recent-diagnosis-card-${entry.id}'),
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 92,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: colors.surface),
                  Semantics(
                    image: true,
                    label: 'Processed leaf thumbnail for ${result.cropName}',
                    child: Image.memory(
                      entry.imageBytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.image_not_supported_rounded,
                            color: colors.mutedText,
                          ),
                    ),
                  ),
                  Positioned(
                    top: spacing.s,
                    right: spacing.s,
                    child: _HistoryStatusIcon(
                      color: statusColor,
                      isHealthy: result.isHealthy,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.cropName,
                      style: context.typography.label.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      statusLabel,
                      style: context.typography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: colors.mutedText,
                        ),
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: Text(
                            _formatShortDate(entry.createdAt),
                            style: context.typography.caption.copyWith(
                              color: colors.mutedText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.s),
                    _ConfidencePill(
                      confidence: '${result.confidencePercent}%',
                      color: statusColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortDate(DateTime value) {
    final now = DateTime.now();
    final local = value.toLocal();

    if (DateUtils.isSameDay(local, now)) {
      return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (DateUtils.isSameDay(local, yesterday)) {
      return 'Yesterday';
    }

    final month = _monthNames[local.month - 1];
    if (local.year == now.year) {
      return '$month ${local.day}';
    }

    return '$month ${local.day}, ${local.year}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

class _HistoryStatusIcon extends StatelessWidget {
  final Color color;
  final bool isHealthy;

  const _HistoryStatusIcon({required this.color, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.32)),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          isHealthy ? Icons.check_rounded : Icons.priority_high_rounded,
          color: color,
          size: 16,
        ),
      ),
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  final String confidence;
  final Color color;

  const _ConfidencePill({required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    const radius = RadiusTokens();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius.pill),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        '$confidence confidence',
        style: context.typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
