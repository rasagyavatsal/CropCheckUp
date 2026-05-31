import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/components/diagnosis/result_summary_card.dart';
import 'package:crop_check_up/ui/components/diagnosis/info_section.dart';
import 'package:crop_check_up/ui/components/diagnosis/bullet_list.dart';

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
              title: 'Status',
              icon: Icons.info_outline_rounded,
              content: _buildContent('The AI model determined this ${result.cropName} leaf is healthy with ${result.confidencePercent}% confidence.'),
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
                title: 'Symptoms',
                icon: Icons.visibility_rounded,
                content: _buildContent(result.symptoms!),
              ),
              const SizedBox(height: 24),
            ],
            if (result.causes != null) ...[
              InfoSection(
                title: 'Causes',
                icon: Icons.biotech_rounded,
                content: _buildContent(result.causes!),
              ),
              const SizedBox(height: 24),
            ],
            if (result.management != null) ...[
              InfoSection(
                title: 'Management & Treatment',
                icon: Icons.medical_services_rounded,
                content: _buildContent(result.management!),
              ),
              const SizedBox(height: 24),
            ],
            if (result.symptoms == null && result.causes == null && result.management == null)
              InfoSection(
                title: 'About',
                icon: Icons.info_outline_rounded,
                content: _buildContent('${result.diseaseName} was detected on the ${result.cropName} leaf with ${result.confidencePercent}% confidence. Early treatment is critical to prevent further spread.'),
              ),
          ],
        ],
      ),
    );
  }
}
