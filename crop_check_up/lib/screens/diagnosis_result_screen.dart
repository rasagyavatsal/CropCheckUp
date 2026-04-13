import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../models/diagnosis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/header_background.dart';

/// Full‑screen route that presents a [DiagnosisResult].
///
/// Shows the disease name, crop name, a confidence progress bar, a colour‑coded
/// health icon, and a button to navigate to treatment information.
class DiagnosisResultScreen extends StatelessWidget {
  final DiagnosisResult result;
  final Uint8List? imageBytes;

  const DiagnosisResultScreen({
    super.key,
    required this.result,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        result.isHealthy ? AppTheme.healthyGreen : AppTheme.dangerRed;
    final statusIcon =
        result.isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            stretch: true,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Diagnosis Result',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              background: HeaderBackground(
                title: 'Diagnosis Result',
                subtitle: result.isHealthy ? 'HEALTHY PLANT' : 'DISEASE DETECTED',
                icon: statusIcon,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Segmented Image
                if (imageBytes != null) ...[
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
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
                  ),
                  const SizedBox(height: 32),
                ],

                // Status info
                Column(
                  children: [
                    Icon(statusIcon, size: 64, color: statusColor),
                    const SizedBox(height: 16),
                    Text(
                      result.diseaseName,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crop: ${result.cropName}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Confidence card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: _ConfidenceBar(
                    confidence: result.confidence,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Disease Info Sections
                if (result.isHealthy) ...[
                  _DiseaseInfoSection(
                    title: 'Status',
                    content: 'The AI model determined this ${result.cropName} leaf is healthy with '
                        '${result.confidencePercent}% confidence.',
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _DiseaseInfoSection(
                    title: 'Maintenance Tips',
                    items: const [
                      'Maintain proper spacing between plants.',
                      'Use drip irrigation rather than overhead watering.',
                      'Rotate crops each season.',
                      'Monitor periodically for early signs of disease.',
                    ],
                    icon: Icons.shield_rounded,
                  ),
                ] else ...[
                  if (result.symptoms != null) ...[
                    _DiseaseInfoSection(
                      title: 'Symptoms',
                      content: result.symptoms,
                      icon: Icons.visibility_rounded,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (result.causes != null) ...[
                    _DiseaseInfoSection(
                      title: 'Causes',
                      content: result.causes,
                      icon: Icons.biotech_rounded,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (result.management != null) ...[
                    _DiseaseInfoSection(
                      title: 'Management & Treatment',
                      content: result.management,
                      icon: Icons.medical_services_rounded,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (result.symptoms == null && result.causes == null && result.management == null)
                    _DiseaseInfoSection(
                      title: 'About',
                      content: '${result.diseaseName} was detected on the ${result.cropName} leaf with '
                          '${result.confidencePercent}% confidence. Early treatment is critical to '
                          'prevent further spread.',
                      icon: Icons.info_outline_rounded,
                    ),
                ],
                const SizedBox(height: 40),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiseaseInfoSection extends StatelessWidget {
  final String title;
  final String? content;
  final List<String>? items;
  final IconData icon;

  const _DiseaseInfoSection({
    required this.title,
    this.content,
    this.items,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.healthyGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content != null)
                Text(
                  content!,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              if (items != null)
                ...items!.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(color: AppTheme.healthyGreen)),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double confidence;
  final Color color;

  const _ConfidenceBar({required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence Score',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '${(confidence * 100).round()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 12,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
