import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';
import 'package:crop_check_up/ui/copy/app_copy.dart';

class EvidenceImageCard extends StatelessWidget {
  final Uint8List imageBytes;

  const EvidenceImageCard({
    super.key,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const radius = RadiusTokens();

    return Container(
      decoration: BoxDecoration(
        color: colors.raisedSurface,
        borderRadius: BorderRadius.circular(radius.xl),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.xl),
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
      ),
    );
  }
}
