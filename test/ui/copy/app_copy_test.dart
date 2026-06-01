import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';

void main() {
  group('AppCopy', () {
    test('home strings are centralized and product-specific', () {
      expect(AppCopy.home.initLoading, equals('Warming up crop diagnosis models…'));
      expect(AppCopy.home.initErrorTitle, equals('Failed to load diagnosis models'));
      expect(AppCopy.home.actionCameraTitle, equals('Camera'));
      expect(AppCopy.home.actionCameraSubtitle, equals('Take a photo of a leaf'));
      expect(AppCopy.home.actionUploadTitle, equals('Upload'));
      expect(AppCopy.home.actionUploadSubtitle, equals('From gallery'));
      expect(AppCopy.home.tipsTitle, equals('Tips for Best Results'));
      expect(AppCopy.home.diagnoseTitle, equals('Diagnose Plant'));
      expect(AppCopy.home.footerText, equals('v1.0.0 • Powered by TensorFlow Lite'));
      expect(AppCopy.home.loadingOverlayTitle, equals('Diagnosing plant health...'));
      expect(AppCopy.home.loadingOverlaySubtitle, equals('Identifying patterns and diseases'));
    });

    test('camera strings are centralized', () {
      expect(AppCopy.camera.flashOn, equals('Flash On'));
      expect(AppCopy.camera.captureReady, equals('Align leaf and tap to capture'));
      expect(AppCopy.camera.captureFailed, equals('Failed to capture frame, please try again.'));
      expect(AppCopy.camera.diagnosisFailed, equals('Could not confidently diagnose. Please try again.'));
    });

    test('preview strings are centralized', () {
      expect(AppCopy.preview.title, equals('Confirm Specimen'));
      expect(AppCopy.preview.instruction, equals('Is the background removal correct? Ensure only the plant leaf is clearly visible.'));
      expect(AppCopy.preview.actionRetry, equals('Retry'));
      expect(AppCopy.preview.actionConfirm, equals('Confirm'));
    });

    test('result strings handle dynamic values correctly', () {
      expect(AppCopy.result.title, equals('Diagnosis Result'));
      expect(AppCopy.result.statusHealthy, equals('HEALTHY PLANT'));
      expect(AppCopy.result.statusDisease, equals('DISEASE DETECTED'));
      expect(AppCopy.result.sectionStatus, equals('Status'));
      expect(AppCopy.result.sectionSymptoms, equals('Symptoms'));
      expect(AppCopy.result.sectionCauses, equals('Causes'));
      expect(AppCopy.result.sectionManagement, equals('Management & Treatment'));
      expect(AppCopy.result.sectionAbout, equals('About'));
      expect(AppCopy.result.actionDone, equals('Done'));
      expect(
        AppCopy.result.diagnosisConfidence('Tomato', 'Tomato Early Blight', '98'),
        equals('Tomato Early Blight was detected on the Tomato leaf with 98% confidence. Early treatment is critical to prevent further spread.'),
      );
      expect(
        AppCopy.result.healthyConfidence('Tomato', '99'),
        equals('The AI model determined this Tomato leaf is healthy with 99% confidence.'),
      );
    });

    test('feedback/error strings are centralized', () {
      expect(AppCopy.feedback.retry, equals('Retry'));
    });
  });
}
