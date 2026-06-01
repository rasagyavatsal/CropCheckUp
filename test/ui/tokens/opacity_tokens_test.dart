import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/opacity_tokens.dart';

void main() {
  group('OpacityTokens', () {
    test('defines tokens for disabled, overlay, scrim, and subdued states', () {
      expect(OpacityTokens.disabled, equals(0.38));
      expect(OpacityTokens.overlay, equals(0.12));
      expect(OpacityTokens.scrim, equals(0.50));
      expect(OpacityTokens.subdued, equals(0.60));
    });
  });
}
