import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/components/diagnosis/result_summary_card.dart';
import 'package:crop_check_up/ui/components/diagnosis/info_section.dart';
import 'package:crop_check_up/ui/components/diagnosis/bullet_list.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageBytes != null) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.memory(
                  imageBytes!,
                  height: 240,
                  width: 240,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          ResultSummaryCard(result: result),
          const SizedBox(height: 32),
          if (result.isHealthy) ...[
            InfoSection(
              title: AppCopy.result.sectionStatus,
              icon: Icons.info_outline_rounded,
              content: _buildContent(AppCopy.result.healthyConfidence(result.cropName, result.confidencePercent.toString())),
            ),
            const SizedBox(height: 24),
            InfoSection(
              title: 'Maintenance Tips',
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
              const SizedBox(height: 24),
            ],
            if (result.causes != null) ...[
              InfoSection(
                title: AppCopy.result.sectionCauses,
                icon: Icons.biotech_rounded,
                content: _buildContent(result.causes!),
              ),
              const SizedBox(height: 24),
            ],
            if (result.management != null) ...[
              InfoSection(
                title: AppCopy.result.sectionManagement,
                icon: Icons.medical_services_rounded,
                content: _buildContent(result.management!),
              ),
              const SizedBox(height: 24),
            ],
            if (result.symptoms == null && result.causes == null && result.management == null)
              InfoSection(
                title: AppCopy.result.sectionAbout,
                icon: Icons.info_outline_rounded,
                content: _buildContent(AppCopy.result.diagnosisConfidence(result.cropName, result.diseaseName, result.confidencePercent.toString())),
              ),
          ],
        ],
      ),
    );
  }
}
