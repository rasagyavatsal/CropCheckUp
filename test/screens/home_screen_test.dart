import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:crop_check_up/models/diagnosis_history_entry.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/screens/home_screen.dart';
import 'package:crop_check_up/services/diagnosis_history_repository.dart';
import 'package:crop_check_up/ui/app_design_system.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';
import 'package:crop_check_up/ui/flow/diagnosis_flow_coordinator.dart';

typedef HistoryLoader = Future<List<DiagnosisHistoryEntry>> Function(int limit);

class TestDiagnosisHistoryRepository implements DiagnosisHistoryRepository {
  final List<HistoryLoader> loaders;
  int loadCalls = 0;

  TestDiagnosisHistoryRepository(this.loaders);

  @override
  Future<List<DiagnosisHistoryEntry>> loadRecent({int limit = 10}) {
    final loaderIndex =
        loadCalls < loaders.length ? loadCalls : loaders.length - 1;
    loadCalls += 1;
    return loaders[loaderIndex](limit);
  }

  @override
  Future<void> recordDiagnosis({
    required DiagnosisResult result,
    required Uint8List imageBytes,
  }) async {}
}

class TestDiagnosisFlowCoordinator implements DiagnosisFlowCoordinator {
  final Future<void> Function()? onInit;
  final Future<DiagnosisOutcome> Function(BuildContext context)?
  onStartGalleryDiagnosis;

  TestDiagnosisFlowCoordinator({this.onInit, this.onStartGalleryDiagnosis});

  @override
  Future<void> init() => onInit?.call() ?? Future.value();

  @override
  void dispose() {}

  @override
  Future<DiagnosisOutcome> startGalleryDiagnosis(BuildContext context) {
    return onStartGalleryDiagnosis?.call(context) ??
        Future.value(DiagnosisOutcome.cancelled);
  }

  @override
  Future<DiagnosisOutcome> startCameraDiagnosis(
    BuildContext context,
    img.Image frame,
  ) {
    return Future.value(DiagnosisOutcome.cancelled);
  }
}

