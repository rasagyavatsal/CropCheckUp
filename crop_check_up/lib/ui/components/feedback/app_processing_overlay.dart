import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

class AppProcessingOverlay extends StatelessWidget {
  final String message;

  const AppProcessingOverlay({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spacing = context.appLayout.spacing;
    
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: colors.cameraScrim,
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.l, vertical: spacing.l),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  semanticsLabel: message,
                ),
                SizedBox(height: spacing.m),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
