import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/components/cards/app_card.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';

class EvidenceImageCard extends StatelessWidget {
  final Uint8List imageBytes;

  const EvidenceImageCard({
    super.key,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.image(
      image: Semantics(
        image: true,
        label: AppCopy.result.semanticEvidenceImage,
        child: Image.memory(
          imageBytes,
          height: 240,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
