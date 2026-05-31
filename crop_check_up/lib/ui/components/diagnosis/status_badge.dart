import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

class StatusBadge extends StatelessWidget {
  final bool isHealthy;

  const StatusBadge({
    super.key,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    final statusTheme = context.diagnosisStatus;
    final color = isHealthy ? statusTheme.healthyColor : statusTheme.dangerColor;
    final text = isHealthy ? 'Healthy' : 'Disease Detected';
    final icon = isHealthy ? Icons.check_circle : Icons.warning_rounded;

    return Semantics(
      label: 'Diagnosis Status: $text',
      container: true,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                text,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
