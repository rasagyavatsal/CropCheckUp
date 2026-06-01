import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/border_tokens.dart';

void main() {
  group('BorderTokens', () {
    test('defines a minimal set of border tokens', () {
      expect(BorderTokens.thin, equals(1.0));
      expect(BorderTokens.medium, equals(2.0));
      expect(BorderTokens.thick, equals(4.0));
    });
  });
}
