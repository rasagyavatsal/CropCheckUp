class AppCopy {
  AppCopy._();

  static const HomeCopy home = HomeCopy();
  static const CameraCopy camera = CameraCopy();
  static const PreviewCopy preview = PreviewCopy();
  static const ResultCopy result = ResultCopy();
  static const FeedbackCopy feedback = FeedbackCopy();
}

class HomeCopy {
  const HomeCopy();

  String get initLoading => 'Warming up crop diagnosis models…';
  String get initErrorTitle => 'Failed to load diagnosis models';
  String get actionCameraTitle => 'Camera';
  String get actionCameraSubtitle => 'Take a photo of a leaf';
  String get actionUploadTitle => 'Upload';
  String get actionUploadSubtitle => 'From gallery';
  String get tipsTitle => 'Tips for Best Results';
  String get diagnoseTitle => 'Diagnose Plant';
  String get footerText => 'v1.0.0 • Powered by TensorFlow Lite';
  String get loadingOverlayTitle => 'Diagnosing plant health...';
  String get loadingOverlaySubtitle => 'Identifying patterns and diseases';
}

class CameraCopy {
  const CameraCopy();

  String get flashOn => 'Flash On';
  String get captureReady => 'Align leaf and tap to capture';
  String get captureFailed => 'Failed to capture frame, please try again.';
  String get diagnosisFailed => 'Could not confidently diagnose. Please try again.';
}

class PreviewCopy {
  const PreviewCopy();

  String get title => 'Confirm Specimen';
  String get instruction => 'Is the background removal correct? Ensure only the plant leaf is clearly visible.';
  String get actionRetry => 'Retry';
  String get actionConfirm => 'Confirm';
}

class ResultCopy {
  const ResultCopy();

  String get title => 'Diagnosis Result';
  String get statusHealthy => 'HEALTHY PLANT';
  String get statusDisease => 'DISEASE DETECTED';
  
  String get sectionStatus => 'Status';
  String get sectionSymptoms => 'Symptoms';
  String get sectionCauses => 'Causes';
  String get sectionManagement => 'Management & Treatment';
  String get sectionAbout => 'About';
  String get sectionHealthyTips => 'Maintenance Tips';
  String get actionDone => 'Done';

  String diagnosisConfidence(String cropName, String diseaseName, String confidence) {
    return '$diseaseName was detected on the $cropName leaf with $confidence% confidence. Early treatment is critical to prevent further spread.';
  }

  String healthyConfidence(String cropName, String confidence) {
    return 'The AI model determined this $cropName leaf is healthy with $confidence% confidence.';
  }
}

class FeedbackCopy {
  const FeedbackCopy();

  String get retry => 'Retry';
}
