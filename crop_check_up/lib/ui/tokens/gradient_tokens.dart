import 'package:flutter/material.dart';

class GradientTokens extends ThemeExtension<GradientTokens> {
  final LinearGradient brandHeader;
  final LinearGradient cameraOverlay;
  final LinearGradient healthyStatus;
  final LinearGradient dangerStatus;
  final LinearGradient neutralStatus;
  final LinearGradient previewBackdrop;

  const GradientTokens({
    required this.brandHeader,
    required this.cameraOverlay,
    required this.healthyStatus,
    required this.dangerStatus,
    required this.neutralStatus,
    required this.previewBackdrop,
  });

  @override
  GradientTokens copyWith({
    LinearGradient? brandHeader,
    LinearGradient? cameraOverlay,
    LinearGradient? healthyStatus,
    LinearGradient? dangerStatus,
    LinearGradient? neutralStatus,
    LinearGradient? previewBackdrop,
  }) {
    return GradientTokens(
      brandHeader: brandHeader ?? this.brandHeader,
      cameraOverlay: cameraOverlay ?? this.cameraOverlay,
      healthyStatus: healthyStatus ?? this.healthyStatus,
      dangerStatus: dangerStatus ?? this.dangerStatus,
      neutralStatus: neutralStatus ?? this.neutralStatus,
      previewBackdrop: previewBackdrop ?? this.previewBackdrop,
    );
  }

  @override
  ThemeExtension<GradientTokens> lerp(
    covariant ThemeExtension<GradientTokens>? other,
    double t,
  ) {
    if (other is! GradientTokens) {
      return this;
    }
    return GradientTokens(
      brandHeader: LinearGradient.lerp(brandHeader, other.brandHeader, t)!,
      cameraOverlay: LinearGradient.lerp(cameraOverlay, other.cameraOverlay, t)!,
      healthyStatus: LinearGradient.lerp(healthyStatus, other.healthyStatus, t)!,
      dangerStatus: LinearGradient.lerp(dangerStatus, other.dangerStatus, t)!,
      neutralStatus: LinearGradient.lerp(neutralStatus, other.neutralStatus, t)!,
      previewBackdrop: LinearGradient.lerp(previewBackdrop, other.previewBackdrop, t)!,
    );
  }

  static const GradientTokens light = GradientTokens(
    brandHeader: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
    ),
    cameraOverlay: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
    ),
    healthyStatus: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
    ),
    dangerStatus: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
    ),
    neutralStatus: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF757575), Color(0xFF424242)],
    ),
    previewBackdrop: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black,
        Color(0x1A43A047), // AppTheme.healthyGreen with 0.1 alpha
        Colors.black,
      ],
    ),
  );

  static const GradientTokens dark = GradientTokens(
    brandHeader: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A3926), Color(0xFF1A4936)], // dark theme surfaces
    ),
    cameraOverlay: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A4936), Color(0xFF0A3926)],
    ),
    healthyStatus: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF5DF2B5), Color(0xFF2E7D32)],
    ),
    dangerStatus: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB4AB), Color(0xFFE53935)],
    ),
    neutralStatus: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFBFC9C2), Color(0xFF8A938C)],
    ),
    previewBackdrop: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black,
        Color(0x1A5DF2B5), // dark semantic success brand with 0.1 alpha
        Colors.black,
      ],
    ),
  );
}
