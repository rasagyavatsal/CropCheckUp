import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';

class StatusBadge extends StatelessWidget {
  final bool isHealthy;

  const StatusBadge({
    super.key,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isHealthy ? colors.success : colors.danger;
    final text = isHealthy ? 'Healthy' : 'Disease Detected';
    final icon = isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded;

    return Semantics(
      label: 'Diagnosis Status: $text',
      container: true,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: context.typography.label.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
