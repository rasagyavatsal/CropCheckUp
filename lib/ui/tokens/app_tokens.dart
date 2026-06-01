import 'package:flutter/material.dart';
import 'gradient_tokens.dart';

extension GradientTokensExtension on BuildContext {
  GradientTokens get gradient => Theme.of(this).extension<GradientTokens>()!;
}

class AppTokens {
  const AppTokens();
}
