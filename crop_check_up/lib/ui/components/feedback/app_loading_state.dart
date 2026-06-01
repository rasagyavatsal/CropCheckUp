import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

class AppLoadingState extends StatelessWidget {
  final String? message;

  const AppLoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    final spacing = context.appLayout.spacing;
    final colors = context.appColors;

    return Center(
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              semanticsLabel: message ?? 'Loading',
            ),
            if (message != null) ...[
              SizedBox(height: spacing.m),
              Text(
                message!,
                style: typography.bodyLarge?.copyWith(
                  color: colors.mutedText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
