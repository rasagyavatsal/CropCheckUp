import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';
import 'package:crop_check_up/ui/components/app_components.dart';

class EvidenceImageCard extends StatelessWidget {
  final Uint8List imageBytes;

  const EvidenceImageCard({
    super.key,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      padding: EdgeInsets.zero,
      child: Semantics(
        image: true,
        label: AppCopy.result.semanticEvidenceImage,
        child: Image.memory(
          imageBytes,
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
