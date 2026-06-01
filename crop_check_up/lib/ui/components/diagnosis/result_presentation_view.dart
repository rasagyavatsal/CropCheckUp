import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/components/diagnosis/result_summary_card.dart';
import 'package:crop_check_up/ui/components/diagnosis/info_section.dart';
import 'package:crop_check_up/ui/components/diagnosis/bullet_list.dart';
import 'package:crop_check_up/ui/components/diagnosis/evidence_image_card.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';

class ResultPresentationView extends StatelessWidget {
  final DiagnosisResult result;
  final Uint8List? imageBytes;

  const ResultPresentationView({
    super.key,
    required this.result,
    this.imageBytes,
  });

  Widget _buildContent(String content) {
    if (content.contains('\n')) {
      return BulletList(items: content.split('\n').where((s) => s.trim().isNotEmpty).toList());
    }
    return Text(content);
  }

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageBytes != null) ...[
          EvidenceImageCard(imageBytes: imageBytes!),
          SizedBox(height: spacing.xl),
        ],
        ResultSummaryCard(result: result),
        SizedBox(height: spacing.xxl),
        if (result.isHealthy) ...[
          InfoSection(
            title: AppCopy.result.sectionStatus,
            icon: Icons.info_outline_rounded,
            content: _buildContent(AppCopy.result.healthyConfidence(result.cropName, result.confidencePercent.toString())),
          ),
          SizedBox(height: spacing.xl),
          InfoSection(
            title: AppCopy.result.sectionHealthyTips,
            icon: Icons.shield_rounded,
            content: const BulletList(items: [
              'Maintain proper spacing between plants.',
              'Use drip irrigation rather than overhead watering.',
              'Rotate crops each season.',
              'Monitor periodically for early signs of disease.',
            ]),
          ),
        ] else ...[
          if (result.symptoms != null) ...[
            InfoSection(
              title: AppCopy.result.sectionSymptoms,
              icon: Icons.visibility_rounded,
              content: _buildContent(result.symptoms!),
            ),
            SizedBox(height: spacing.xl),
          ],
          if (result.causes != null) ...[
            InfoSection(
              title: AppCopy.result.sectionCauses,
              icon: Icons.biotech_rounded,
              content: _buildContent(result.causes!),
            ),
            SizedBox(height: spacing.xl),
          ],
          if (result.management != null) ...[
            InfoSection(
              title: AppCopy.result.sectionManagement,
              icon: Icons.medical_services_rounded,
              content: _buildContent(result.management!),
            ),
            SizedBox(height: spacing.xl),
          ],
          if (result.symptoms == null && result.causes == null && result.management == null)
            InfoSection(
              title: AppCopy.result.sectionAbout,
              icon: Icons.info_outline_rounded,
              content: _buildContent(AppCopy.result.diagnosisConfidence(result.cropName, result.diseaseName, result.confidencePercent.toString())),
            ),
        ],
      ],
    );
  }
}
