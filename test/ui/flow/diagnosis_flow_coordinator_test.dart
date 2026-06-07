import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:crop_check_up/ui/flow/diagnosis_flow_coordinator.dart';
import 'package:crop_check_up/services/diagnosis_workflow_service.dart';
import 'package:crop_check_up/services/diagnosis_history_repository.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';
import 'package:crop_check_up/ui/app_design_system.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';

class MockImagePicker extends Mock implements ImagePicker {}
class MockDiagnosisWorkflowService extends Mock implements DiagnosisWorkflowService {}
class MockDiagnosisHistoryRepository extends Mock implements DiagnosisHistoryRepository {}

class DiagnosisFlowCoordinatorHarness {
  final imagePicker = MockImagePicker();
  final workflowService = MockDiagnosisWorkflowService();
  final historyRepository = MockDiagnosisHistoryRepository();
  late final DiagnosisFlowCoordinator coordinator;

  DiagnosisFlowCoordinatorHarness() {
    coordinator = DiagnosisFlowCoordinator(
      imagePicker: imagePicker,
      workflowService: workflowService,
      historyRepository: historyRepository,
    );
  }

  static void registerFallbacks() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(img.Image(width: 1, height: 1));
    registerFallbackValue(const DiagnosisResult(rawLabel: '', confidence: 0.0));
  }

  void galleryImageSelected([Uint8List? bytes]) {
    when(() => imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
        )).thenAnswer((_) async => XFile.fromData(bytes ?? Uint8List(0)));
  }

  void galleryCancelled() {
    when(() => imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
        )).thenAnswer((_) async => null);
  }

  void processingSuccess(img.Image image, Uint8List bytes) {
    when(() => workflowService.processImageBytes(any()))
        .thenAnswer((_) async => WorkflowProcessResult.success(image, bytes));
    when(() => workflowService.processImageObj(any()))
        .thenAnswer((_) async => WorkflowProcessResult.success(image, bytes));
  }

  void processingFailure([String message = 'Error']) {
    when(() => workflowService.processImageBytes(any()))
        .thenAnswer((_) async => WorkflowProcessResult.failure(message));
    when(() => workflowService.processImageObj(any()))
        .thenAnswer((_) async => WorkflowProcessResult.failure(message));
  }

  void classificationSuccess(DiagnosisResult result) {
    when(() => workflowService.classifyImage(any()))
        .thenReturn(result);
  }

  void classificationFailure() {
    when(() => workflowService.classifyImage(any()))
        .thenReturn(null);
  }

  void historyWriteSuccess() {
    when(() => historyRepository.recordDiagnosis(
          result: any(named: 'result'),
          imageBytes: any(named: 'imageBytes'),
        )).thenAnswer((_) async {});
  }

  void historyWriteFailure([Object? error]) {
    when(() => historyRepository.recordDiagnosis(
          result: any(named: 'result'),
          imageBytes: any(named: 'imageBytes'),
        )).thenThrow(error ?? Exception('Disk full'));
  }

  Future<void> pumpStartButtonApp(
    WidgetTester tester,
    Future<void> Function(BuildContext context) onStartPressed,
  ) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => onStartPressed(context),
              child: const Text('Start'),
            );
          },
        ),
      ),
    ));
  }

  Future<void> tapStartButton(WidgetTester tester) async {
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
  }

  Future<DiagnosisOutcome?> startGalleryDiagnosis(BuildContext context) {
    return coordinator.startGalleryDiagnosis(context);
  }

  Future<DiagnosisOutcome?> startCameraDiagnosis(BuildContext context, img.Image image) {
    return coordinator.startCameraDiagnosis(context, image);
  }

  Future<void> tapPreviewConfirm(WidgetTester tester) async {
    await tester.tap(find.text(AppCopy.preview.actionConfirm));
    await tester.pumpAndSettle();
  }

  Future<void> tapPreviewRetry(WidgetTester tester) async {
    await tester.tap(find.text(AppCopy.preview.actionRetry));
    await tester.pumpAndSettle();
  }

  void verifyHistoryRecorded({required DiagnosisResult result, required Uint8List imageBytes}) {
    verify(() => historyRepository.recordDiagnosis(
          result: result,
          imageBytes: imageBytes,
        )).called(1);
  }

  void verifyHistoryNotRecorded() {
    verifyNever(() => historyRepository.recordDiagnosis(
          result: any(named: 'result'),
          imageBytes: any(named: 'imageBytes'),
        ));
  }
}

