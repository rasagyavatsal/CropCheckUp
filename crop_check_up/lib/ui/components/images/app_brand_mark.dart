import 'package:flutter/material.dart';

class AppBrandMark extends StatelessWidget {
  final double size;

  const AppBrandMark({
    super.key,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
