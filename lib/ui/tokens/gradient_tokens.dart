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
      cameraOverlay:
          LinearGradient.lerp(cameraOverlay, other.cameraOverlay, t)!,
      healthyStatus:
          LinearGradient.lerp(healthyStatus, other.healthyStatus, t)!,
      dangerStatus: LinearGradient.lerp(dangerStatus, other.dangerStatus, t)!,
      neutralStatus:
          LinearGradient.lerp(neutralStatus, other.neutralStatus, t)!,
      previewBackdrop:
          LinearGradient.lerp(previewBackdrop, other.previewBackdrop, t)!,
    );
  }

  static const GradientTokens light = GradientTokens(
    brandHeader: _StandardGradient([Color(0xFFFFFFFF), Color(0xFFF5F8F4)]),
    cameraOverlay: _StandardGradient([Color(0xFF1F7A4D), Color(0xFF0F5F8F)]),
    healthyStatus: _StandardGradient([Color(0xFF1F7A4D), Color(0xFFEFF7F1)]),
    dangerStatus: _StandardGradient([Color(0xFFB42318), Color(0xFFFFF2F0)]),
    neutralStatus: _StandardGradient([Color(0xFF0F5F8F), Color(0xFFEEF5ED)]),
    previewBackdrop: _VerticalGradient([Color(0xFFFFFFFF), Color(0xFFF5F8F4), Color(0xFFFFFFFF)]),
  );

  static const GradientTokens dark = GradientTokens(
    brandHeader: _StandardGradient([Colors.black, Color(0xFF050505)]),
    cameraOverlay: _StandardGradient([Color(0xFF0B0B0B), Color(0xFF0F5F8F)]),
    healthyStatus: _StandardGradient([Color(0xFF0B0B0B), Color(0xFF5BB07E)]),
    dangerStatus: _StandardGradient([Color(0xFF0B0B0B), Color(0xFFFFB4AB)]),
    neutralStatus: _StandardGradient([Color(0xFF0B0B0B), Color(0xFF6DAED6)]),
    previewBackdrop: _VerticalGradient([Colors.black, Color(0xFF050505), Colors.black]),
  );
}

class _StandardGradient extends LinearGradient {
  const _StandardGradient(List<Color> colors)
      : super(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        );
}

class _VerticalGradient extends LinearGradient {
  const _VerticalGradient(List<Color> colors)
      : super(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        );
}
