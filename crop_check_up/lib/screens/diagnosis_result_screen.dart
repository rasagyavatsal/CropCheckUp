import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/diagnosis_result.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/diagnosis/result_presentation_view.dart';
import '../ui/components/layout/app_page_shell.dart';
import '../ui/tokens/spacing_tokens.dart';


import '../ui/components/app_components.dart';

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


    return Stack(
      children: [
        AppPageShell(
          applySafeArea: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shared App Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.l, vertical: spacing.m),
                child: AppScreenHeader(
                  title: AppCopy.result.title,
                  leading: AppHeaderAction(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                  ),
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
