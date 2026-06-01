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
    return AppImagePanel(
      imageBytes: imageBytes,
      semanticLabel: AppCopy.result.semanticEvidenceImage,
      height: 260,
    );
  }
}
