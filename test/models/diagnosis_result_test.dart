import 'package:flutter_test/flutter_test.dart';

import 'package:crop_check_up/models/diagnosis_result.dart';

void main() {
  DiagnosisResult createResult({
    String rawLabel = 'Tomato___Late_blight',
    double confidence = 0.95,
    String? symptoms,
    String? causes,
    String? management,
  }) {
    return DiagnosisResult(
      rawLabel: rawLabel,
      confidence: confidence,
      symptoms: symptoms,
      causes: causes,
      management: management,
    );
  }

  group('DiagnosisResult', () {
    group('label parsing', () {
      final cases = [
        (
          description: 'extracts crop name from standard label',
          raw: 'Tomato___Late_blight',
          crop: 'Tomato',
          disease: 'Late blight',
        ),
        (
          description: 'extracts crop name with parentheses',
          raw: 'Cherry_(including_sour)___Powdery_mildew',
          crop: 'Cherry (including sour)',
          disease: 'Powdery mildew',
        ),
        (
          description: 'extracts crop name with underscores replaced by spaces',
          raw: 'Corn_(maize)___Common_rust_',
          crop: 'Corn (maize)',
          disease: 'Common rust',
        ),
        (
          description: 'returns "Healthy" for healthy labels',
          raw: 'Tomato___healthy',
          crop: 'Tomato',
          disease: 'Healthy',
        ),
        (
          description: 'extracts complex disease names',
          raw: 'Grape___Esca_(Black_Measles)',
          crop: 'Grape',
          disease: 'Esca (Black Measles)',
        ),
        (
          description: 'handles labels with spaces in disease name',
          raw: 'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
          crop: 'Corn (maize)',
          disease: 'Cercospora leaf spot Gray leaf spot',
        ),
        (
          description: 'returns Unknown for malformed labels without separator',
          raw: 'SomePlant',
          crop: 'SomePlant',
          disease: 'Unknown',
        ),
      ];

      for (final tc in cases) {
        test(tc.description, () {
          final result = createResult(rawLabel: tc.raw);
          expect(result.cropName, tc.crop);
          expect(result.diseaseName, tc.disease);
        });
      }
    });

    group('displayLabel', () {
      final cases = [
        (
          description: 'combines crop and disease with em dash',
          raw: 'Apple___Apple_scab',
          expected: 'Apple — Apple scab',
        ),
        (
          description: 'shows Healthy for healthy plants',
          raw: 'Blueberry___healthy',
          expected: 'Blueberry — Healthy',
        ),
      ];

      for (final tc in cases) {
        test(tc.description, () {
          final result = createResult(rawLabel: tc.raw);
          expect(result.displayLabel, tc.expected);
        });
      }
    });

    group('isHealthy', () {
      final cases = [
        (
          description: 'returns true for healthy labels',
          raw: 'Peach___healthy',
          expected: true,
        ),
        (
          description: 'returns false for diseased labels',
          raw: 'Potato___Late_blight',
          expected: false,
        ),
        (
          description: 'is case-insensitive',
          raw: 'Grape___Healthy',
          expected: true,
        ),
      ];

      for (final tc in cases) {
        test(tc.description, () {
          final result = createResult(rawLabel: tc.raw);
          expect(result.isHealthy, tc.expected ? isTrue : isFalse);
        });
      }
    });

    group('confidence', () {
      final cases = [
        (
          description: 'returns correct percentage',
          confidence: 0.9432,
          expected: 94,
        ),
        (
          description: 'rounds correctly at boundary',
          confidence: 0.755,
          expected: 76,
        ),
        (
          description: 'handles 100% confidence',
          confidence: 1.0,
          expected: 100,
        ),
        (description: 'handles 0% confidence', confidence: 0.0, expected: 0),
      ];

      for (final tc in cases) {
        test(tc.description, () {
          final result = createResult(confidence: tc.confidence);
          expect(result.confidencePercent, tc.expected);
        });
      }
    });

    group('optional info fields', () {
      test('stores and returns symptoms, causes, and management', () {
        final result = createResult(
          rawLabel: 'Tomato___Late_blight',
          confidence: 0.95,
          symptoms: 'Brown spots on leaves',
          causes: 'Fungus',
          management: 'Use fungicide',
        );
        expect(result.symptoms, 'Brown spots on leaves');
        expect(result.causes, 'Fungus');
        expect(result.management, 'Use fungicide');
      });

      test('fields are null when not provided', () {
        final result = createResult(
          rawLabel: 'Tomato___Late_blight',
          confidence: 0.95,
        );
        expect(result.symptoms, isNull);
        expect(result.causes, isNull);
        expect(result.management, isNull);
      });
    });

    group('equality', () {
      test('equal for same label and confidence', () {
        final a = createResult(rawLabel: 'A___B', confidence: 0.5);
        final b = createResult(rawLabel: 'A___B', confidence: 0.5);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal for different labels', () {
        final a = createResult(rawLabel: 'A___B', confidence: 0.5);
        final b = createResult(rawLabel: 'A___C', confidence: 0.5);
        expect(a, isNot(equals(b)));
      });

      test('not equal for different confidence', () {
        final a = createResult(rawLabel: 'A___B', confidence: 0.5);
        final b = createResult(rawLabel: 'A___B', confidence: 0.6);
        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('contains display label and percentage', () {
        final result = createResult(
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
          final result = createResult(rawLabel: label, confidence: 0.9);
          expect(result.cropName, isNotEmpty);
          expect(result.diseaseName, isNotEmpty);
          expect(result.displayLabel, contains('—'));
          expect(result.confidencePercent, 90);
        });
      }
    });

    group('JSON serialization', () {
      test('toJson and fromJson round-trip with all fields', () {
        final original = createResult(
          rawLabel: 'Tomato___Late_blight',
          confidence: 0.95,
          symptoms: 'symptoms text',
          causes: 'causes text',
          management: 'management text',
        );

        final json = original.toJson();
        expect(json['rawLabel'], 'Tomato___Late_blight');
        expect(json['confidence'], 0.95);
        expect(json['symptoms'], 'symptoms text');
        expect(json['causes'], 'causes text');
        expect(json['management'], 'management text');

        final reconstructed = DiagnosisResult.fromJson(json);
        expect(reconstructed, equals(original));
        expect(reconstructed.cropName, 'Tomato');
        expect(reconstructed.diseaseName, 'Late blight');
        expect(reconstructed.displayLabel, 'Tomato — Late blight');
        expect(reconstructed.confidencePercent, 95);
      });

      test('toJson and fromJson round-trip with null optional fields', () {
        final original = createResult(
          rawLabel: 'Blueberry___healthy',
          confidence: 0.99,
        );

        final json = original.toJson();
        expect(json['rawLabel'], 'Blueberry___healthy');
        expect(json['confidence'], 0.99);
        expect(json['symptoms'], isNull);
        expect(json['causes'], isNull);
        expect(json['management'], isNull);

        final reconstructed = DiagnosisResult.fromJson(json);
        expect(reconstructed, equals(original));
      });
    });
  });
}
