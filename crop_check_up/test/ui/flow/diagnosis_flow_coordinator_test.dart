import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:crop_check_up/ui/flow/diagnosis_flow_coordinator.dart';
import 'package:crop_check_up/services/background_removal_service.dart';
import 'package:crop_check_up/services/plant_classifier.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';
import 'package:crop_check_up/ui/app_design_system.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';

class MockImagePicker extends Mock implements ImagePicker {}
class MockBackgroundRemovalService extends Mock implements BackgroundRemovalService {}
class MockPlantClassifier extends Mock implements PlantClassifier {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockBackgroundRemovalService mockBgRemover;
  late MockPlantClassifier mockClassifier;
  late DiagnosisFlowCoordinator coordinator;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(img.Image(width: 1, height: 1));
  });

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockBgRemover = MockBackgroundRemovalService();
    mockClassifier = MockPlantClassifier();

    coordinator = DiagnosisFlowCoordinator(
      imagePicker: mockImagePicker,
      bgRemover: mockBgRemover,
      classifier: mockClassifier,
    );
  });

  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => child,
        ),
      ),
    );
  }

  group('DiagnosisFlowCoordinator', () {
    testWidgets('startGalleryDiagnosis returns cancelled if no image picked', (tester) async {
      when(() => mockImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024))
          .thenAnswer((_) async => null);
      
      DiagnosisOutcome? result;
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await coordinator.startGalleryDiagnosis(context);
              },
              child: const Text('Start'),
            );
          }
        )
      ));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(result, DiagnosisOutcome.cancelled);
    });

    testWidgets('startGalleryDiagnosis returns failed if background removal fails', (tester) async {
      when(() => mockImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024))
          .thenAnswer((_) async => XFile.fromData(Uint8List(0)));
          
      when(() => mockBgRemover.processImageBytes(any()))
          .thenAnswer((_) async => null);
      
      DiagnosisOutcome? result;
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await coordinator.startGalleryDiagnosis(context);
              },
              child: const Text('Start'),
            );
          }
        )
      ));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(result, DiagnosisOutcome.failed);
      expect(find.text(AppCopy.camera.diagnosisFailed), findsOneWidget);
    });

    testWidgets('startGalleryDiagnosis returns cancelled if user retries preview', (tester) async {
      when(() => mockImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024))
          .thenAnswer((_) async => XFile.fromData(Uint8List(0)));
          
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      when(() => mockBgRemover.processImageBytes(any()))
          .thenAnswer((_) async => ProcessedImage(dummyImg, dummyBytes));

      when(() => mockClassifier.resizeForModel(any()))
          .thenAnswer((_) async => (dummyImg, dummyBytes));
      
      DiagnosisOutcome? result;
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await coordinator.startGalleryDiagnosis(context);
              },
              child: const Text('Start'),
            );
          }
        )
      ));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // show preview dialog
      
      expect(find.text(AppCopy.preview.title), findsOneWidget);
      await tester.tap(find.text(AppCopy.preview.actionRetry));
      await tester.pumpAndSettle(); // close dialog
      
      expect(result, DiagnosisOutcome.cancelled);
    });

    testWidgets('startGalleryDiagnosis returns success on confirm and valid classification', (tester) async {
      when(() => mockImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024))
          .thenAnswer((_) async => XFile.fromData(Uint8List(0)));
          
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      when(() => mockBgRemover.processImageBytes(any()))
          .thenAnswer((_) async => ProcessedImage(dummyImg, dummyBytes));

      when(() => mockClassifier.resizeForModel(any()))
          .thenAnswer((_) async => (dummyImg, dummyBytes));

      when(() => mockClassifier.classifyImage(any()))
          .thenReturn(DiagnosisResult(rawLabel: 'Healthy', confidence: 0.99));
      
      DiagnosisOutcome? result;
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await coordinator.startGalleryDiagnosis(context);
              },
              child: const Text('Start'),
            );
          }
        )
      ));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // show preview dialog
      
      await tester.tap(find.text(AppCopy.preview.actionConfirm));
      await tester.pumpAndSettle(); // push to ResultScreen
      
      expect(result, DiagnosisOutcome.success);
      expect(find.text(AppCopy.result.title), findsOneWidget);
    });

    testWidgets('startCameraDiagnosis returns success on confirm', (tester) async {
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      when(() => mockBgRemover.processImageObj(any()))
          .thenAnswer((_) async => ProcessedImage(dummyImg, dummyBytes));

      when(() => mockClassifier.resizeForModel(any()))
          .thenAnswer((_) async => (dummyImg, dummyBytes));

      when(() => mockClassifier.classifyImage(any()))
          .thenReturn(DiagnosisResult(rawLabel: 'Healthy', confidence: 0.99));
      
      DiagnosisOutcome? result;
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await coordinator.startCameraDiagnosis(context, dummyImg);
              },
              child: const Text('Start'),
            );
          }
        )
      ));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text(AppCopy.preview.actionConfirm));
      await tester.pumpAndSettle();
      
      expect(result, DiagnosisOutcome.success);
    });
  });
}
