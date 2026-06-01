import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:crop_check_up/services/diagnosis_workflow_service.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';
import 'package:crop_check_up/screens/segmentation_preview_screen.dart';
import 'package:crop_check_up/screens/diagnosis_result_screen.dart';
import 'package:crop_check_up/ui/app_design_system.dart';

enum DiagnosisOutcome {
  success,
  cancelled,
  failed,
}

/// Orchestrates the entire plant diagnosis workflow.
/// Handles image selection/input, background removal, resizing, preview,
/// classification, error feedback, and navigation to results.
class DiagnosisFlowCoordinator {
  final ImagePicker _imagePicker;
  final DiagnosisWorkflowService _workflowService;

  DiagnosisFlowCoordinator({
    ImagePicker? imagePicker,
    DiagnosisWorkflowService? workflowService,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _workflowService = workflowService ?? DiagnosisWorkflowService();

  /// Initialises required services for diagnosis.
  Future<void> init() async {
    await _workflowService.init();
  }

  /// Disposes resources used by the services.
  void dispose() {
    _workflowService.dispose();
  }

  /// Starts the diagnosis flow using an image picked from the gallery.
  Future<DiagnosisOutcome> startGalleryDiagnosis(BuildContext context) async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (file == null) {
      return DiagnosisOutcome.cancelled;
    }

    if (!context.mounted) return DiagnosisOutcome.failed;

    try {
      final bytes = await file.readAsBytes();
      final processResult = await _workflowService.processImageBytes(bytes);
      if (!context.mounted) return DiagnosisOutcome.failed;
      return _processAndDiagnose(context, processResult);
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, AppCopy.camera.diagnosisFailed);
      }
      return DiagnosisOutcome.failed;
    }
  }

  /// Starts the diagnosis flow using a decoded camera frame.
  Future<DiagnosisOutcome> startCameraDiagnosis(BuildContext context, img.Image frame) async {
    try {
      final processResult = await _workflowService.processImageObj(frame);
      if (!context.mounted) return DiagnosisOutcome.failed;
      return _processAndDiagnose(context, processResult);
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, AppCopy.camera.diagnosisFailed);
      }
      return DiagnosisOutcome.failed;
    }
  }

  Future<DiagnosisOutcome> _processAndDiagnose(BuildContext context, WorkflowProcessResult processResult) async {
    if (!processResult.isSuccess) {
      if (context.mounted) {
        AppFeedback.showError(context, AppCopy.camera.diagnosisFailed);
      }
      return DiagnosisOutcome.failed;
    }

    if (!context.mounted) return DiagnosisOutcome.failed;

    // Show preview for user confirmation before running inference.
    final confirmed = await SegmentationPreviewScreen.show(
      context, 
      processResult.resizedBytes!,
    );
    
    if (confirmed != true) {
      return DiagnosisOutcome.cancelled;
    }

    if (!context.mounted) return DiagnosisOutcome.failed;

    final result = _workflowService.classifyImage(processResult.resizedImage!);
    
    if (result != null) {
      Navigator.of(context).push(
        AppRoute.standard<void>(
          builder: (_) => DiagnosisResultScreen(
            result: result,
            imageBytes: processResult.resizedBytes!,
          ),
        ),
      );
      return DiagnosisOutcome.success;
    } else {
      AppFeedback.showError(context, AppCopy.camera.diagnosisFailed);
      return DiagnosisOutcome.failed;
    }
  }
}
