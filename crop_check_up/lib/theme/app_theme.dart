import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';

/// Centralised design tokens for CropCheckUp.
///
/// Provides [lightTheme] and [darkTheme] built from a curated green/earth‑tone
/// palette suited for agriculture imagery.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Colour palette
  // ---------------------------------------------------------------------------

  static const Color seedGreen = Color(0xFF2E7D32);
  static const Color healthyGreen = Color(0xFF43A047);
  static const Color warningAmber = Color(0xFFFFA726);
  static const Color dangerRed = Color(0xFFE53935);

  static const Color _darkSurface = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);

  // ---------------------------------------------------------------------------
  // Themes
  // ---------------------------------------------------------------------------

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        SemanticColors.dark,
      ],
      colorScheme: ColorScheme.dark(
        primary: healthyGreen,
        secondary: warningAmber,
        error: dangerRed,
        surface: _darkSurface,
      ),
      scaffoldBackgroundColor: _darkSurface,
      cardColor: _darkCard,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: healthyGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
