import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../ui/app_design_system.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/layout/layout.dart';
import '../ui/tokens/typography.dart';
import '../ui/theme/theme_ext.dart';
import '../ui/tokens/spacing_tokens.dart';
import '../ui/tokens/radius_tokens.dart';

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
    const radius = RadiusTokens();

    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        AppPageShell(
          applySafeArea: true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.l, vertical: spacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top action bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back/Retry Button
                    Container(
                      decoration: BoxDecoration(
                        color: colors.raisedSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.subtleBorder),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                        tooltip: AppCopy.preview.actionRetry,
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                    // Title
                    Text(
                      AppCopy.preview.title,
                      style: context.typography.title.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    // Placeholder for symmetry
                    const SizedBox(width: 48),
                  ],
                ),
                SizedBox(height: spacing.l),
                
                // Instruction Text
                Text(
                  AppCopy.preview.instruction,
                  style: context.typography.body.copyWith(
                    color: colors.mutedText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.l),
                
                // Image Preview Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.raisedSurface,
                      borderRadius: BorderRadius.circular(radius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: colors.textPrimary.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius.xl),
                      child: Hero(
                        tag: 'segmentation_preview',
                        child: Semantics(
                          image: true,
                          label: AppCopy.preview.semanticPreviewImage,
                          child: Padding(
                            padding: EdgeInsets.all(spacing.m),
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
                
                SizedBox(height: spacing.xl),
                
                // Bottom Actions
                Semantics(
                  button: true,
                  label: AppCopy.preview.actionConfirm,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: colors.brand,
                        foregroundColor: isDark ? colors.background : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius.l),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.check_circle_rounded, size: 24),
                      label: Text(
                        AppCopy.preview.actionConfirm,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  button: true,
                  label: AppCopy.preview.actionRetry,
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        foregroundColor: colors.textPrimary,
                        backgroundColor: colors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius.l),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.refresh_rounded, size: 24),
                      label: Text(
                        AppCopy.preview.actionRetry,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
