import 'package:flutter/material.dart';

import '../../theme/theme_ext.dart';

class AppGridBackground extends StatelessWidget {
  final Widget child;

  const AppGridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final brightness = Theme.of(context).brightness;
    final opacity = brightness == Brightness.light ? 0.038 : 0.10;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _AppGridPainter(
                color: colors.textPrimary.withValues(alpha: opacity),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AppGridPainter extends CustomPainter {
  final Color color;

  const _AppGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const step = 48.0;
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;

    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AppGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
