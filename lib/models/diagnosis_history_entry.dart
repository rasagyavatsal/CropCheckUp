import 'dart:typed_data';
import 'package:crop_check_up/models/diagnosis_result.dart';

/// Immutable model representing a saved diagnosis entry in history.
class DiagnosisHistoryEntry {
  final String id;
  final DateTime createdAt;
  final DiagnosisResult result;
  final Uint8List imageBytes;

  const DiagnosisHistoryEntry({
    required this.id,
    required this.createdAt,
    required this.result,
    required this.imageBytes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'result': result.toJson(),
      };

  factory DiagnosisHistoryEntry.fromJson(
    Map<String, dynamic> json,
    Uint8List imageBytes,
  ) {
    return DiagnosisHistoryEntry(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      result: DiagnosisResult.fromJson(json['result'] as Map<String, dynamic>),
      imageBytes: imageBytes,
    );
  }
}
