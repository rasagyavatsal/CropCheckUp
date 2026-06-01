import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';

void main() {
  group('SemanticColors', () {
    test('provides light mode semantic colors', () {
      final colors = SemanticColors.light;
      expect(colors.brand, isA<Color>());
      expect(colors.background, isA<Color>());
      expect(colors.surface, isA<Color>());
      expect(colors.raisedSurface, isA<Color>());
      expect(colors.textPrimary, isA<Color>());
      expect(colors.textSecondary, isA<Color>());
      expect(colors.mutedText, isA<Color>());
      expect(colors.subtleBorder, isA<Color>());
      expect(colors.strongBorder, isA<Color>());
      expect(colors.success, isA<Color>());
      expect(colors.warning, isA<Color>());
      expect(colors.danger, isA<Color>());
      expect(colors.cameraScrim, isA<Color>());
      expect(colors.overlay, isA<Color>());
      expect(colors.disabled, isA<Color>());
    });

    test('provides dark mode semantic colors', () {
      final colors = SemanticColors.dark;
      expect(colors.brand, const Color(0xFF006C4C));
      expect(colors.background, isA<Color>());
      expect(colors.surface, isA<Color>());
      expect(colors.raisedSurface, isA<Color>());
      expect(colors.textPrimary, isA<Color>());
      expect(colors.textSecondary, isA<Color>());
      expect(colors.mutedText, isA<Color>());
      expect(colors.subtleBorder, isA<Color>());
      expect(colors.strongBorder, isA<Color>());
      expect(colors.success, const Color(0xFF006C4C));
      expect(colors.warning, isA<Color>());
      expect(colors.danger, isA<Color>());
      expect(colors.cameraScrim, isA<Color>());
      expect(colors.overlay, isA<Color>());
      expect(colors.disabled, isA<Color>());
    });

    test('ThemeExtension functionality', () {
      final colors = SemanticColors.light;
      
      // copyWith
      final copiedColors = colors.copyWith(brand: Colors.red);
      expect(copiedColors.brand, Colors.red);
      expect(copiedColors.background, colors.background); // Rest remains same
      
      // lerp
      final darkColors = SemanticColors.dark;
      final lerped = colors.lerp(darkColors, 0.5) as SemanticColors;
      expect(lerped.brand, Color.lerp(colors.brand, darkColors.brand, 0.5));
    });
  });
}
