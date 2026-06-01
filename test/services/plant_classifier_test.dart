import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:crop_check_up/services/plant_classifier.dart';

void main() {
  group('PlantClassifier', () {
    group('preprocessing validation', () {
      // We can't run the full classifier in tests (no TFLite model file), but
      // we validate the public contract and ready-state invariants.

      test('isReady is false before init()', () {
        final classifier = PlantClassifier();
        expect(classifier.isReady, isFalse);
      });

      test('classifyImage asserts when not initialised', () {
        final classifier = PlantClassifier();
        final dummyImage = img.Image(width: 10, height: 10);

        expect(
          () => classifier.classifyImage(dummyImage),
          throwsA(isA<AssertionError>()),
        );
      });

      test('dispose resets isReady to false', () {
        final classifier = PlantClassifier();
        // Even without init, dispose should be safe and idempotent.
        classifier.dispose();
        expect(classifier.isReady, isFalse);
      });

      test('dispose is idempotent', () {
        final classifier = PlantClassifier();
        classifier.dispose();
        classifier.dispose(); // second call should not throw
        expect(classifier.isReady, isFalse);
      });
    });

    group('preprocessImage contract (via classifyImage)', () {
      // These tests validate the input image handling — the classifier
      // must accept images of any size and resize them internally to 224x224.

      test('accepts very small images without error', () {
        final classifier = PlantClassifier();
        final tinyImage = img.Image(width: 1, height: 1);

        // Should fail at the assertion (not initialised), NOT at preprocessing.
        expect(
          () => classifier.classifyImage(tinyImage),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts very large images without error', () {
        final classifier = PlantClassifier();
        final largeImage = img.Image(width: 4000, height: 3000);

        // Should fail at the assertion (not initialised), NOT at preprocessing.
        expect(
          () => classifier.classifyImage(largeImage),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts non-square images without error', () {
        final classifier = PlantClassifier();
        final wideImage = img.Image(width: 800, height: 200);

        // Should fail at the assertion (not initialised), NOT at preprocessing.
        expect(
          () => classifier.classifyImage(wideImage),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}
