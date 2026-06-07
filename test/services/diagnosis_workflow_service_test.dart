import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image/image.dart' as img;

import 'package:crop_check_up/services/diagnosis_workflow_service.dart';
import 'package:crop_check_up/services/background_removal_service.dart';
import 'package:crop_check_up/services/plant_classifier.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';

class MockBackgroundRemovalService extends Mock implements BackgroundRemovalService {}
class MockPlantClassifier extends Mock implements PlantClassifier {}

void main() {
  late MockBackgroundRemovalService mockBgRemover;
  late MockPlantClassifier mockClassifier;
  late DiagnosisWorkflowService service;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(img.Image(width: 1, height: 1));
  });

  setUp(() {
    mockBgRemover = MockBackgroundRemovalService();
    mockClassifier = MockPlantClassifier();

    service = DiagnosisWorkflowService(
      bgRemover: mockBgRemover,
      classifier: mockClassifier,
    );
  });

  group('DiagnosisWorkflowService', () {
    test('initialises underlying services', () async {
      when(() => mockBgRemover.init()).thenAnswer((_) async {});
      when(() => mockClassifier.init()).thenAnswer((_) async {});

      await service.init();
      
      expect(service.isInitialised, true);
      verify(() => mockBgRemover.init()).called(1);
      verify(() => mockClassifier.init()).called(1);
    });

    test('processImageBytes returns success result', () async {
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List(0);
      
      when(() => mockBgRemover.processImageBytes(any()))
          .thenAnswer((_) async => ProcessedImage(dummyImg, dummyBytes));
      when(() => mockClassifier.resizeForModel(any()))
          .thenAnswer((_) async => (dummyImg, dummyBytes));

      final result = await service.processImageBytes(dummyBytes);

      expect(result.isSuccess, true);
      expect(result.resizedImage, dummyImg);
      expect(result.resizedBytes, dummyBytes);
    });

    test('processImageBytes returns failure when background removal fails', () async {
      when(() => mockBgRemover.processImageBytes(any()))
          .thenAnswer((_) async => null);

      final result = await service.processImageBytes(Uint8List(0));

      expect(result.isSuccess, false);
      expect(result.error, isNotNull);
    });
    
    test('processImageObj returns success result', () async {
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List(0);
      
      when(() => mockBgRemover.processImageObj(any()))
          .thenAnswer((_) async => ProcessedImage(dummyImg, dummyBytes));
      when(() => mockClassifier.resizeForModel(any()))
          .thenAnswer((_) async => (dummyImg, dummyBytes));

      final result = await service.processImageObj(dummyImg);

      expect(result.isSuccess, true);
      expect(result.resizedImage, dummyImg);
      expect(result.resizedBytes, dummyBytes);
    });

    test('classifyImage returns correct diagnosis', () {
      final dummyImg = img.Image(width: 1, height: 1);
      const expectedResult = DiagnosisResult(rawLabel: 'Healthy', confidence: 0.99);
      
      when(() => mockClassifier.classifyImage(any())).thenReturn(expectedResult);

      final result = service.classifyImage(dummyImg);

      expect(result, expectedResult);
    });
  });
}
