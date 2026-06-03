import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic typography tokens for the application.
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle overline;

  const AppTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.label,
    required this.caption,
    required this.button,
    required this.overline,
  });

  /// Factory constructor preserving the public API while matching the brand
  /// type pairing used by the landing page.
  factory AppTypography.inter({Color color = Colors.white}) {
    return AppTypography(
      display: GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.05,
        letterSpacing: 0,
      ),
      headline: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.15,
        letterSpacing: 0,
      ),
      title: GoogleFonts.outfit(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
        letterSpacing: 0,
      ),
      body: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.48,
        letterSpacing: 0,
      ),
      label: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.35,
        letterSpacing: 0,
      ),
      caption: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color.withValues(alpha: 0.7),
        height: 1.35,
        letterSpacing: 0,
      ),
      button: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
        letterSpacing: 0,
      ),
      overline: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color.withValues(alpha: 0.6),
        height: 1.3,
        letterSpacing: 0,
      ),
    );
  }

  @override
  AppTypography copyWith({
    TextStyle? display,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? overline,
  }) {
    return AppTypography(
      display: display ?? this.display,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      body: body ?? this.body,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      button: button ?? this.button,
      overline: overline ?? this.overline,
    );
  }

  @override
  AppTypography lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
    );
  }
}

extension AppTypographyExtension on BuildContext {
  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;
}
