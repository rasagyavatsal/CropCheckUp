import 'package:flutter/material.dart';

import '../models/diagnosis_result.dart';
import '../theme/app_theme.dart';

/// Static treatment / disease information page.
///
/// Shows a summary card for the detected disease with basic management advice.
/// In a production app this would pull from a local database; here we provide
/// a generic template keyed off the [DiagnosisResult].
class TreatmentInfoScreen extends StatelessWidget {
  final DiagnosisResult result;

  const TreatmentInfoScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isHealthy = result.isHealthy;
    final statusColor = isHealthy ? AppTheme.healthyGreen : AppTheme.dangerRed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.25),
                  statusColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isHealthy
                          ? Icons.eco_rounded
                          : Icons.bug_report_rounded,
                      color: statusColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.diseaseName,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Detected on: ${result.cropName}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${result.confidencePercent}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recommendations
          _SectionCard(
            icon: Icons.medical_services_rounded,
            title: 'Recommended Actions',
            items: _getRecommendations(result),
          ),
          const SizedBox(height: 16),

          _SectionCard(
            icon: Icons.shield_rounded,
            title: 'Prevention Tips',
            items: _getPreventionTips(result),
          ),
          const SizedBox(height: 16),

          _SectionCard(
            icon: Icons.info_outline_rounded,
            title: 'About this disease',
            items: [_getDescription(result)],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Content generators – keyed on health status for now; extend with a real DB.
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
      'Consult a local agricultural extension office for region‑specific advice.',
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
      'Keep tools and equipment clean.',
    ];
  }

  static String _getDescription(DiagnosisResult r) {
    if (r.isHealthy) {
      return 'The AI model determined this ${r.cropName} leaf is healthy with '
          '${r.confidencePercent}% confidence. Keep up the great work!';
    }
    return '${r.diseaseName} was detected on the ${r.cropName} leaf with '
        '${r.confidencePercent}% confidence. Early treatment is critical to '
        'prevent further spread to neighbouring plants.';
  }
}

// -----------------------------------------------------------------------------
// Section card widget
// -----------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.healthyGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ',
                      style: TextStyle(color: AppTheme.healthyGreen)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white70,
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
    );
  }
}
