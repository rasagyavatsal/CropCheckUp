import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/diagnosis_result.dart';
import '../ui/copy/app_copy.dart';
import '../ui/components/diagnosis/result_presentation_view.dart';
import '../ui/components/layout/app_page_shell.dart';
import '../ui/components/layout/app_bottom_action_bar.dart';
import '../ui/components/headers/app_headers.dart';
import '../ui/components/buttons/app_button.dart';

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
    final statusIcon =
        result.isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded;

    return AppPageShell.sliver(
      slivers: [
        AppStatusHeader(
          title: AppCopy.result.title,
          subtitle: result.isHealthy ? AppCopy.result.statusHealthy : AppCopy.result.statusDisease,
          statusIcon: statusIcon,
          isHealthy: result.isHealthy,
          leading: const BackButton(color: Colors.white),
        ),
        SliverToBoxAdapter(
          child: ResultPresentationView(
            result: result,
            imageBytes: imageBytes,
          ),
        ),
      ],
      bottomNavigationBar: AppBottomActionBar(
        child: SizedBox(
          width: double.infinity,
          child: AppButton.primary(
            label: AppCopy.result.actionDone,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
