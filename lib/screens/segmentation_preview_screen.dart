import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../ui/app_design_system.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/layout/layout.dart';
import '../ui/tokens/spacing_tokens.dart';

/// Screen to preview the segmented image before inference.
///
/// This allows the user to verify if the background removal was successful
/// and if the leaf is clearly visible.
class SegmentationPreviewScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const SegmentationPreviewScreen({super.key, required this.imageBytes});

  /// Shows the preview screen and returns true if confirmed, false if retried.
  static Future<bool?> show(BuildContext context, Uint8List imageBytes) {
    return Navigator.push<bool>(
      context,
      AppRoute.dialog(
        builder: (_) => SegmentationPreviewScreen(imageBytes: imageBytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();

    return Stack(
      children: [
        AppPageShell(
          applySafeArea: true,
          child: AppGridBackground(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.l,
                spacing.m,
                spacing.l,
                spacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppScreenHeader(
                    title: AppCopy.preview.title,
                    leading: AppHeaderAction(
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: AppCopy.preview.actionRetry,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  SizedBox(height: spacing.l),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: AppImagePanel(
                        imageBytes: imageBytes,
                        semanticLabel: AppCopy.preview.semanticPreviewImage,
                        heroTag: 'segmentation_preview',
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.m),
                  Semantics(
                    button: true,
                    label: AppCopy.preview.actionConfirm,
                    child: AppButton.primary(
                      isFullWidth: true,
                      icon: Icons.check_circle_rounded,
                      label: AppCopy.preview.actionConfirm,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  Semantics(
                    button: true,
                    label: AppCopy.preview.actionRetry,
                    child: AppButton.secondary(
                      isFullWidth: true,
                      icon: Icons.refresh_rounded,
                      label: AppCopy.preview.actionRetry,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
