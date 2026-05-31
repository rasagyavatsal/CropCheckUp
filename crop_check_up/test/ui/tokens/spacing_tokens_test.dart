import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';

void main() {
  group('SpacingTokens', () {
    test('defines a minimal set of spacing tokens', () {
      expect(SpacingTokens.xs, equals(4.0));
      expect(SpacingTokens.s, equals(8.0));
      expect(SpacingTokens.m, equals(16.0));
      expect(SpacingTokens.l, equals(24.0));
      expect(SpacingTokens.xl, equals(32.0));
    });
  });
}
