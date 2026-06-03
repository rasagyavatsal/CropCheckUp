class AppCopy {
  AppCopy._();

  static const SharedCopy shared = SharedCopy();
  static const HomeCopy home = HomeCopy();
  static const CameraCopy camera = CameraCopy();
  static const PreviewCopy preview = PreviewCopy();
  static const ResultCopy result = ResultCopy();
  static const FeedbackCopy feedback = FeedbackCopy();
}

class SharedCopy {
  const SharedCopy();

  String get backAction => 'Back';
  String get closeAction => 'Close';
}

class HomeCopy {
  const HomeCopy();

  String get initLoading => 'Warming up crop diagnosis models…';
  String get initErrorTitle => 'Failed to load diagnosis models';
  String get actionCameraTitle => 'Scan with Camera';
  String get actionCameraSubtitle => 'Live leaf capture';
  String get actionUploadTitle => 'Choose from Gallery';
  String get actionUploadSubtitle => 'Analyze an existing image';
  String get tipsTitle => 'Capture Checklist';
  String get diagnoseTitle => 'Leaf Diagnostics';
  String get footerText => '68 labels • 224 x 224 input • TensorFlow Lite';
  String get loadingOverlayTitle => 'Diagnosing plant health...';
  String get loadingOverlaySubtitle => 'Identifying patterns and diseases';

  // Semantics
  String get semanticScanAction => 'Scan plant using camera';
  String get semanticUploadAction => 'Upload image from gallery';
}

class CameraCopy {
  const CameraCopy();

  String get flashOn => 'Flash On';
  String get captureReady => 'Frame one leaf for diagnosis';
  String get captureFailed => 'Failed to capture frame, please try again.';
  String get diagnosisFailed =>
      'Could not confidently diagnose. Please try again.';

  // Semantics
  String get semanticCaptureAction => 'Capture photo';
  String get semanticFlashOn => 'Turn flash on';
  String get semanticFlashOff => 'Turn flash off';
}

class PreviewCopy {
  const PreviewCopy();

  String get title => 'Confirm Specimen';
  String get instruction =>
      'Check that the isolated leaf is clear before running inference.';
  String get actionRetry => 'Retry';
  String get actionConfirm => 'Confirm';

  // Semantics
  String get semanticPreviewImage => 'Segmented plant leaf preview';
}

class ResultCopy {
  const ResultCopy();

  String get title => 'Diagnosis Report';
  String get statusHealthy => 'HEALTHY PLANT';
  String get statusDisease => 'DISEASE DETECTED';

  String get sectionStatus => 'Status';
  String get sectionSymptoms => 'Symptoms';
  String get sectionCauses => 'Causes';
  String get sectionManagement => 'Management & Treatment';
  String get sectionAbout => 'About';
  String get sectionHealthyTips => 'Maintenance Tips';
  String get actionDone => 'Done';

  String diagnosisConfidence(
    String cropName,
    String diseaseName,
    String confidence,
  ) {
    return '$diseaseName was detected on the $cropName leaf with $confidence% confidence. Use this as triage and inspect the plant before treatment.';
  }

  String healthyConfidence(String cropName, String confidence) {
    return 'The model classified this $cropName leaf as healthy with $confidence% confidence. Keep monitoring new growth and changing spots.';
  }

  // Semantics
  String get semanticEvidenceImage => 'Image used for diagnosis';
}

class FeedbackCopy {
  const FeedbackCopy();

  String get retry => 'Retry';
}
