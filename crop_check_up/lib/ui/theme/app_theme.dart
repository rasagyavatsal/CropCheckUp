import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';
import 'package:crop_check_up/ui/tokens/elevation_tokens.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/tokens/gradient_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return _buildTheme(
      brightness: Brightness.light,
      tokens: SemanticColors.light,
    );
  }

  static ThemeData get dark {
    return _buildTheme(
      brightness: Brightness.dark,
      tokens: SemanticColors.dark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required SemanticColors tokens,
  }) {
    final typography = AppTypography.inter(color: tokens.textPrimary);
    final onPrimaryColor = brightness == Brightness.light ? tokens.raisedSurface : tokens.background;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[
        tokens,
        typography,
        brightness == Brightness.light ? GradientTokens.light : GradientTokens.dark,
      ],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: tokens.brand,
        onPrimary: onPrimaryColor,
        secondary: tokens.warning,
        onSecondary: tokens.textPrimary,
        error: tokens.danger,
        onError: onPrimaryColor,
        surface: tokens.background,
        onSurface: tokens.textPrimary,
      ),
      scaffoldBackgroundColor: tokens.background,
      textTheme: TextTheme(
        displayLarge: typography.display,
        headlineLarge: typography.headline,
        titleLarge: typography.title,
        bodyLarge: typography.body,
        bodyMedium: typography.label,
        bodySmall: typography.caption,
        labelLarge: typography.button,
        labelSmall: typography.overline,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.textPrimary,
        elevation: ElevationTokens.none,
        centerTitle: true,
        titleTextStyle: typography.title,
      ),
      cardTheme: CardThemeData(
        color: tokens.raisedSurface,
        elevation: ElevationTokens.low,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.l),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.brand,
          foregroundColor: onPrimaryColor,
          elevation: ElevationTokens.low,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.xl),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l, vertical: SpacingTokens.m),
          textStyle: typography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.brand,
          side: BorderSide(color: tokens.strongBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.xl),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l, vertical: SpacingTokens.m),
          textStyle: typography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.brand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.xl),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.m, vertical: SpacingTokens.s),
          textStyle: typography.button,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.textPrimary,
        contentTextStyle: typography.body.copyWith(color: tokens.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.m),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.raisedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.xl),
        ),
        titleTextStyle: typography.title,
        contentTextStyle: typography.body,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.brand,
        linearTrackColor: tokens.subtleBorder,
        circularTrackColor: tokens.subtleBorder,
      ),
    );
  }
}
