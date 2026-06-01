import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/size_tokens.dart';

void main() {
  group('SizeTokens', () {
    test('defines required size tokens', () {
      const sizes = SizeTokens();
      expect(sizes.iconSmall, equals(16.0));
      expect(sizes.iconMedium, equals(24.0));
      expect(sizes.iconLarge, equals(32.0));
      
      // Minimum touch target size is defined
      expect(sizes.minTouchTarget, equals(48.0));
      
      expect(sizes.buttonHeight, equals(48.0));
      expect(sizes.cardPadding, equals(16.0));
      
      // Camera specific
      expect(sizes.cameraCaptureSize, equals(72.0));
      expect(sizes.cameraOverlaySizing, equals(250.0));
      
      // Result specific
      expect(sizes.imagePreviewSize, equals(200.0));
    });
  });
}
