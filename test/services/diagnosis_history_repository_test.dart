import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/services/diagnosis_history_repository.dart';

void main() {
  late Directory tempDir;
  late DiagnosisHistoryRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('diagnosis_history_test_');
    repository = DiagnosisHistoryRepository(baseDirectory: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DiagnosisHistoryRepository', () {
    test('loadRecent returns empty list when no history exists', () async {
      final entries = await repository.loadRecent();
      expect(entries, isEmpty);
    });

    test('recordDiagnosis saves the diagnosis and image, loadRecent retrieves it', () async {
      const result = DiagnosisResult(
        rawLabel: 'Tomato___Late_blight',
        confidence: 0.95,
        symptoms: 'spots',
      );
      final imageBytes = Uint8List.fromList([10, 20, 30, 40]);

      await repository.recordDiagnosis(result: result, imageBytes: imageBytes);

      final entries = await repository.loadRecent();
      expect(entries.length, 1);
      
      final entry = entries.first;
      expect(entry.id, isNotEmpty);
      expect(entry.result, result);
      expect(entry.imageBytes, imageBytes);
      expect(DateTime.now().difference(entry.createdAt).inSeconds, lessThan(5));

      // Verify PNG file exists
      final pngFile = File('${tempDir.path}/${entry.id}.png');
      expect(await pngFile.exists(), isTrue);
      expect(await pngFile.readAsBytes(), imageBytes);

      // Verify JSON index file exists and is populated
      final indexFile = File('${tempDir.path}/history.json');
      expect(await indexFile.exists(), isTrue);
      final indexData = json.decode(await indexFile.readAsString()) as List;
      expect(indexData.length, 1);
      expect(indexData[0]['id'], entry.id);
    });

    test('loadRecent returns entries sorted newest-first', () async {
      const result1 = DiagnosisResult(rawLabel: 'Tomato___healthy', confidence: 0.9);
      const result2 = DiagnosisResult(rawLabel: 'Potato___Late_blight', confidence: 0.8);
      
      await repository.recordDiagnosis(result: result1, imageBytes: Uint8List.fromList([1]));
      // Wait a bit to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.recordDiagnosis(result: result2, imageBytes: Uint8List.fromList([2]));

      final entries = await repository.loadRecent();
      expect(entries.length, 2);
      expect(entries[0].result.rawLabel, 'Potato___Late_blight');
      expect(entries[1].result.rawLabel, 'Tomato___healthy');
    });

    test('loadRecent respects the limit parameter', () async {
      for (int i = 0; i < 5; i++) {
        await repository.recordDiagnosis(
          result: DiagnosisResult(rawLabel: 'Plant___$i', confidence: 0.9),
          imageBytes: Uint8List.fromList([i]),
        );
        await Future.delayed(const Duration(milliseconds: 2));
      }

      final entries = await repository.loadRecent(limit: 3);
      expect(entries.length, 3);
      expect(entries[0].result.rawLabel, 'Plant___4');
      expect(entries[1].result.rawLabel, 'Plant___3');
      expect(entries[2].result.rawLabel, 'Plant___2');
    });

    test('enforces max 20 entries and deletes pruned image files', () async {
      // Record 22 diagnoses
      for (int i = 0; i < 22; i++) {
        await repository.recordDiagnosis(
          result: DiagnosisResult(rawLabel: 'Plant___$i', confidence: 0.9),
          imageBytes: Uint8List.fromList([i]),
        );
        await Future.delayed(const Duration(milliseconds: 2));
      }

      final entries = await repository.loadRecent(limit: 50);
      // Capped at 20
      expect(entries.length, 20);
      
      // The newest ones should be kept (Plant 2 to Plant 21)
      expect(entries.first.result.rawLabel, 'Plant___21');
      expect(entries.last.result.rawLabel, 'Plant___2');

      // The oldest ones (Plant 0 and Plant 1) should be pruned.
      // We don't have the exact IDs directly, but we can verify only 20 PNG files exist in the temp directory.
      final pngFiles = tempDir.listSync().where((f) => f is File && f.path.endsWith('.png')).toList();
      expect(pngFiles.length, 20);

      // Verify history.json contains exactly 20 records
      final indexFile = File('${tempDir.path}/history.json');
      final indexData = json.decode(await indexFile.readAsString()) as List;
      expect(indexData.length, 20);
    });

    test('persisted history survives repository recreate', () async {
      const result = DiagnosisResult(
        rawLabel: 'Apple___Apple_scab',
        confidence: 0.77,
      );
      final imageBytes = Uint8List.fromList([1, 3, 5]);

      await repository.recordDiagnosis(result: result, imageBytes: imageBytes);

      // Recreate repository pointing to the same tempDir
      final newRepository = DiagnosisHistoryRepository(baseDirectory: tempDir);
      final entries = await newRepository.loadRecent();
      
      expect(entries.length, 1);
      expect(entries.first.result, result);
      expect(entries.first.imageBytes, imageBytes);
    });
  });
}
