import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/services/background_removal_service.dart';

void main() {
  group('BackgroundRemovalService', () {
    test('is singleton', () {
      final s1 = BackgroundRemovalService();
      final s2 = BackgroundRemovalService();
      expect(identical(s1, s2), isTrue);
    });

  });
}
