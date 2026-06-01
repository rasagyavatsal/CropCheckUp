import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/services/camera_session.dart';

void main() {
  group('CameraSession', () {
    test('exposes required lifecycle and properties API', () {
      final session = CameraSession();
      
      expect(session.isRunning, isFalse);
      expect(session.isFlashOn, isFalse);
      
      // We just verify the API signature exists in this test.
      // We can't fully run start() because it requires a physical camera plugin.
      expect(() => session.pause(), returnsNormally);
      
      // Check captureFrame returns null before started
      expect(session.captureFrame(), isNull);
    });
  });
}