void main() {
  setUpAll(() {
    DiagnosisFlowCoordinatorHarness.registerFallbacks();
  });

  group('DiagnosisFlowCoordinator', () {
    testWidgets('startGalleryDiagnosis returns cancelled if no image picked', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      harness.galleryCancelled();
      
      DiagnosisOutcome? result;
      await harness.pumpStartButtonApp(tester, (context) async {
        result = await harness.startGalleryDiagnosis(context);
      });
      
      await harness.tapStartButton(tester);
      
      expect(result, DiagnosisOutcome.cancelled);
    });

    testWidgets('startGalleryDiagnosis returns failed if processing fails', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      harness.galleryImageSelected();
      harness.processingFailure();
      
      DiagnosisOutcome? result;
      await harness.pumpStartButtonApp(tester, (context) async {
        result = await harness.startGalleryDiagnosis(context);
      });
      
      await harness.tapStartButton(tester);
      
      expect(result, DiagnosisOutcome.failed);
      expect(find.text(AppCopy.camera.diagnosisFailed), findsOneWidget);
    });

    testWidgets('startGalleryDiagnosis returns cancelled if user retries preview', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      harness.galleryImageSelected();
      
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      harness.processingSuccess(dummyImg, dummyBytes);
      
      DiagnosisOutcome? result;
      await harness.pumpStartButtonApp(tester, (context) async {
        result = await harness.startGalleryDiagnosis(context);
      });
      
      await harness.tapStartButton(tester);
      
      expect(find.text(AppCopy.preview.title), findsOneWidget);
      await harness.tapPreviewRetry(tester);
      
      expect(result, DiagnosisOutcome.cancelled);
    });

    testWidgets('startGalleryDiagnosis returns success on confirm and valid classification', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      harness.galleryImageSelected();
      
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      harness.processingSuccess(dummyImg, dummyBytes);
      harness.classificationSuccess(const DiagnosisResult(rawLabel: 'Healthy', confidence: 0.99));
      
      DiagnosisOutcome? result;
      await harness.pumpStartButtonApp(tester, (context) async {
        result = await harness.startGalleryDiagnosis(context);
      });
      
      await harness.tapStartButton(tester);
      await harness.tapPreviewConfirm(tester);
      
      expect(result, DiagnosisOutcome.success);
      expect(find.text(AppCopy.result.title), findsOneWidget);
    });

    testWidgets('startCameraDiagnosis returns success on confirm', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      harness.processingSuccess(dummyImg, dummyBytes);
      harness.classificationSuccess(const DiagnosisResult(rawLabel: 'Healthy', confidence: 0.99));
      
      DiagnosisOutcome? result;
      await harness.pumpStartButtonApp(tester, (context) async {
        result = await harness.startCameraDiagnosis(context, dummyImg);
      });
      
      await harness.tapStartButton(tester);
      await harness.tapPreviewConfirm(tester);
      
      expect(result, DiagnosisOutcome.success);
    });

    testWidgets('startGalleryDiagnosis records history on success', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      harness.galleryImageSelected();
      
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      const expectedResult = DiagnosisResult(rawLabel: 'Healthy', confidence: 0.99);
      
      harness.processingSuccess(dummyImg, dummyBytes);
      harness.classificationSuccess(expectedResult);
      harness.historyWriteSuccess();
      
      await harness.pumpStartButtonApp(tester, (context) => harness.startGalleryDiagnosis(context));
      
      await harness.tapStartButton(tester);
      await harness.tapPreviewConfirm(tester);
      
      harness.verifyHistoryRecorded(result: expectedResult, imageBytes: dummyBytes);
    });

    testWidgets('startCameraDiagnosis records history on success', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      const expectedResult = DiagnosisResult(rawLabel: 'Healthy', confidence: 0.99);
      
      harness.processingSuccess(dummyImg, dummyBytes);
      harness.classificationSuccess(expectedResult);
      harness.historyWriteSuccess();
      
      await harness.pumpStartButtonApp(tester, (context) => harness.startCameraDiagnosis(context, dummyImg));
      
      await harness.tapStartButton(tester);
      await harness.tapPreviewConfirm(tester);
      
      harness.verifyHistoryRecorded(result: expectedResult, imageBytes: dummyBytes);
    });

    testWidgets('preview cancellation records nothing to history', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      harness.galleryImageSelected();
      
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      harness.processingSuccess(dummyImg, dummyBytes);
      
      await harness.pumpStartButtonApp(tester, (context) => harness.startGalleryDiagnosis(context));
      
      await harness.tapStartButton(tester);
      await harness.tapPreviewRetry(tester);
      
      harness.verifyHistoryNotRecorded();
    });

    testWidgets('classification failure records nothing to history', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      harness.galleryImageSelected();
      
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      harness.processingSuccess(dummyImg, dummyBytes);
      harness.classificationFailure();
      
      await harness.pumpStartButtonApp(tester, (context) => harness.startGalleryDiagnosis(context));
      
      await harness.tapStartButton(tester);
      await harness.tapPreviewConfirm(tester);
      
      harness.verifyHistoryNotRecorded();
    });

    testWidgets('repository write failure still returns success on navigation', (tester) async {
      final harness = DiagnosisFlowCoordinatorHarness();
      harness.galleryImageSelected();
      
      final dummyImg = img.Image(width: 1, height: 1);
      final dummyBytes = Uint8List.fromList(img.encodePng(dummyImg));
      const expectedResult = DiagnosisResult(rawLabel: 'Healthy', confidence: 0.99);
      
      harness.processingSuccess(dummyImg, dummyBytes);
      harness.classificationSuccess(expectedResult);
      harness.historyWriteFailure();
      
      DiagnosisOutcome? result;
      await harness.pumpStartButtonApp(tester, (context) async {
        result = await harness.startGalleryDiagnosis(context);
      });
      
      await harness.tapStartButton(tester);
      await harness.tapPreviewConfirm(tester);
      
      expect(result, DiagnosisOutcome.success);
      expect(find.text(AppCopy.result.title), findsOneWidget);
    });
  });
}
