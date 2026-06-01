import 'dart:ui';
import 'package:flutter/material.dart';

class CameraTheme extends ThemeExtension<CameraTheme> {
  final Color scrim;
  final double frameRatio;
  final double framePosition;
  final BorderSide stroke;
  final BoxShadow glow;
  final BoxDecoration captureControlStyling;
  final double cornerRadius;
  final double cornerLength;
  final double instructionTextSpacing;
  final Color instructionTextColor;

  const CameraTheme({
    required this.scrim,
    required this.frameRatio,
    required this.framePosition,
    required this.stroke,
    required this.glow,
    required this.captureControlStyling,
    required this.cornerRadius,
    required this.cornerLength,
    required this.instructionTextSpacing,
    required this.instructionTextColor,
  });

  @override
  CameraTheme copyWith({
    Color? scrim,
    double? frameRatio,
    double? framePosition,
    BorderSide? stroke,
    BoxShadow? glow,
    BoxDecoration? captureControlStyling,
    double? cornerRadius,
    double? cornerLength,
    double? instructionTextSpacing,
    Color? instructionTextColor,
  }) {
    return CameraTheme(
      scrim: scrim ?? this.scrim,
      frameRatio: frameRatio ?? this.frameRatio,
      framePosition: framePosition ?? this.framePosition,
      stroke: stroke ?? this.stroke,
      glow: glow ?? this.glow,
      captureControlStyling: captureControlStyling ?? this.captureControlStyling,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      cornerLength: cornerLength ?? this.cornerLength,
      instructionTextSpacing: instructionTextSpacing ?? this.instructionTextSpacing,
      instructionTextColor: instructionTextColor ?? this.instructionTextColor,
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
      cornerRadius: lerpDouble(cornerRadius, other.cornerRadius, t) ?? cornerRadius,
      cornerLength: lerpDouble(cornerLength, other.cornerLength, t) ?? cornerLength,
      instructionTextSpacing: lerpDouble(instructionTextSpacing, other.instructionTextSpacing, t) ?? instructionTextSpacing,
      instructionTextColor: Color.lerp(instructionTextColor, other.instructionTextColor, t)!,
    );
  }

  static CameraTheme light(Color scrimColor) => CameraTheme(
    scrim: scrimColor,
    frameRatio: 0.72,
    framePosition: 2.5,
    stroke: const BorderSide(color: Colors.white, width: 4.0),
    glow: const BoxShadow(color: Color(0x4DFFFFFF), blurRadius: 4.0, spreadRadius: 0.0), // color is white with 0.3 opacity
    captureControlStyling: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade300, width: 4.0),
    ),
    cornerRadius: 24.0, // Used to be 24 and 16, let's use 24 for outer, 16 for inner maybe? The issue says remove magic radii. Let's make it 24.0. Wait, cornerBracket used 16.0. Let's make cornerRadius 24.0 and we can derive inner.
    cornerLength: 32.0,
    instructionTextSpacing: 32.0,
    instructionTextColor: Colors.white,
  );

  static CameraTheme dark(Color scrimColor) => CameraTheme(
    scrim: scrimColor,
    frameRatio: 0.72,
    framePosition: 2.5,
    stroke: const BorderSide(color: Colors.white, width: 4.0),
    glow: const BoxShadow(color: Color(0x4DFFFFFF), blurRadius: 4.0, spreadRadius: 0.0),
    captureControlStyling: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade700, width: 4.0),
    ),
    cornerRadius: 24.0,
    cornerLength: 32.0,
    instructionTextSpacing: 32.0,
    instructionTextColor: Colors.white,
  );
}
