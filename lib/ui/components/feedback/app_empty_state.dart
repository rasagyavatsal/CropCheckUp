import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/components/app_components.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spacing = context.appLayout.spacing;
    final typography = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox, size: 48, color: colors.mutedText),
          SizedBox(height: spacing.m),
          Text(
            message,
            textAlign: TextAlign.center,
            style: typography.bodyLarge?.copyWith(
              color: colors.mutedText,
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: spacing.l),
            AppButton.secondary(
              onPressed: onAction,
              label: actionLabel!,
            ),
          ],
        ],
      ),
    );
  }
}
