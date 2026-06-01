import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/diagnosis_result.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/diagnosis/result_presentation_view.dart';
import '../ui/components/layout/app_page_shell.dart';
import '../ui/tokens/spacing_tokens.dart';
import '../ui/tokens/typography.dart';
import '../ui/theme/theme_ext.dart';

/// Full‑screen route that presents a [DiagnosisResult].
///
/// Shows the disease name, crop name, a confidence progress bar, a colour‑coded
/// health icon, and a button to navigate to treatment information.
class DiagnosisResultScreen extends StatelessWidget {
  final DiagnosisResult result;
  final Uint8List? imageBytes;

  const DiagnosisResultScreen({
    super.key,
    required this.result,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    final colors = context.appColors;

    return Stack(
      children: [
        AppPageShell(
          applySafeArea: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Minimal Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.l, vertical: spacing.m),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: colors.raisedSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.subtleBorder),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Title
                    Text(
                      AppCopy.result.title,
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
              ),
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(spacing.l, spacing.m, spacing.l, spacing.xxl),
                  child: ResultPresentationView(
                    result: result,
                    imageBytes: imageBytes,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
