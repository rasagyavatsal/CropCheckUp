import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Semi‑transparent overlay drawn on top of the camera preview.
///
/// Displays a centred target rectangle with rounded corners and four decorative
/// corner brackets so the user knows where to position the leaf.
class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - boxSize) / 2;
        final top = (constraints.maxHeight - boxSize) / 2.5;

        return Stack(
          children: [
            // Semi‑transparent dark film
            Positioned.fill(
              child: CustomPaint(
                painter: _OverlayPainter(
                  rect: Rect.fromLTWH(left, top, boxSize, boxSize),
                ),
              ),
            ),
            // Target box corners
            Positioned(
              left: left,
              top: top,
              width: boxSize,
              height: boxSize,
              child: CustomPaint(
                painter: _CornerBracketPainter(),
              ),
            ),
            // Instructional text
            Positioned(
              left: 0,
              right: 0,
              top: top + boxSize + 24,
              child: Text(
                'Centre the leaf inside the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  shadows: const [
                    Shadow(blurRadius: 8, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Custom painters
// -----------------------------------------------------------------------------

/// Fills the entire canvas with a dark scrim, cutting out the target rectangle.
class _OverlayPainter extends CustomPainter {
  final Rect rect;
  _OverlayPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      );
    final combined = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.rect != rect;
}

/// Draws four rounded corner brackets to highlight the target region.
class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.healthyGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const len = 30.0;
    const r = 12.0;

    // Top‑left
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(len, 0),
      paint,
    );
    // Top‑right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
        ..lineTo(size.width, len),
      paint,
    );
    // Bottom‑left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height - r)
        ..arcToPoint(Offset(r, size.height), radius: const Radius.circular(r))
        ..lineTo(len, size.height),
      paint,
    );
    // Bottom‑right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width - r, size.height)
        ..arcToPoint(Offset(size.width, size.height - r),
            radius: const Radius.circular(r))
        ..lineTo(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
