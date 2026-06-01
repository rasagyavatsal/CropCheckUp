import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';

void main() {
  group('SpacingTokens', () {
    test('defines a minimal set of spacing tokens', () {
      const spacing = SpacingTokens();
      expect(spacing.xs, equals(4.0));
      expect(spacing.s, equals(8.0));
      expect(spacing.m, equals(16.0));
      expect(spacing.l, equals(24.0));
      expect(spacing.xl, equals(32.0));
    });
  });
}
