/// Immutable value object representing a plant disease diagnosis.
///
/// Encapsulates the full output of a single inference run — the predicted
/// label, confidence score, and convenience properties derived from label
/// parsing (crop name, disease name, health status).
class DiagnosisResult {
  /// Raw label string from `labels.txt` (e.g. `"Tomato___Late_blight"`).
  final String rawLabel;

  /// Model confidence in the range `[0.0, 1.0]`.
  final double confidence;

  /// Detailed symptoms of the disease (if applicable).
  final String? symptoms;

  /// Underlying cause or pathogen of the disease (if applicable).
  final String? causes;

  /// Recommended management and treatment steps (if applicable).
  final String? management;

  const DiagnosisResult({
    required this.rawLabel,
    required this.confidence,
    this.symptoms,
    this.causes,
    this.management,
  });

  // ---------------------------------------------------------------------------
  // Derived properties
  // ---------------------------------------------------------------------------

  /// Human‑readable crop name extracted from the raw label.
  ///
  /// Splits on `"___"`, takes the first segment and replaces underscores with
  /// spaces.  e.g. `"Cherry_(including_sour)"` → `"Cherry (including sour)"`.
  String get cropName {
    final parts = rawLabel.split('___');
    return _humanize(parts.first);
  }

  /// Human‑readable disease name.
  ///
  /// Returns `"Healthy"` for labels whose second segment is `"healthy"`,
  /// otherwise the humanised disease string.
  String get diseaseName {
    final parts = rawLabel.split('___');
    if (parts.length < 2) return 'Unknown';
    final raw = parts[1];
    if (raw.toLowerCase() == 'healthy') return 'Healthy';
    return _humanize(raw);
  }

  /// Formatted display label combining crop and disease.
  String get displayLabel => '$cropName — $diseaseName';

  /// Whether this diagnosis indicates a healthy plant.
  bool get isHealthy => rawLabel.toLowerCase().contains('healthy');

  /// Confidence expressed as a percentage integer (0‑100).
  int get confidencePercent => (confidence * 100).round();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts an underscore‑delimited segment into a human‑readable string,
  /// preserving parenthetical expressions.
  static String _humanize(String segment) {
    return segment
        .replaceAll('_', ' ')
        .replaceAll('  ', ' ')
        .trim();
  }

  @override
  String toString() => 'DiagnosisResult($displayLabel, $confidencePercent%)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosisResult &&
          rawLabel == other.rawLabel &&
          confidence == other.confidence &&
          symptoms == other.symptoms &&
          causes == other.causes &&
          management == other.management;

  @override
  int get hashCode =>
      rawLabel.hashCode ^
      confidence.hashCode ^
      symptoms.hashCode ^
      causes.hashCode ^
      management.hashCode;

  Map<String, dynamic> toJson() => {
        'rawLabel': rawLabel,
        'confidence': confidence,
        'symptoms': symptoms,
        'causes': causes,
        'management': management,
      };

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      rawLabel: json['rawLabel'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      symptoms: json['symptoms'] as String?,
      causes: json['causes'] as String?,
      management: json['management'] as String?,
    );
  }
}

