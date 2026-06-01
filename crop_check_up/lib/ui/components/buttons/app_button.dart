import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/adaptive/app_adaptive.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/size_tokens.dart';

enum AppButtonVariant { primary, secondary, tonal, ghost, danger, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant _variant;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : _variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : _variant = AppButtonVariant.secondary;

  const AppButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : _variant = AppButtonVariant.tonal;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : _variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : _variant = AppButtonVariant.danger;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : _variant = AppButtonVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || onPressed == null)
        ? null
        : () {
            AppHaptics.primaryAction();
            onPressed!();
          };

    Widget child = Text(label);

    if (isLoading) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          child,
        ],
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          child,
        ],
      );
    }

    final colors = context.appColors;
    
    Widget button;
    switch (_variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(onPressed: effectiveOnPressed, child: child);
        break;
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.surface,
            foregroundColor: colors.textPrimary,
          ),
          child: child,
        );
        break;
      case AppButtonVariant.tonal:
        button = FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: colors.surface,
            foregroundColor: colors.brand,
          ),
          child: child,
        );
        break;
      case AppButtonVariant.danger:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.danger,
            foregroundColor: colors.raisedSurface,
          ),
          child: child,
        );
        break;
      case AppButtonVariant.ghost:
        button = TextButton(onPressed: effectiveOnPressed, child: child);
        break;
      case AppButtonVariant.outlined:
        button = OutlinedButton(onPressed: effectiveOnPressed, child: child);
        break;
    }

    return SizedBox(
      height: const SizeTokens().buttonHeight,
      width: isFullWidth ? double.infinity : null,
      child: button,
    );
  }
}
