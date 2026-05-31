import 'package:flutter/material.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/components/diagnosis/confidence_meter.dart';
import 'package:crop_check_up/ui/components/diagnosis/status_badge.dart';

class ResultSummaryCard extends StatelessWidget {
  final DiagnosisResult result;
  
  const ResultSummaryCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          StatusBadge(isHealthy: result.isHealthy),
          const SizedBox(height: 16),
          Text(
            result.diseaseName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Crop: ${result.cropName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConfidenceMeter(confidence: result.confidence),
        ],
      ),
    );
  }
}
