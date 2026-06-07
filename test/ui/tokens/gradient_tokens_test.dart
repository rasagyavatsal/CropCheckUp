import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/gradient_tokens.dart';

void main() {
  group('GradientTokens', () {
    test('brandHeader creates correct gradient', () {
      const gradient = GradientTokens.light;

      expect(gradient.brandHeader, isA<LinearGradient>());
      expect(gradient.brandHeader.colors.length, 2);
    });

    test('dark gradients use black background tones', () {
      const gradient = GradientTokens.dark;

      expect(gradient.brandHeader.colors, [
        Colors.black,
        const Color(0xFF050505),
      ]);
      expect(gradient.previewBackdrop.colors, [
        Colors.black,
        const Color(0xFF050505),
        Colors.black,
      ]);
    });

    test('lerp works correctly', () {
      const start = GradientTokens.light;
      const end = GradientTokens.dark;

      final lerped = start.lerp(end, 0.5);
      expect(lerped, isA<GradientTokens>());
    });

    test('copyWith works correctly', () {
      const tokens = GradientTokens.light;
      final copied = tokens.copyWith();
      expect(copied.brandHeader, tokens.brandHeader);
    });
  });
}
