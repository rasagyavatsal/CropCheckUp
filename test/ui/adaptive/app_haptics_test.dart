import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/adaptive/app_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const vibrateMethod = 'HapticFeedback.vibrate';

  group('AppHaptics', () {
    late List<MethodCall> log;

    setUp(() {
      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('primaryAction triggers lightImpact', () async {
      await AppHaptics.primaryAction();
      expect(log, hasLength(1));
      expect(log.single.method, vibrateMethod);
      expect(log.single.arguments, 'HapticFeedbackType.lightImpact');
    });

    test('confirmation triggers mediumImpact', () async {
      await AppHaptics.confirmation();
      expect(log, hasLength(1));
      expect(log.single.method, vibrateMethod);
      expect(log.single.arguments, 'HapticFeedbackType.mediumImpact');
    });

    test('warning triggers heavyImpact', () async {
      await AppHaptics.warning();
      expect(log, hasLength(1));
      expect(log.single.method, vibrateMethod);
      expect(log.single.arguments, 'HapticFeedbackType.heavyImpact');
    });

    test('error triggers heavyImpact', () async {
      await AppHaptics.error();
      expect(log, hasLength(1));
      expect(log.single.method, vibrateMethod);
      expect(log.single.arguments, 'HapticFeedbackType.heavyImpact');
    });
    
    test('retry triggers mediumImpact', () async {
      await AppHaptics.retry();
      expect(log, hasLength(1));
      expect(log.single.method, vibrateMethod);
      expect(log.single.arguments, 'HapticFeedbackType.mediumImpact');
    });
  });
}
