import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/diagnosis_result.dart';
import '../ui/tokens/typography.dart';
import '../ui/components/diagnosis/result_presentation_view.dart';
import '../widgets/header_background.dart';

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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            stretch: true,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Diagnosis Result',
                style: context.typography.title.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              background: HeaderBackground(
                title: 'Diagnosis Result',
                subtitle: result.isHealthy ? 'HEALTHY PLANT' : 'DISEASE DETECTED',
                icon: statusIcon,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ResultPresentationView(
              result: result,
              imageBytes: imageBytes,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
