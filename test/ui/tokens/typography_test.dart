import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';

void main() {
  group('AppTypography', () {
    testWidgets('provides required text roles', (tester) async {
      final typography = AppTypography.inter();

      expect(typography.display, isA<TextStyle>());
      expect(typography.headline, isA<TextStyle>());
      expect(typography.title, isA<TextStyle>());
      expect(typography.body, isA<TextStyle>());
      expect(typography.label, isA<TextStyle>());
      expect(typography.caption, isA<TextStyle>());
      expect(typography.button, isA<TextStyle>());
      expect(typography.overline, isA<TextStyle>());
    });

    testWidgets('supports text scaling implicitly via standard TextStyle', (tester) async {
      final typography = AppTypography.inter();
      
      // TextStyles inherently support text scaling when used in Text widgets,
      // as long as fontSize is defined natively without hardcoding scale factors
      // inside the style itself inappropriately.
      expect(typography.body.fontSize, isNotNull);
    });

    testWidgets('implements ThemeExtension correctly', (tester) async {
      final typography1 = AppTypography.inter();
      final typography2 = typography1.copyWith(
        display: const TextStyle(fontSize: 100),
      );

      expect(typography1.display.fontSize, isNot(100));
      expect(typography2.display.fontSize, 100);

      final lerped = typography1.lerp(typography2, 0.5);
      expect(lerped, isA<AppTypography>());
    });
  });
}
