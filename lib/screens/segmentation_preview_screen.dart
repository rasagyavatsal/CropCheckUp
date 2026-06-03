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
                  _PreviewStatus(instruction: AppCopy.preview.instruction),
                  SizedBox(height: spacing.m),
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
                  const _SpecimenChecklist(),
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

class _PreviewStatus extends StatelessWidget {
  final String instruction;

  const _PreviewStatus({required this.instruction});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.all(spacing.m),
      decoration: BoxDecoration(
        color: colors.raisedSurface,
        border: Border.all(color: colors.subtleBorder),
        borderRadius: BorderRadius.circular(const RadiusTokens().l),
      ),
      child: Row(
        children: [
          Icon(Icons.content_cut_rounded, color: colors.brandSecondary),
          SizedBox(width: spacing.m),
          Expanded(
            child: Text(
              instruction,
              style: context.typography.label.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecimenChecklist extends StatelessWidget {
  const _SpecimenChecklist();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SpecimenSignal(
            icon: Icons.eco_rounded,
            label: 'Leaf visible',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _SpecimenSignal(
            icon: Icons.auto_fix_high_rounded,
            label: 'Background removed',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _SpecimenSignal(
            icon: Icons.center_focus_strong_rounded,
            label: 'Edges clear',
          ),
        ),
      ],
    );
  }
}

class _SpecimenSignal extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecimenSignal({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: EdgeInsets.all(spacing.s),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.subtleBorder),
        borderRadius: BorderRadius.circular(const RadiusTokens().l),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: colors.brand),
          SizedBox(height: spacing.s),
          Text(
            label,
            style: context.typography.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
