import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';

void main() {
  group('RadiusTokens', () {
    test('defines a minimal set of radius tokens', () {
      expect(RadiusTokens.s, equals(4.0));
      expect(RadiusTokens.m, equals(8.0));
      expect(RadiusTokens.l, equals(16.0));
      expect(RadiusTokens.xl, equals(24.0));
      expect(RadiusTokens.pill, equals(999.0));
    });
  });
}
