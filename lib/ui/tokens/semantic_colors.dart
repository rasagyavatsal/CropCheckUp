import 'package:flutter/material.dart';

class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color brand;
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
  final Color danger;  // Disease diagnosis
  final Color cameraScrim;
  final Color overlay;
  final Color disabled;

  const SemanticColors({
    required this.brand,
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
    brand: Color(0xFF006C4C), // agricultural green
    background: Color(0xFFFBFDF9),
    surface: Color(0xFFF0FDF4),
    raisedSurface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF191C1A),
    textSecondary: Color(0xFF404943),
    mutedText: Color(0xFF707973),
    subtleBorder: Color(0xFFE1E3DF),
    strongBorder: Color(0xFF707973),
    success: Color(0xFF006C4C),
    warning: Color(0xFF98690B),
    danger: Color(0xFFBA1A1A),
    cameraScrim: Color(0x99000000),
    overlay: Color(0x33000000),
    disabled: Color(0x61191C1A),
  );

  static const SemanticColors dark = SemanticColors(
    brand: Color(0xFF006C4C),
    background: Color(0xFF000000), // OLED pure black background
    surface: Color(0xFF121212),    // Very dark gray surface
    raisedSurface: Color(0xFF1E1E1E), // Slightly lighter gray for cards/elevated layers
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFC0C0C0),
    mutedText: Color(0xFF7A7A7A),
    subtleBorder: Color(0xFF282828),
    strongBorder: Color(0xFF505050),
    success: Color(0xFF006C4C),
    warning: Color(0xFFFFB300),
    danger: Color(0xFFFFB4AB),
    cameraScrim: Color(0x99000000),
    overlay: Color(0x33000000),
    disabled: Color(0x61F5F5F5),
  );
}
