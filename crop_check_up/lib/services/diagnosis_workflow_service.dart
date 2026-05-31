import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../models/diagnosis_result.dart';
import 'background_removal_service.dart';
import 'plant_classifier.dart';

class WorkflowProcessResult {
  final img.Image? resizedImage;
  final Uint8List? resizedBytes;
  final String? error;

  bool get isSuccess => error == null && resizedImage != null && resizedBytes != null;

  WorkflowProcessResult.success(this.resizedImage, this.resizedBytes) : error = null;
  WorkflowProcessResult.failure(this.error) : resizedImage = null, resizedBytes = null;
}

/// A "Deep Module" that orchestrates the core plant diagnosis workflow tasks.
///
/// Hides the complexity of background removal, resizing, and 
/// model inference behind a simple API, without coupling to the UI.
class DiagnosisWorkflowService {
  final PlantClassifier _classifier;
  final BackgroundRemovalService _bgRemover;

  DiagnosisWorkflowService({
    PlantClassifier? classifier,
    BackgroundRemovalService? bgRemover,
  })  : _classifier = classifier ?? PlantClassifier(),
        _bgRemover = bgRemover ?? BackgroundRemovalService();

  bool _isInitialised = false;
  bool get isInitialised => _isInitialised;

  /// Initialises all underlying AI models and services.
  Future<void> init() async {
    if (_isInitialised) return;
    await Future.wait([
      _classifier.init(),
      _bgRemover.init(),
    ]);
    _isInitialised = true;
  }

  /// Disposes resources used by the services.
  void dispose() {
    _classifier.dispose();
  }

  /// Processes raw image bytes by removing background and resizing for the model.
  Future<WorkflowProcessResult> processImageBytes(Uint8List bytes) async {
    try {
      final processedImage = await _bgRemover.processImageBytes(bytes);
      
      if (processedImage == null) {
        return WorkflowProcessResult.failure('Failed to remove background and process image.');
      }

      final (resizedImage, resizedBytes) = await _classifier.resizeForModel(processedImage.image);
      return WorkflowProcessResult.success(resizedImage, resizedBytes);
    } catch (e) {
      return WorkflowProcessResult.failure('Error processing image: $e');
    }
  }

  /// Processes an image object by removing background and resizing for the model.
  Future<WorkflowProcessResult> processImageObj(img.Image frame) async {
    try {
      final processedImage = await _bgRemover.processImageObj(frame);
      
      if (processedImage == null) {
        return WorkflowProcessResult.failure('Failed to remove background and process image.');
      }

      final (resizedImage, resizedBytes) = await _classifier.resizeForModel(processedImage.image);
      return WorkflowProcessResult.success(resizedImage, resizedBytes);
    } catch (e) {
      return WorkflowProcessResult.failure('Error processing image: $e');
    }
  }

  /// Classifies the processed and resized image.
  DiagnosisResult? classifyImage(img.Image image) {
    return _classifier.classifyImage(image);
  }
}
