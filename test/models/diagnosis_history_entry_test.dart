import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/models/diagnosis_history_entry.dart';

void main() {
  group('DiagnosisHistoryEntry', () {
    test('holds fields correctly', () {
      final now = DateTime.now();
      final result = const DiagnosisResult(
        rawLabel: 'Tomato___Late_blight',
        confidence: 0.95,
      );
      final imageBytes = Uint8List.fromList([1, 2, 3, 4]);

      final entry = DiagnosisHistoryEntry(
        id: 'test-id-123',
        createdAt: now,
        result: result,
        imageBytes: imageBytes,
      );

      expect(entry.id, 'test-id-123');
      expect(entry.createdAt, now);
      expect(entry.result, result);
      expect(entry.imageBytes, imageBytes);
    });

    test('JSON serialization round-trip', () {
      final now = DateTime.parse('2026-06-06T12:00:00.000Z');
      final result = const DiagnosisResult(
        rawLabel: 'Tomato___Late_blight',
        confidence: 0.95,
        symptoms: 'spots',
      );
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      final entry = DiagnosisHistoryEntry(
        id: 'entry-1',
        createdAt: now,
        result: result,
        imageBytes: imageBytes,
      );

      final json = entry.toJson();
      expect(json['id'], 'entry-1');
      expect(json['createdAt'], '2026-06-06T12:00:00.000Z');
      expect(json['result']['rawLabel'], 'Tomato___Late_blight');
      expect(json['result']['confidence'], 0.95);
      expect(json['result']['symptoms'], 'spots');

      // Reconstruct using fromJson and the original imageBytes
      final reconstructed = DiagnosisHistoryEntry.fromJson(json, imageBytes);
      expect(reconstructed.id, 'entry-1');
      expect(reconstructed.createdAt, now);
      expect(reconstructed.result, result);
      expect(reconstructed.imageBytes, imageBytes);
    });
  });
}
