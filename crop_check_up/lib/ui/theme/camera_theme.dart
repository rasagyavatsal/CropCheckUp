import 'dart:ui';
import 'package:flutter/material.dart';

class CameraTheme extends ThemeExtension<CameraTheme> {
  final Color scrim;
  final double frameRatio;
  final double framePosition;
  final BorderSide stroke;
  final BoxShadow glow;
  final BoxDecoration captureControlStyling;

  const CameraTheme({
    required this.scrim,
    required this.frameRatio,
    required this.framePosition,
    required this.stroke,
    required this.glow,
    required this.captureControlStyling,
  });

  @override
  CameraTheme copyWith({
    Color? scrim,
    double? frameRatio,
    double? framePosition,
    BorderSide? stroke,
    BoxShadow? glow,
    BoxDecoration? captureControlStyling,
  }) {
    return CameraTheme(
      scrim: scrim ?? this.scrim,
      frameRatio: frameRatio ?? this.frameRatio,
      framePosition: framePosition ?? this.framePosition,
      stroke: stroke ?? this.stroke,
      glow: glow ?? this.glow,
      captureControlStyling: captureControlStyling ?? this.captureControlStyling,
    );
  }

  @override
  ThemeExtension<CameraTheme> lerp(ThemeExtension<CameraTheme>? other, double t) {
    if (other is! CameraTheme) return this;
    return CameraTheme(
      scrim: Color.lerp(scrim, other.scrim, t)!,
      frameRatio: lerpDouble(frameRatio, other.frameRatio, t) ?? frameRatio,
      framePosition: lerpDouble(framePosition, other.framePosition, t) ?? framePosition,
      stroke: BorderSide.lerp(stroke, other.stroke, t),
      glow: BoxShadow.lerp(glow, other.glow, t) ?? glow,
      captureControlStyling: BoxDecoration.lerp(captureControlStyling, other.captureControlStyling, t) ?? captureControlStyling,
    );
  }

  static CameraTheme light(Color scrimColor) => CameraTheme(
    scrim: scrimColor,
    frameRatio: 1.0, // Square frame
    framePosition: 0.4, // Slightly above center
    stroke: const BorderSide(color: Colors.white, width: 2.0),
    glow: const BoxShadow(color: Colors.black26, blurRadius: 8.0, spreadRadius: 2.0),
    captureControlStyling: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade300, width: 4.0),
    ),
  );

  static CameraTheme dark(Color scrimColor) => CameraTheme(
    scrim: scrimColor,
    frameRatio: 1.0,
    framePosition: 0.4,
    stroke: const BorderSide(color: Colors.white, width: 2.0),
    glow: const BoxShadow(color: Colors.black54, blurRadius: 8.0, spreadRadius: 2.0),
    captureControlStyling: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade700, width: 4.0),
    ),
  );
}
