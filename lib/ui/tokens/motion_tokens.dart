import 'package:flutter/animation.dart';

class MotionTokens {
  MotionTokens._();

  // Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  
  static const Duration durationButtonPress = Duration(milliseconds: 100);
  static const Duration durationLoadingTransition = Duration(milliseconds: 400);
  static const Duration durationPageTransition = Duration(milliseconds: 300);

  // Curves
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.easeOut;
}
