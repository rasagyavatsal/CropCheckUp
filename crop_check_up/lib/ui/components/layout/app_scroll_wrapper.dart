import 'package:flutter/material.dart';

/// A wrapper that provides consistent scrolling behavior across the app.
class AppScrollWrapper extends StatelessWidget {
  const AppScrollWrapper({
    super.key,
    required this.child,
    this.controller,
    this.physics,
  });

  final Widget child;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: physics ?? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: child,
    );
  }
}
