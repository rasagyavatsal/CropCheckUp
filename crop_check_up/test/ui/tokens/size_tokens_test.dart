import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/size_tokens.dart';

void main() {
  group('SizeTokens', () {
    test('defines required size tokens', () {
      expect(SizeTokens.iconSmall, equals(16.0));
      expect(SizeTokens.iconMedium, equals(24.0));
      expect(SizeTokens.iconLarge, equals(32.0));
      
      // Minimum touch target size is defined
      expect(SizeTokens.minTouchTarget, equals(48.0));
      
      expect(SizeTokens.buttonHeight, equals(48.0));
      expect(SizeTokens.cardPadding, equals(16.0));
      
      // Camera specific
      expect(SizeTokens.cameraCaptureSize, equals(72.0));
      expect(SizeTokens.cameraOverlaySizing, equals(250.0));
      
      // Result specific
      expect(SizeTokens.imagePreviewSize, equals(200.0));
    });
  });
}
