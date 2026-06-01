import 'package:flutter/material.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/components/diagnosis/confidence_meter.dart';
import 'package:crop_check_up/ui/components/diagnosis/status_badge.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';

class ResultSummaryCard extends StatelessWidget {
  final DiagnosisResult result;
  
  const ResultSummaryCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const radius = RadiusTokens();
    const spacing = SpacingTokens();

    return Container(
      padding: EdgeInsets.all(spacing.xl),
      decoration: BoxDecoration(
        color: colors.raisedSurface,
        borderRadius: BorderRadius.circular(radius.xl),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          StatusBadge(isHealthy: result.isHealthy),
          SizedBox(height: spacing.l),
          Text(
            result.diseaseName,
            style: context.typography.headline.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 28,
              letterSpacing: -0.5,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.s),
          Text(
            'Crop: ${result.cropName}',
            style: context.typography.body.copyWith(
              color: colors.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.xl),
          ConfidenceMeter(confidence: result.confidence),
        ],
      ),
    );
  }
}
