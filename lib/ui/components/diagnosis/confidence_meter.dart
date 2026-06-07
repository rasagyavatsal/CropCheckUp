import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence;

  const ConfidenceMeter({
    super.key,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage = (confidence * 100).round();
    final colors = context.appColors;
    final Color color;
    if (percentage >= 80) {
      color = colors.success;
    } else if (percentage >= 50) {
      color = colors.warning;
    } else {
      color = colors.danger;
    }
    
    return Semantics(
      label: 'Diagnosis confidence score: $percentage%',
      container: true,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confidence Score',
                  style: context.typography.body.copyWith(
                    color: colors.mutedText,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: context.typography.title.copyWith(
                    color: color,
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
                backgroundColor: colors.subtleBorder,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

