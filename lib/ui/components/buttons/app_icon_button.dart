import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/adaptive/app_adaptive.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/size_tokens.dart';

enum AppIconButtonVariant { filled, translucent, ghost, danger }

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppIconButtonVariant _variant;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  }) : _variant = AppIconButtonVariant.ghost;

  const AppIconButton.filled({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  }) : _variant = AppIconButtonVariant.filled;

  const AppIconButton.translucent({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  }) : _variant = AppIconButtonVariant.translucent;

  const AppIconButton.ghost({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  }) : _variant = AppIconButtonVariant.ghost;

  const AppIconButton.danger({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  }) : _variant = AppIconButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = onPressed == null
        ? null
        : () {
            AppHaptics.primaryAction();
            onPressed!();
          };

    final colors = context.appColors;
    const sizes = SizeTokens();

    Color? backgroundColor;
    Color? foregroundColor;

    switch (_variant) {
      case AppIconButtonVariant.filled:
        backgroundColor = colors.surface;
        foregroundColor = colors.textPrimary;
        break;
      case AppIconButtonVariant.translucent:
        backgroundColor = Colors.black.withValues(alpha: 0.5);
        foregroundColor = Colors.white;
        break;
      case AppIconButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.textPrimary;
        break;
      case AppIconButtonVariant.danger:
        backgroundColor = colors.danger;
        foregroundColor = colors.raisedSurface;
        break;
    }

    if (onPressed == null) {
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveOnPressed,
          customBorder: const CircleBorder(),
          child: Container(
            constraints: BoxConstraints(
              minWidth: sizes.minTouchTarget,
              minHeight: sizes.minTouchTarget,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: foregroundColor,
              size: sizes.iconMedium,
            ),
          ),
        ),
      ),
    );
  }
}
