import 'package:flutter_test/flutter_test.dart';

import 'package:crop_check_up/services/plant_classifier.dart';

void main() {
  group('Service Boundaries (Issue #32)', () {
    test('PlantClassifier constants must not be changed during UI rewrite', () {
      // 1. No model asset paths are changed by UI work.
      expect(PlantClassifier.modelAssetPath, 'assets/plant_disease_model.tflite',
          reason: 'Model asset path is a hard service boundary');
      expect(PlantClassifier.labelsAssetPath, 'assets/labels.txt',
          reason: 'Labels asset path is a hard service boundary');
      expect(PlantClassifier.diseaseInfoAssetPath, 'assets/disease_info.json',
          reason: 'Disease info asset path is a hard service boundary');

      // 2. No classifier input size or confidence behavior is changed by UI work.
      expect(PlantClassifier.modelInputSize, 224,
          reason: 'Model input size must remain 224x224');
      expect(PlantClassifier.minimumConfidence, 0.0,
          reason: 'Minimum confidence threshold must remain 0.0');
    });
  });
}
