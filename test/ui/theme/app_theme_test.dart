import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppTheme', () {
    testWidgets('provides light and dark Material 3 themes', (
      WidgetTester tester,
    ) async {
      final lightTheme = AppTheme.light;
      final darkTheme = AppTheme.dark;

      expect(lightTheme.useMaterial3, isTrue);
      expect(darkTheme.useMaterial3, isTrue);
    });

    testWidgets('light theme uses SemanticColors.light for colorScheme', (
      WidgetTester tester,
    ) async {
      final colorScheme = AppTheme.light.colorScheme;
      final tokens = SemanticColors.light;

      expect(colorScheme.primary, equals(tokens.brand));
      expect(colorScheme.surface, equals(tokens.surface));
      expect(colorScheme.error, equals(tokens.danger));
      expect(colorScheme.onPrimary, equals(tokens.raisedSurface));
      expect(colorScheme.onSurface, equals(tokens.textPrimary));
    });

    testWidgets('dark theme uses SemanticColors.dark for colorScheme', (
      WidgetTester tester,
    ) async {
      final colorScheme = AppTheme.dark.colorScheme;
      final tokens = SemanticColors.dark;

      expect(colorScheme.primary, equals(tokens.brand));
      expect(colorScheme.surface, equals(tokens.surface));
      expect(colorScheme.error, equals(tokens.danger));
      expect(colorScheme.onPrimary, equals(tokens.background));
      expect(colorScheme.onSurface, equals(tokens.textPrimary));
    });

    testWidgets('light theme defines TextTheme from AppTypography', (
      WidgetTester tester,
    ) async {
      final textTheme = AppTheme.light.textTheme;
      final expectedColor = SemanticColors.light.textPrimary;

      expect(textTheme.displayLarge?.color, equals(expectedColor));
      expect(textTheme.displayLarge?.fontSize, equals(34));
      expect(textTheme.bodyLarge?.color, equals(expectedColor));
      expect(textTheme.bodyLarge?.fontSize, equals(15));
    });

    testWidgets('dark theme defines TextTheme from AppTypography', (
      WidgetTester tester,
    ) async {
      final textTheme = AppTheme.dark.textTheme;
      final expectedColor = SemanticColors.dark.textPrimary;

      expect(textTheme.displayLarge?.color, equals(expectedColor));
      expect(textTheme.displayLarge?.fontSize, equals(34));
      expect(textTheme.bodyLarge?.color, equals(expectedColor));
      expect(textTheme.bodyLarge?.fontSize, equals(15));
    });

    testWidgets('themes are configured for components', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.light;

      expect(theme.appBarTheme.elevation, isNotNull);
      expect(theme.cardTheme.shape, isNotNull);
      expect(theme.elevatedButtonTheme.style, isNotNull);
      expect(theme.outlinedButtonTheme.style, isNotNull);
      expect(theme.textButtonTheme.style, isNotNull);
      expect(theme.snackBarTheme.behavior, equals(SnackBarBehavior.floating));
      expect(theme.bottomSheetTheme.shape, isNotNull);
      expect(theme.dialogTheme.shape, isNotNull);
      expect(theme.progressIndicatorTheme.color, isNotNull);
    });
  });
}
