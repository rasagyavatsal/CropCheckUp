import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/components/layout/app_scroll_wrapper.dart';

/// A shared page shell component that provides a consistent [Scaffold] layout.
class AppPageShell extends StatelessWidget {
  const AppPageShell({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.applySafeArea = true,
  })  : _isScrollable = false,
        slivers = null;

  const AppPageShell.scrollable({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.applySafeArea = true,
  })  : _isScrollable = true,
        slivers = null;

  const AppPageShell.sliver({
    super.key,
    required this.slivers,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.applySafeArea = true,
  })  : _isScrollable = false,
        child = null,
        appBar = null;

  final Widget? child;
  final List<Widget>? slivers;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool applySafeArea;
  final bool _isScrollable;

  @override
  Widget build(BuildContext context) {
    Widget content;
    
    if (slivers != null) {
      content = CustomScrollView(
        slivers: slivers!,
      );
    } else {
      content = child!;
      if (_isScrollable) {
        content = AppScrollWrapper(child: content);
      }
    }

    if (applySafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
