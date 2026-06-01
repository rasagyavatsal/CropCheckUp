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
