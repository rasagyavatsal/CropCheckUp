import 'package:flutter/services.dart';

class AppHaptics {
  const AppHaptics._();

  static Future<void> primaryAction() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> confirmation() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> retry() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> warning() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }
}
