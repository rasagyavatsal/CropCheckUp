import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';

void main() {
  group('RadiusTokens', () {
    test('defines a minimal set of radius tokens', () {
      const radius = RadiusTokens();
      expect(radius.s, equals(4.0));
      expect(radius.m, equals(8.0));
      expect(radius.l, equals(16.0));
      expect(radius.xl, equals(24.0));
      expect(radius.pill, equals(999.0));
    });
  });
}
