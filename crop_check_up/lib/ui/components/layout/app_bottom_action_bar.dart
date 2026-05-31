import 'package:flutter/material.dart';
import 'app_safe_area.dart';

/// A bottom action bar component that avoids OS navigation bars and provides
/// consistent spacing around action buttons.
class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0), // Defaults to SpacingTokens().m
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      top: false,
      left: true,
      right: true,
      bottom: true,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
