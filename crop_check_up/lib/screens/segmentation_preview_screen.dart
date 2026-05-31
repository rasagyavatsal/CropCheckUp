import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/layout/layout.dart';
import '../ui/components/cards/app_card.dart';
import '../ui/tokens/typography.dart';
import '../ui/theme/theme_ext.dart';
import '../ui/tokens/spacing_tokens.dart';

/// Screen to preview the segmented image before inference.
/// 
/// This allows the user to verify if the background removal was successful 
/// and if the leaf is clearly visible.
class SegmentationPreviewScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const SegmentationPreviewScreen({
    super.key,
    required this.imageBytes,
  });

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

    return AppPageShell(
      applySafeArea: true,
      bottomNavigationBar: AppBottomActionBar(
        child: Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: AppCopy.preview.actionRetry,
                onPressed: () => Navigator.pop(context, false),
                icon: Icons.refresh_rounded,
              ),
            ),
            SizedBox(width: spacing.m),
            Expanded(
              child: AppButton.primary(
                label: AppCopy.preview.actionConfirm,
                onPressed: () => Navigator.pop(context, true),
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.l),
        child: Column(
          children: [
            SizedBox(height: spacing.xl),
            
            // Header
            Text(
              AppCopy.preview.title,
              style: context.typography.headline,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.s),
            Text(
              AppCopy.preview.instruction,
              style: context.typography.body.copyWith(
                color: context.appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Image Preview
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'segmentation_preview',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.xl),
                    child: AppCard.image(
                      image: Flexible(
                        child: Semantics(
                          image: true,
                          label: AppCopy.preview.semanticPreviewImage,
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
