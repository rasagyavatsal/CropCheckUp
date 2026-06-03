import 'package:flutter/rendering.dart';

class ShadowTokens {
  const ShadowTokens._();

  static const List<BoxShadow> low = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% opacity black
      offset: Offset(0, 1),
      blurRadius: 3.0,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x26000000), // ~15% opacity black
      offset: Offset(0, 4),
      blurRadius: 8.0,
    ),
  ];

  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x33000000), // ~20% opacity black
      offset: Offset(0, 8),
      blurRadius: 16.0,
    ),
  ];

  static List<BoxShadow> panel(Color textPrimary) => [
    BoxShadow(
      color: textPrimary.withValues(alpha: 0.07),
      blurRadius: 26,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> elevated(Color textPrimary) => [
    BoxShadow(
      color: textPrimary.withValues(alpha: 0.1),
      blurRadius: 34,
      offset: const Offset(0, 18),
    ),
  ];
}
