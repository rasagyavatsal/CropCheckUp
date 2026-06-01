import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/elevation_tokens.dart';

void main() {
  group('ElevationTokens', () {
    test('defines a minimal set of elevation tokens', () {
      expect(ElevationTokens.none, equals(0.0));
      expect(ElevationTokens.low, equals(2.0));
      expect(ElevationTokens.medium, equals(4.0));
      expect(ElevationTokens.high, equals(8.0));
    });
  });
}
