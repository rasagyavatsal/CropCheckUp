import 'package:flutter/material.dart';

class AppSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;

  const AppSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
  });

  const AppSafeArea.top({
    super.key,
    required this.child,
  })  : top = true,
        bottom = false;

  const AppSafeArea.bottom({
    super.key,
    required this.child,
  })  : top = false,
        bottom = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: false,
      right: false,
      child: child,
    );
  }
}
