import 'package:flutter/material.dart';

class AppRoute {
  static PageRoute<T> standard<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return MaterialPageRoute<T>(
      builder: builder,
      settings: settings,
    );
  }

  static PageRoute<T> dialog<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return MaterialPageRoute<T>(
      builder: builder,
      settings: settings,
      fullscreenDialog: true,
    );
  }
}
