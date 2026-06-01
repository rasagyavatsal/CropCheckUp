import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/components/app_components.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spacing = context.appLayout.spacing;
    final typography = Theme.of(context).textTheme;

    return Center(
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.danger),
            SizedBox(height: spacing.m),
            Text(
              message,
              textAlign: TextAlign.center,
              style: typography.bodyLarge?.copyWith(
                color: colors.danger,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: spacing.l),
              AppButton.primary(
                onPressed: onRetry,
                label: 'Retry', // The button itself is handled by AppButton
              ),
            ],
          ],
        ),
      ),
    );
  }
}
