import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/diagnosis_result.dart';
import '../theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text('Diagnosis Result'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Segmented Image
              if (imageBytes != null) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                    borderRadius: BorderRadius.circular(16),
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

              // Status icon
              Icon(statusIcon, size: 80, color: statusColor),
              const SizedBox(height: 16),

              // Primary label
              Text(
                result.diseaseName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Crop name subtitle
              Text(
                'Crop: ${result.cropName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 32),

              // Confidence card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: _ConfidenceBar(
                  confidence: result.confidence,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 32),

              // Disease Info Sections
              _DiseaseInfoSection(
                title: 'About',
                content: _getDescription(result),
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 20),

              _DiseaseInfoSection(
                title: 'Recommended Actions',
                items: _getRecommendations(result),
                icon: Icons.medical_services_rounded,
              ),
              const SizedBox(height: 20),

              _DiseaseInfoSection(
                title: 'Prevention Tips',
                items: _getPreventionTips(result),
                icon: Icons.shield_rounded,
              ),
              const SizedBox(height: 40),

              // Done Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.healthyGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Content generators
  // ---------------------------------------------------------------------------

  static List<String> _getRecommendations(DiagnosisResult r) {
    if (r.isHealthy) {
      return [
        'No action needed — your plant looks healthy!',
        'Continue regular watering and fertilisation.',
        'Monitor periodically for early signs of disease.',
      ];
    }
    return [
      'Remove and destroy affected leaves immediately.',
      'Apply an appropriate fungicide or bactericide.',
      'Isolate the plant to prevent spreading.',
      'Consult a local agricultural office for specific advice.',
    ];
  }

  static List<String> _getPreventionTips(DiagnosisResult r) {
    if (r.isHealthy) {
      return [
        'Maintain proper spacing between plants.',
        'Use drip irrigation rather than overhead watering.',
        'Rotate crops each season.',
      ];
    }
    return [
      'Ensure good air circulation around plants.',
      'Avoid overhead watering — use drip irrigation.',
      'Practice crop rotation to break disease cycles.',
      'Use disease‑resistant varieties where available.',
    ];
  }

  static String _getDescription(DiagnosisResult r) {
    if (r.isHealthy) {
      return 'The AI model determined this ${r.cropName} leaf is healthy with '
          '${r.confidencePercent}% confidence.';
    }
    return '${r.diseaseName} was detected on the ${r.cropName} leaf with '
        '${r.confidencePercent}% confidence. Early treatment is critical to '
        'prevent further spread.';
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content != null)
                Text(
                  content!,
                  style: const TextStyle(
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
                            style: const TextStyle(
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