void main() {
  group('HomeScreen', () {
    testWidgets('renders AppLoadingState while initializing', (tester) async {
      final initCompleter = Completer<void>();
      final repository = TestDiagnosisHistoryRepository([
        (_) async => const [],
      ]);

      await _pumpHome(
        tester,
        coordinator: TestDiagnosisFlowCoordinator(
          onInit: () => initCompleter.future,
        ),
        historyRepository: repository,
      );

      expect(find.byType(AppLoadingState), findsOneWidget);
    });

    testWidgets('renders compact empty history state', (tester) async {
      final repository = TestDiagnosisHistoryRepository([
        (_) async => const [],
      ]);

      await _pumpHome(
        tester,
        coordinator: TestDiagnosisFlowCoordinator(),
        historyRepository: repository,
      );
      await tester.pumpAndSettle();

      expect(find.text(AppCopy.home.recentDiagnosesTitle), findsOneWidget);
      expect(find.text(AppCopy.home.recentEmptyTitle), findsOneWidget);
      expect(find.text(AppCopy.home.recentEmptyMessage), findsOneWidget);
      expect(find.text(AppCopy.home.tipsTitle), findsNothing);
    });

    testWidgets('renders app version from metadata loader', (tester) async {
      final repository = TestDiagnosisHistoryRepository([
        (_) async => const [],
      ]);

      await _pumpHome(
        tester,
        coordinator: TestDiagnosisFlowCoordinator(),
        historyRepository: repository,
        appVersionLoader: () async => '0.0.1',
      );
      await tester.pumpAndSettle();

      expect(find.text(AppCopy.home.versionLabel('0.0.1')), findsOneWidget);
    });

    testWidgets('renders carousel with multiple history entries', (
      tester,
    ) async {
      final repository = TestDiagnosisHistoryRepository([
        (_) async => [
          _historyEntry(
            id: 'tomato',
            rawLabel: 'Tomato___Late_blight',
            confidence: 0.91,
          ),
          _historyEntry(
            id: 'potato',
            rawLabel: 'Potato___healthy',
            confidence: 0.97,
          ),
        ],
      ]);

      await _pumpHome(
        tester,
        coordinator: TestDiagnosisFlowCoordinator(),
        historyRepository: repository,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('recent-diagnoses-carousel')),
        findsOneWidget,
      );
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Late blight'), findsOneWidget);
      expect(find.text('91% confidence'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('97% confidence'), findsOneWidget);
    });

    testWidgets('opens diagnosis result from history card tap', (tester) async {
      final repository = TestDiagnosisHistoryRepository([
        (_) async => [
          _historyEntry(
            id: 'tomato',
            rawLabel: 'Tomato___Late_blight',
            confidence: 0.91,
          ),
        ],
      ]);

      await _pumpHome(
        tester,
        coordinator: TestDiagnosisFlowCoordinator(),
        historyRepository: repository,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('recent-diagnosis-card-tomato')),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppCopy.result.title), findsOneWidget);
      expect(find.text('Late blight'), findsWidgets);
    });

    testWidgets('reloads history after returning from a diagnosis flow', (
      tester,
    ) async {
      final entries = <DiagnosisHistoryEntry>[];
      final repository = TestDiagnosisHistoryRepository([
        (_) async => List<DiagnosisHistoryEntry>.of(entries),
      ]);

      await _pumpHome(
        tester,
        coordinator: TestDiagnosisFlowCoordinator(),
        historyRepository: repository,
        cameraScreenBuilder:
            (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Return home'),
                ),
              ),
            ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppCopy.home.recentEmptyTitle), findsOneWidget);

      await tester.tap(find.text(AppCopy.home.actionCameraTitle));
      await tester.pumpAndSettle();

      entries.add(
        _historyEntry(
          id: 'apple',
          rawLabel: 'Apple___Apple_scab',
          confidence: 0.86,
        ),
      );
      await tester.tap(find.text('Return home'));
      await tester.pumpAndSettle();

      expect(repository.loadCalls, 2);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Apple scab'), findsOneWidget);
    });

    testWidgets('history loading failure keeps primary actions available', (
      tester,
    ) async {
      final repository = TestDiagnosisHistoryRepository([
        (_) async => throw Exception('disk unavailable'),
      ]);

      await _pumpHome(
        tester,
        coordinator: TestDiagnosisFlowCoordinator(),
        historyRepository: repository,
      );
      await tester.pumpAndSettle();

      expect(find.text(AppCopy.home.recentError), findsOneWidget);
      expect(find.text(AppCopy.home.actionCameraTitle), findsOneWidget);
      expect(find.text(AppCopy.home.actionUploadTitle), findsOneWidget);
      expect(find.byType(AppErrorState), findsNothing);
    });
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required DiagnosisFlowCoordinator coordinator,
  required DiagnosisHistoryRepository historyRepository,
  WidgetBuilder? cameraScreenBuilder,
  Future<String?> Function()? appVersionLoader,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: HomeScreen(
        coordinator: coordinator,
        historyRepository: historyRepository,
        cameraScreenBuilder: cameraScreenBuilder,
        appVersionLoader: appVersionLoader,
      ),
    ),
  );
}

DiagnosisHistoryEntry _historyEntry({
  required String id,
  required String rawLabel,
  required double confidence,
}) {
  return DiagnosisHistoryEntry(
    id: id,
    createdAt: DateTime(2026, 6, 6, 9, 30),
    result: DiagnosisResult(
      rawLabel: rawLabel,
      confidence: confidence,
      symptoms: 'Leaf spots',
      causes: 'Fungal infection',
      management: 'Remove affected leaves.',
    ),
    imageBytes: Uint8List.fromList(_pngBytes),
  );
}

const _pngBytes = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
