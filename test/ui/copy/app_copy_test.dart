import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';

void main() {
  group('AppCopy', () {
    test('home strings are centralized and product-specific', () {
      expect(
        AppCopy.home.initLoading,
        equals('Warming up crop diagnosis models…'),
      );
      expect(
        AppCopy.home.initErrorTitle,
        equals('Failed to load diagnosis models'),
      );
      expect(AppCopy.home.actionCameraTitle, equals('Scan with Camera'));
      expect(AppCopy.home.actionCameraSubtitle, equals('Live leaf capture'));
      expect(AppCopy.home.actionUploadTitle, equals('Choose from Gallery'));
      expect(
        AppCopy.home.actionUploadSubtitle,
        equals('Analyze an existing image'),
      );
      expect(AppCopy.home.tipsTitle, equals('Capture Checklist'));
      expect(AppCopy.home.diagnoseTitle, equals('Leaf Diagnostics'));
      expect(
        AppCopy.home.footerText,
        equals('68 labels • 224 x 224 input • TensorFlow Lite'),
      );
      expect(
        AppCopy.home.loadingOverlayTitle,
        equals('Diagnosing plant health...'),
      );
      expect(
        AppCopy.home.loadingOverlaySubtitle,
        equals('Identifying patterns and diseases'),
      );
    });

    test('camera strings are centralized', () {
      expect(AppCopy.camera.flashOn, equals('Flash On'));
      expect(
        AppCopy.camera.captureReady,
        equals('Frame one leaf for diagnosis'),
      );
      expect(
        AppCopy.camera.captureFailed,
        equals('Failed to capture frame, please try again.'),
      );
      expect(
        AppCopy.camera.diagnosisFailed,
        equals('Could not confidently diagnose. Please try again.'),
      );
    });

    test('preview strings are centralized', () {
      expect(AppCopy.preview.title, equals('Confirm Specimen'));
      expect(
        AppCopy.preview.instruction,
        equals(
          'Check that the isolated leaf is clear before running inference.',
        ),
      );
      expect(AppCopy.preview.actionRetry, equals('Retry'));
      expect(AppCopy.preview.actionConfirm, equals('Confirm'));
    });

    test('result strings handle dynamic values correctly', () {
      expect(AppCopy.result.title, equals('Diagnosis Report'));
      expect(AppCopy.result.statusHealthy, equals('HEALTHY PLANT'));
      expect(AppCopy.result.statusDisease, equals('DISEASE DETECTED'));
      expect(AppCopy.result.sectionStatus, equals('Status'));
      expect(AppCopy.result.sectionSymptoms, equals('Symptoms'));
      expect(AppCopy.result.sectionCauses, equals('Causes'));
      expect(
        AppCopy.result.sectionManagement,
        equals('Management & Treatment'),
      );
      expect(AppCopy.result.sectionAbout, equals('About'));
      expect(AppCopy.result.actionDone, equals('Done'));
      expect(
        AppCopy.result.diagnosisConfidence(
          'Tomato',
          'Tomato Early Blight',
          '98',
        ),
        equals(
          'Tomato Early Blight was detected on the Tomato leaf with 98% confidence. Use this as triage and inspect the plant before treatment.',
        ),
      );
      expect(
        AppCopy.result.healthyConfidence('Tomato', '99'),
        equals(
          'The model classified this Tomato leaf as healthy with 99% confidence. Keep monitoring new growth and changing spots.',
        ),
      );
    });

    test('feedback/error strings are centralized', () {
      expect(AppCopy.feedback.retry, equals('Retry'));
    });
  });
}
