import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/components/cards/app_card.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';

class AppImagePanel extends StatelessWidget {
  final Uint8List imageBytes;
  final String semanticLabel;
  final double? height;
  final Object? heroTag;

  const AppImagePanel({
    super.key,
    required this.imageBytes,
    required this.semanticLabel,
    this.height,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens();
    
    Widget imageWidget = Image.memory(
      imageBytes,
      fit: BoxFit.contain,
    );

    if (height != null) {
      imageWidget = SizedBox(
        height: height,
        width: double.infinity,
        child: imageWidget,
      );
    }

    Widget semanticImage = Semantics(
      image: true,
      label: semanticLabel,
      child: Padding(
        padding: EdgeInsets.all(spacing.m),
        child: imageWidget,
      ),
    );

    if (heroTag != null) {
      semanticImage = Hero(
        tag: heroTag!,
        child: semanticImage,
      );
    }

    return AppCard.panel(
      child: semanticImage,
    );
  }
}
