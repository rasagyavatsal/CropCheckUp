import 'package:flutter/material.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/components/diagnosis/confidence_meter.dart';
import 'package:crop_check_up/ui/components/diagnosis/status_badge.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';
import 'package:crop_check_up/ui/components/app_components.dart';

class ResultSummaryCard extends StatelessWidget {
  final DiagnosisResult result;

  const ResultSummaryCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const spacing = SpacingTokens();
    final statusColor = result.isHealthy ? colors.success : colors.danger;

    return AppCard.panel(
      padding: EdgeInsets.all(spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusBadge(isHealthy: result.isHealthy),
              const Spacer(),
              Icon(
                result.isHealthy
                    ? Icons.verified_rounded
                    : Icons.priority_high_rounded,
                color: statusColor,
              ),
            ],
          ),
          SizedBox(height: spacing.m),
          Text(
            result.diseaseName,
            style: context.typography.headline.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: spacing.s),
          Row(
            children: [
              Expanded(
                child: _SummaryDatum(label: 'Crop', value: result.cropName),
              ),
              SizedBox(width: spacing.s),
              Expanded(
                child: _SummaryDatum(
                  label: 'Confidence',
                  value: '${result.confidencePercent}%',
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.m),
          Text(
            'Crop: ${result.cropName}',
            style: context.typography.caption.copyWith(color: colors.mutedText),
          ),
          SizedBox(height: spacing.l),
          ConfidenceMeter(confidence: result.confidence),
          SizedBox(height: spacing.m),
          Container(
            padding: EdgeInsets.all(spacing.m),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Icon(
                  result.isHealthy
                      ? Icons.visibility_rounded
                      : Icons.medical_services_rounded,
                  color: statusColor,
                  size: 20,
                ),
                SizedBox(width: spacing.m),
                Expanded(
                  child: Text(
                    result.isHealthy
                        ? 'Monitor crop health during routine field checks.'
                        : 'Inspect affected plants before selecting treatment.',
                    style: context.typography.label.copyWith(
                      color: colors.textSecondary,
                    ),
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

class _SummaryDatum extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryDatum({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.m,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.subtleBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.typography.caption.copyWith(color: colors.mutedText),
          ),
          SizedBox(height: spacing.xs),
          Text(
            value,
            style: context.typography.label.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
