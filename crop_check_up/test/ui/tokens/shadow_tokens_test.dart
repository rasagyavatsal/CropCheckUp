import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/shadow_tokens.dart';

void main() {
  group('ShadowTokens', () {
    test('defines box shadows', () {
      expect(ShadowTokens.low, isA<List<BoxShadow>>());
      expect(ShadowTokens.medium, isA<List<BoxShadow>>());
      expect(ShadowTokens.high, isA<List<BoxShadow>>());
    });
  });
}
