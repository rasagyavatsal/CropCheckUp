import 'package:flutter/material.dart';

import '../ui/tokens/typography.dart';


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
        final boxSize = constraints.maxWidth * 0.72;
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
                painter: _CornerBracketPainter(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // Instructional text
            Positioned(
              left: 0,
              right: 0,
              top: top + boxSize + 32,
              child: Text(
                'Centre the leaf inside the frame',
                textAlign: TextAlign.center,
                style: context.typography.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: const [
                    Shadow(blurRadius: 12, color: Colors.black87),
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
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      );
    final combined = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.rect != rect;
}

/// Draws four rounded corner brackets to highlight the target region.
class _CornerBracketPainter extends CustomPainter {
  final Color color;

  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..strokeCap = StrokeCap.round;

    const len = 32.0;
    const r = 16.0;

    void drawCorner(Path path) {
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    // Top‑left
    drawCorner(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(len, 0),
    );
    // Top‑right
    drawCorner(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
        ..lineTo(size.width, len),
    );
    // Bottom‑left
    drawCorner(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height - r)
        ..arcToPoint(Offset(r, size.height), radius: const Radius.circular(r))
        ..lineTo(len, size.height),
    );
    // Bottom‑right
    drawCorner(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width - r, size.height)
        ..arcToPoint(Offset(size.width, size.height - r),
            radius: const Radius.circular(r))
        ..lineTo(size.width, size.height - len),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
