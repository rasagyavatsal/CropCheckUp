import 'package:flutter/material.dart';

class DiagnosisStatusTheme extends ThemeExtension<DiagnosisStatusTheme> {
  final Color healthyColor;
  final Color dangerColor;
  final Color warningColor;
  final Color neutralColor;

  const DiagnosisStatusTheme({
    required this.healthyColor,
    required this.dangerColor,
    required this.warningColor,
    required this.neutralColor,
  });

  @override
  DiagnosisStatusTheme copyWith({
    Color? healthyColor,
    Color? dangerColor,
    Color? warningColor,
    Color? neutralColor,
  }) {
    return DiagnosisStatusTheme(
      healthyColor: healthyColor ?? this.healthyColor,
      dangerColor: dangerColor ?? this.dangerColor,
      warningColor: warningColor ?? this.warningColor,
      neutralColor: neutralColor ?? this.neutralColor,
    );
  }

  @override
  ThemeExtension<DiagnosisStatusTheme> lerp(ThemeExtension<DiagnosisStatusTheme>? other, double t) {
    if (other is! DiagnosisStatusTheme) return this;
    return DiagnosisStatusTheme(
      healthyColor: Color.lerp(healthyColor, other.healthyColor, t)!,
      dangerColor: Color.lerp(dangerColor, other.dangerColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      neutralColor: Color.lerp(neutralColor, other.neutralColor, t)!,
    );
  }

  static DiagnosisStatusTheme light(Color success, Color danger, Color warning, Color neutral) => DiagnosisStatusTheme(
    healthyColor: success,
    dangerColor: danger,
    warningColor: warning,
    neutralColor: neutral,
  );

  static DiagnosisStatusTheme dark(Color success, Color danger, Color warning, Color neutral) => DiagnosisStatusTheme(
    healthyColor: success,
    dangerColor: danger,
    warningColor: warning,
    neutralColor: neutral,
  );
}
