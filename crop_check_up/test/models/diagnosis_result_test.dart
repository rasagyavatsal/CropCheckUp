import 'package:flutter_test/flutter_test.dart';

import 'package:crop_check_up/models/diagnosis_result.dart';

void main() {
  group('DiagnosisResult', () {
    group('label parsing', () {
      test('extracts crop name from standard label', () {
        const result = DiagnosisResult(
          rawLabel: 'Tomato___Late_blight',
          confidence: 0.95,
        );
        expect(result.cropName, 'Tomato');
      });

      test('extracts crop name with parentheses', () {
        const result = DiagnosisResult(
          rawLabel: 'Cherry_(including_sour)___Powdery_mildew',
          confidence: 0.88,
        );
        expect(result.cropName, 'Cherry (including sour)');
      });

      test('extracts crop name with underscores replaced by spaces', () {
        const result = DiagnosisResult(
          rawLabel: 'Corn_(maize)___Common_rust_',
          confidence: 0.90,
        );
        expect(result.cropName, 'Corn (maize)');
      });

      test('extracts disease name from standard label', () {
        const result = DiagnosisResult(
          rawLabel: 'Tomato___Late_blight',
          confidence: 0.95,
        );
        expect(result.diseaseName, 'Late blight');
      });

      test('returns "Healthy" for healthy labels', () {
        const result = DiagnosisResult(
          rawLabel: 'Tomato___healthy',
          confidence: 0.99,
        );
        expect(result.diseaseName, 'Healthy');
      });

      test('extracts complex disease names', () {
        const result = DiagnosisResult(
          rawLabel: 'Grape___Esca_(Black_Measles)',
          confidence: 0.76,
        );
        expect(result.diseaseName, 'Esca (Black Measles)');
      });

      test('handles labels with spaces in disease name', () {
        const result = DiagnosisResult(
          rawLabel: 'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
          confidence: 0.85,
        );
        expect(result.cropName, 'Corn (maize)');
        expect(result.diseaseName, 'Cercospora leaf spot Gray leaf spot');
      });

      test('returns Unknown for malformed labels without separator', () {
        const result = DiagnosisResult(
          rawLabel: 'SomePlant',
          confidence: 0.50,
        );
        expect(result.cropName, 'SomePlant');
        expect(result.diseaseName, 'Unknown');
      });
    });

    group('displayLabel', () {
      test('combines crop and disease with em dash', () {
        const result = DiagnosisResult(
          rawLabel: 'Apple___Apple_scab',
          confidence: 0.92,
        );
        expect(result.displayLabel, 'Apple — Apple scab');
      });

      test('shows Healthy for healthy plants', () {
        const result = DiagnosisResult(
          rawLabel: 'Blueberry___healthy',
          confidence: 0.97,
        );
        expect(result.displayLabel, 'Blueberry — Healthy');
      });
    });

    group('isHealthy', () {
      test('returns true for healthy labels', () {
        const result = DiagnosisResult(
          rawLabel: 'Peach___healthy',
          confidence: 0.95,
        );
        expect(result.isHealthy, isTrue);
      });

      test('returns false for diseased labels', () {
        const result = DiagnosisResult(
          rawLabel: 'Potato___Late_blight',
          confidence: 0.90,
        );
        expect(result.isHealthy, isFalse);
      });

      test('is case-insensitive', () {
        const result = DiagnosisResult(
          rawLabel: 'Grape___Healthy',
          confidence: 0.95,
        );
        expect(result.isHealthy, isTrue);
      });
    });

    group('confidence', () {
      test('returns correct percentage', () {
        const result = DiagnosisResult(
          rawLabel: 'Tomato___healthy',
          confidence: 0.9432,
        );
        expect(result.confidencePercent, 94);
      });

      test('rounds correctly at boundary', () {
        const result = DiagnosisResult(
          rawLabel: 'Tomato___healthy',
          confidence: 0.755,
        );
        expect(result.confidencePercent, 76);
      });

      test('handles 100% confidence', () {
        const result = DiagnosisResult(
          rawLabel: 'Apple___healthy',
          confidence: 1.0,
        );
        expect(result.confidencePercent, 100);
      });

      test('handles 0% confidence', () {
        const result = DiagnosisResult(
          rawLabel: 'Apple___healthy',
          confidence: 0.0,
        );
        expect(result.confidencePercent, 0);
      });
    });

    group('equality', () {
      test('equal for same label and confidence', () {
        const a = DiagnosisResult(rawLabel: 'A___B', confidence: 0.5);
        const b = DiagnosisResult(rawLabel: 'A___B', confidence: 0.5);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal for different labels', () {
        const a = DiagnosisResult(rawLabel: 'A___B', confidence: 0.5);
        const b = DiagnosisResult(rawLabel: 'A___C', confidence: 0.5);
        expect(a, isNot(equals(b)));
      });

      test('not equal for different confidence', () {
        const a = DiagnosisResult(rawLabel: 'A___B', confidence: 0.5);
        const b = DiagnosisResult(rawLabel: 'A___B', confidence: 0.6);
        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('contains display label and percentage', () {
        const result = DiagnosisResult(
          rawLabel: 'Strawberry___Leaf_scorch',
          confidence: 0.87,
        );
        expect(result.toString(), contains('Strawberry — Leaf scorch'));
        expect(result.toString(), contains('87%'));
      });
    });

    group('all 38 PlantVillage labels', () {
      // Validates that every label in labels.txt parses without errors.
      final labels = [
        'Apple___Apple_scab',
        'Apple___Black_rot',
        'Apple___Cedar_apple_rust',
        'Apple___healthy',
        'Blueberry___healthy',
        'Cherry_(including_sour)___Powdery_mildew',
        'Cherry_(including_sour)___healthy',
        'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
        'Corn_(maize)___Common_rust_',
        'Corn_(maize)___Northern_Leaf_Blight',
        'Corn_(maize)___healthy',
        'Grape___Black_rot',
        'Grape___Esca_(Black_Measles)',
        'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
        'Grape___healthy',
        'Orange___Haunglongbing_(Citrus_greening)',
        'Peach___Bacterial_spot',
        'Peach___healthy',
        'Pepper,_bell___Bacterial_spot',
        'Pepper,_bell___healthy',
        'Potato___Early_blight',
        'Potato___Late_blight',
        'Potato___healthy',
        'Raspberry___healthy',
        'Soybean___healthy',
        'Squash___Powdery_mildew',
        'Strawberry___Leaf_scorch',
        'Strawberry___healthy',
        'Tomato___Bacterial_spot',
        'Tomato___Early_blight',
        'Tomato___Late_blight',
        'Tomato___Leaf_Mold',
        'Tomato___Septoria_leaf_spot',
        'Tomato___Spider_mites Two-spotted_spider_mite',
        'Tomato___Target_Spot',
        'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
        'Tomato___Tomato_mosaic_virus',
        'Tomato___healthy',
      ];

      for (final label in labels) {
        test('parses "$label" without error', () {
          final result = DiagnosisResult(rawLabel: label, confidence: 0.9);
          expect(result.cropName, isNotEmpty);
          expect(result.diseaseName, isNotEmpty);
          expect(result.displayLabel, contains('—'));
          expect(result.confidencePercent, 90);
        });
      }
    });
  });
}
