import 'package:flutter/material.dart';

class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color brand;
  final Color brandSecondary;
  final Color background;
  final Color surface;
  final Color raisedSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color mutedText;
  final Color subtleBorder;
  final Color strongBorder;
  final Color success; // Healthy diagnosis
  final Color warning; // Uncertain states
  final Color danger; // Disease diagnosis
  final Color cameraScrim;
  final Color overlay;
  final Color disabled;

  const SemanticColors({
    required this.brand,
    required this.brandSecondary,
    required this.background,
    required this.surface,
    required this.raisedSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.mutedText,
    required this.subtleBorder,
    required this.strongBorder,
    required this.success,
    required this.warning,
    required this.danger,
    required this.cameraScrim,
    required this.overlay,
    required this.disabled,
  });

  @override
  SemanticColors copyWith({
    Color? brand,
    Color? brandSecondary,
    Color? background,
    Color? surface,
    Color? raisedSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? mutedText,
    Color? subtleBorder,
    Color? strongBorder,
    Color? success,
    Color? warning,
    Color? danger,
    Color? cameraScrim,
    Color? overlay,
    Color? disabled,
  }) {
    return SemanticColors(
      brand: brand ?? this.brand,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      raisedSurface: raisedSurface ?? this.raisedSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      mutedText: mutedText ?? this.mutedText,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      strongBorder: strongBorder ?? this.strongBorder,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      cameraScrim: cameraScrim ?? this.cameraScrim,
      overlay: overlay ?? this.overlay,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  ThemeExtension<SemanticColors> lerp(
    covariant ThemeExtension<SemanticColors>? other,
    double t,
  ) {
    if (other is! SemanticColors) {
      return this;
    }
    return SemanticColors(
      brand: Color.lerp(brand, other.brand, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raisedSurface: Color.lerp(raisedSurface, other.raisedSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      strongBorder: Color.lerp(strongBorder, other.strongBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      cameraScrim: Color.lerp(cameraScrim, other.cameraScrim, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
    );
  }

  static const SemanticColors light = SemanticColors(
    brand: Color(0xFF1F7A4D),
    brandSecondary: Color(0xFF0F5F8F),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F8F4),
    raisedSurface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF17201B),
    textSecondary: Color(0xFF40524A),
    mutedText: Color(0xFF6F7F76),
    subtleBorder: Color(0x1C17201B),
    strongBorder: Color(0x571F7A4D),
    success: Color(0xFF1F7A4D),
    warning: Color(0xFFB7791F),
    danger: Color(0xFFB42318),
    cameraScrim: Color(0xA6000000),
    overlay: Color(0x33000000),
    disabled: Color(0x5C17201B),
  );

  static const SemanticColors dark = SemanticColors(
    brand: Color(0xFF5BB07E),
    brandSecondary: Color(0xFF6DAED6),
    background: Color(0xFF000000),
    surface: Color(0xFF050505),
    raisedSurface: Color(0xFF0B0B0B),
    textPrimary: Color(0xFFF5FBF6),
    textSecondary: Color(0xFFC7D7CC),
    mutedText: Color(0xFF94AA9D),
    subtleBorder: Color(0x1FFFFFFF),
    strongBorder: Color(0x665BB07E),
    success: Color(0xFF5BB07E),
    warning: Color(0xFFE0A13E),
    danger: Color(0xFFFFB4AB),
    cameraScrim: Color(0xB0000000),
    overlay: Color(0x52000000),
    disabled: Color(0x61F5FBF6),
  );
}
