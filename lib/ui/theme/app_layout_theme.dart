import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';
import 'package:crop_check_up/ui/tokens/size_tokens.dart';

class AppLayoutTheme extends ThemeExtension<AppLayoutTheme> {
  final SpacingTokens spacing;
  final RadiusTokens radius;
  final SizeTokens sizes;

  const AppLayoutTheme({
    this.spacing = const SpacingTokens(),
    this.radius = const RadiusTokens(),
    this.sizes = const SizeTokens(),
  });

  @override
  AppLayoutTheme copyWith({
    SpacingTokens? spacing,
    RadiusTokens? radius,
    SizeTokens? sizes,
  }) {
    return AppLayoutTheme(
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      sizes: sizes ?? this.sizes,
    );
  }

  @override
  ThemeExtension<AppLayoutTheme> lerp(ThemeExtension<AppLayoutTheme>? other, double t) {
    // Layout values typically don't animate between themes, but we can return the target if it changes.
    if (other is! AppLayoutTheme) return this;
    return other; // Or simply return this if we want them constant
  }
}
