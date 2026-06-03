import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/components/diagnosis/result_summary_card.dart';
import 'package:crop_check_up/ui/components/diagnosis/info_section.dart';
import 'package:crop_check_up/ui/components/diagnosis/bullet_list.dart';
import 'package:crop_check_up/ui/components/diagnosis/evidence_image_card.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';

class ResultPresentationView extends StatelessWidget {
  final DiagnosisResult result;
  final Uint8List? imageBytes;

  const ResultPresentationView({
    super.key,
    required this.result,
    this.imageBytes,
  });

  Widget _buildContent(BuildContext context, String content) {
    if (content.contains('\n')) {
      return BulletList(
        items: content.split('\n').where((s) => s.trim().isNotEmpty).toList(),
      );
    }
    final colors = context.appColors;
    return Text(
      content,
      style: context.typography.body.copyWith(
        color: colors.textSecondary,
        height: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResultSummaryCard(result: result),
        SizedBox(height: spacing.l),
        if (imageBytes != null) ...[
          _ReportSectionLabel(
            icon: Icons.photo_library_rounded,
            label: 'Evidence image',
          ),
          SizedBox(height: spacing.sm),
          EvidenceImageCard(imageBytes: imageBytes!),
          SizedBox(height: spacing.l),
        ],
        _ReportSectionLabel(
          icon:
              result.isHealthy
                  ? Icons.shield_rounded
                  : Icons.assignment_rounded,
          label: result.isHealthy ? 'Field notes' : 'Action notes',
        ),
        SizedBox(height: spacing.sm),
        if (result.isHealthy) ...[
          InfoSection(
            title: AppCopy.result.sectionStatus,
            icon: Icons.info_outline_rounded,
            content: _buildContent(
              context,
              AppCopy.result.healthyConfidence(
                result.cropName,
                result.confidencePercent.toString(),
              ),
            ),
          ),
          SizedBox(height: spacing.m),
          InfoSection(
            title: AppCopy.result.sectionHealthyTips,
            icon: Icons.shield_rounded,
            content: const BulletList(
              items: [
                'Maintain proper spacing between plants.',
                'Use drip irrigation rather than overhead watering.',
                'Rotate crops each season.',
                'Monitor periodically for early signs of disease.',
              ],
            ),
          ),
        ] else ...[
          if (result.symptoms != null) ...[
            InfoSection(
              title: AppCopy.result.sectionSymptoms,
              icon: Icons.visibility_rounded,
              content: _buildContent(context, result.symptoms!),
            ),
            SizedBox(height: spacing.m),
          ],
          if (result.causes != null) ...[
            InfoSection(
              title: AppCopy.result.sectionCauses,
              icon: Icons.biotech_rounded,
              content: _buildContent(context, result.causes!),
            ),
            SizedBox(height: spacing.m),
          ],
          if (result.management != null) ...[
            InfoSection(
              title: AppCopy.result.sectionManagement,
              icon: Icons.medical_services_rounded,
              content: _buildContent(context, result.management!),
            ),
          ],
          if (result.symptoms == null &&
              result.causes == null &&
              result.management == null)
            InfoSection(
              title: AppCopy.result.sectionAbout,
              icon: Icons.info_outline_rounded,
              content: _buildContent(
                context,
                AppCopy.result.diagnosisConfidence(
                  result.cropName,
                  result.diseaseName,
                  result.confidencePercent.toString(),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _ReportSectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReportSectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.brandSecondary),
        SizedBox(width: spacing.s),
        Text(
          label,
          style: context.typography.label.copyWith(
            color: colors.brandSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
