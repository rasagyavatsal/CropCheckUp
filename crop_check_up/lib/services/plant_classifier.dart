import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/diagnosis_result.dart';

/// On-device plant‑disease classifier backed by a TFLite model.
///
/// **Interface** (deep module — only two public methods):
///
///   • [init]            — load the model & labels once.
///   • [classifyImage]   — run inference on raw image bytes.
///
/// All pre‑processing, tensor conversion, model invocation, and post‑processing
/// are encapsulated inside this class.
class PlantClassifier {
  static const String _modelAsset = 'assets/plant_disease_model.tflite';
  static const String _labelsAsset = 'assets/labels.txt';
  static const String _diseaseInfoAsset = 'assets/disease_info.json';
  static const int _inputSize = 224;
  static const double _confidenceThreshold = 0.0;

  Interpreter? _interpreter;
  List<String> _labels = [];
  Map<String, dynamic> _diseaseInfo = {};

  /// Whether [init] has completed successfully.
  bool get isReady => _interpreter != null && _labels.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Load the TFLite model and class labels from app assets.
  ///
  /// Must be called once before [classifyImage].  Subsequent calls are no‑ops.
  Future<void> init() async {
    if (isReady) return;

    _interpreter = await Interpreter.fromAsset(_modelAsset);
    _labels = await _loadLabels();
    _diseaseInfo = await _loadDiseaseInfo();
  }

  /// Classify a camera frame supplied as a decoded [img.Image].
  ///
  /// Returns a [DiagnosisResult] when the model's top confidence exceeds
  /// [_confidenceThreshold], or `null` if the prediction is too uncertain.
  DiagnosisResult? classifyImage(img.Image image) {
    assert(isReady, 'PlantClassifier.init() must be called first');

    // If image is already 224x224, we still run through _preprocessImage 
    // to get the correctly formatted tensor.
    final input = _preprocessImage(image);
    final output = _runInference(input);
    return _interpretOutput(output);
  }

  /// Resizes the image to the model's required input size (224x224).
  /// 
  /// Returns the resized [img.Image] and its PNG bytes for display.
  Future<(img.Image, Uint8List)> resizeForModel(img.Image image) async {
    return compute(_resizeAndEncode, image);
  }

  static (img.Image, Uint8List) _resizeAndEncode(img.Image image) {
    final resized = img.copyResizeCropSquare(
      image,
      size: _inputSize,
      interpolation: img.Interpolation.linear,
    );
    
    final bytes = Uint8List.fromList(img.encodePng(resized));
    return (resized, bytes);
  }

  /// Release the interpreter resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  // ---------------------------------------------------------------------------
  // Private implementation
  // ---------------------------------------------------------------------------

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString(_labelsAsset);
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> _loadDiseaseInfo() async {
    final raw = await rootBundle.loadString(_diseaseInfoAsset);
    return json.decode(raw) as Map<String, dynamic>;
  }

  /// Resize to 224×224 and convert to a `[1, 224, 224, 3]` tensor.
  ///
  /// Pixel values are kept in the raw `[0, 255]` range.  The TFLite model
  /// contains a built‑in `preprocess_input` Lambda layer that normalises
  /// to `[-1, 1]` internally, so no manual scaling is needed here.
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final img.Image resized;
    if (image.width == _inputSize && image.height == _inputSize) {
      resized = image;
    } else {
      resized = img.copyResizeCropSquare(
        image,
        size: _inputSize,
        interpolation: img.Interpolation.linear,
      );
    }

    return List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            double r = pixel.r.toDouble();
            double g = pixel.g.toDouble();
            double b = pixel.b.toDouble();
            
            // Treat perfectly transparent pixels (background) as solid black
            if (pixel.a == 0) {
              r = 0.0;
              g = 0.0;
              b = 0.0;
            }
            
            return [r, g, b];
          },
        ),
      ),
    );
  }

  /// Execute the interpreter and return the raw output probabilities.
  List<double> _runInference(List<List<List<List<double>>>> input) {
    final outputBuffer = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter!.run(input, outputBuffer);
    return List<double>.from(outputBuffer[0] as List);
  }

  /// Map the raw output to a [DiagnosisResult], applying the confidence gate.
  DiagnosisResult? _interpretOutput(List<double> probabilities) {
    double maxScore = probabilities[0];
    int maxIndex = 0;

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxScore) {
        maxScore = probabilities[i];
        maxIndex = i;
      }
    }

    if (maxScore < _confidenceThreshold) return null;

    final String rawLabel = _labels[maxIndex];
    final Map<String, dynamic>? info = _diseaseInfo[rawLabel] as Map<String, dynamic>?;

    return DiagnosisResult(
      rawLabel: rawLabel,
      confidence: maxScore,
      symptoms: info?['symptoms'] as String?,
      causes: info?['causes'] as String?,
      management: info?['management'] as String?,
    );
  }
}
