import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence;

  const ConfidenceMeter({
    super.key,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage = (confidence * 100).round();
    final statusTheme = context.diagnosisStatus;
    
    final color = percentage >= 80 
      ? statusTheme.healthyColor 
      : (percentage >= 50 ? statusTheme.warningColor : statusTheme.dangerColor);
    
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
              '$percentage%',
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

