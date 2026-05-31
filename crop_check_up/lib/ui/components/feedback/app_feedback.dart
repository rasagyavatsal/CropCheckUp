import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/adaptive/app_adaptive.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

class AppFeedback {
  static void showSuccess(BuildContext context, String message) {
    AppHaptics.confirmation();
    _showSnackbar(context, message, _FeedbackIntent.success);
  }

  static void showError(BuildContext context, String message) {
    AppHaptics.error();
    _showSnackbar(context, message, _FeedbackIntent.error);
  }

  static void showWarning(BuildContext context, String message) {
    AppHaptics.warning();
    _showSnackbar(context, message, _FeedbackIntent.warning);
  }

  static void showNeutral(BuildContext context, String message) {
    AppHaptics.primaryAction();
    _showSnackbar(context, message, _FeedbackIntent.neutral);
  }

  static void _showSnackbar(BuildContext context, String message, _FeedbackIntent intent) {
    final colors = context.appColors;
    
    Color backgroundColor;
    Color textColor = colors.raisedSurface;
    IconData icon;

    switch (intent) {
      case _FeedbackIntent.success:
        backgroundColor = colors.success;
        icon = Icons.check_circle_outline;
        break;
      case _FeedbackIntent.error:
        backgroundColor = colors.danger;
        icon = Icons.error_outline;
        break;
      case _FeedbackIntent.warning:
        backgroundColor = colors.warning;
        textColor = colors.textPrimary;
        icon = Icons.warning_amber_outlined;
        break;
      case _FeedbackIntent.neutral:
        backgroundColor = colors.textPrimary;
        textColor = colors.background;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _FeedbackIntent {
  success,
  error,
  warning,
  neutral,
}
