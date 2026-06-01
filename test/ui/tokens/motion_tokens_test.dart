import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/tokens/motion_tokens.dart';

void main() {
  group('MotionTokens', () {
    test('provides duration roles', () {
      expect(MotionTokens.durationFast, isA<Duration>());
      expect(MotionTokens.durationNormal, isA<Duration>());
      expect(MotionTokens.durationSlow, isA<Duration>());
      expect(MotionTokens.durationButtonPress, isA<Duration>());
      expect(MotionTokens.durationLoadingTransition, isA<Duration>());
      expect(MotionTokens.durationPageTransition, isA<Duration>());
    });

    test('provides curve roles', () {
      expect(MotionTokens.curveStandard, isNotNull);
      expect(MotionTokens.curveEmphasized, isNotNull);
      expect(MotionTokens.curveDecelerate, isNotNull);
    });
  });
}
