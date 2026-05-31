import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/diagnosis_result_screen.dart';
import '../screens/segmentation_preview_screen.dart';
import '../ui/adaptive/app_adaptive.dart';
import 'background_removal_service.dart';
import 'plant_classifier.dart';

/// A "Deep Module" that orchestrates the entire plant diagnosis workflow.
///
/// Hides the complexity of image picking, background removal, 
/// model inference, and navigation behind a simple API.
class DiagnosisWorkflowService {
  final PlantClassifier _classifier = PlantClassifier();
  final BackgroundRemovalService _bgRemover = BackgroundRemovalService();
  final ImagePicker _imagePicker = ImagePicker();

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

  /// Picks an image from the gallery and runs the full diagnosis pipeline.
  /// 
  /// Returns `true` if a diagnosis was successfully completed and navigated to,
  /// or `false` if the process was cancelled or failed.
  Future<bool> pickAndDiagnose(BuildContext context, {required Function(bool) onLoading}) async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null) return false;

    onLoading(true);

    try {
      final bytes = await File(file.path).readAsBytes();
      final processedImage = await _bgRemover.processImageBytes(bytes);
      
      if (processedImage == null) {
        if (context.mounted) {
          _showError(context, 'Failed to remove background and process image.');
        }
        return false;
      }

      // Resize to model input dimensions (224x224).
      final (resizedImage, resizedBytes) = await _classifier.resizeForModel(processedImage.image);

      // Show preview for user confirmation before running inference.
      if (context.mounted) {
        final confirmed = await SegmentationPreviewScreen.show(
          context, 
          resizedBytes,
        );
        
        if (confirmed != true) {
          return false; // User cancelled or wanted to retry.
        }
      }

      final result = _classifier.classifyImage(resizedImage);
      
      if (!context.mounted) return false;
      
      if (result != null) {
        Navigator.of(context).push(
          AppRoute.standard<void>(
            builder: (_) => DiagnosisResultScreen(
              result: result,
              imageBytes: resizedBytes,
            ),
          ),
        );
        return true;
      } else {
        _showError(context, 'Could not confidently diagnose from this image.');
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error during diagnosis: $e');
      }
      return false;
    } finally {
      onLoading(false);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
