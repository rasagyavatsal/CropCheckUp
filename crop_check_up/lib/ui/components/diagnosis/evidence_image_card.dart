import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/components/cards/app_card.dart';

class EvidenceImageCard extends StatelessWidget {
  final Uint8List imageBytes;

  const EvidenceImageCard({
    super.key,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.image(
      image: Image.memory(
        imageBytes,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
