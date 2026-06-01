import 'package:flutter/material.dart';

import '../ui/tokens/typography.dart';
import '../ui/tokens/shadow_tokens.dart';
import '../ui/theme/camera_theme.dart';


/// Semi‑transparent overlay drawn on top of the camera preview.
///
/// Displays a centred target rectangle with rounded corners and four decorative
/// corner brackets so the user knows where to position the leaf.
class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraTheme = Theme.of(context).extension<CameraTheme>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.maxWidth * cameraTheme.frameRatio;
        final left = (constraints.maxWidth - boxSize) / 2;
        final top = (constraints.maxHeight - boxSize) / cameraTheme.framePosition;

        return Stack(
          children: [
            // Semi‑transparent dark film
            Positioned.fill(
              child: CustomPaint(
                painter: _OverlayPainter(
                  rect: Rect.fromLTWH(left, top, boxSize, boxSize),
                  scrimColor: cameraTheme.scrim,
                  cornerRadius: cameraTheme.cornerRadius,
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
                  stroke: cameraTheme.stroke,
                  glow: cameraTheme.glow,
                  cornerLength: cameraTheme.cornerLength,
                  cornerRadius: cameraTheme.cornerRadius, // or a derived inner radius, but we use cornerRadius to avoid magic numbers
                ),
              ),
            ),
            // Instructional text
            Positioned(
              left: 0,
              right: 0,
              top: top + boxSize + cameraTheme.instructionTextSpacing,
              child: Text(
                'Centre the leaf inside the frame',
                textAlign: TextAlign.center,
                style: context.typography.body.copyWith(
                  color: cameraTheme.instructionTextColor,
                  shadows: ShadowTokens.high,
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
  final Color scrimColor;
  final double cornerRadius;

  _OverlayPainter({
    required this.rect,
    required this.scrimColor,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = scrimColor;
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
      );
    final combined = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.rect != rect ||
      old.scrimColor != scrimColor ||
      old.cornerRadius != cornerRadius;
}

/// Draws four rounded corner brackets to highlight the target region.
class _CornerBracketPainter extends CustomPainter {
  final BorderSide stroke;
  final BoxShadow glow;
  final double cornerLength;
  final double cornerRadius;

  _CornerBracketPainter({
    required this.stroke,
    required this.glow,
    required this.cornerLength,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = glow.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = glow.spreadRadius > 0 ? glow.spreadRadius : stroke.width * 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow.blurRadius)
      ..strokeCap = StrokeCap.round;

    final len = cornerLength;
    final r = cornerRadius;

    void drawCorner(Path path) {
      if (glow.color.a > 0) {
        canvas.drawPath(path, glowPaint);
      }
      canvas.drawPath(path, paint);
    }

    // Top‑left
    drawCorner(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..arcToPoint(Radius.circular(r) != Radius.zero ? Offset(r, 0) : Offset.zero, radius: Radius.circular(r))
        ..lineTo(len, 0),
    );
    // Top‑right
    drawCorner(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Radius.circular(r) != Radius.zero ? Offset(size.width, r) : Offset(size.width, 0), radius: Radius.circular(r))
        ..lineTo(size.width, len),
    );
    // Bottom‑left
    drawCorner(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height - r)
        ..arcToPoint(Radius.circular(r) != Radius.zero ? Offset(r, size.height) : Offset(0, size.height), radius: Radius.circular(r), clockwise: false)
        ..lineTo(len, size.height),
    );
    // Bottom‑right
    drawCorner(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width - r, size.height)
        ..arcToPoint(Radius.circular(r) != Radius.zero ? Offset(size.width, size.height - r) : Offset(size.width, size.height),
            radius: Radius.circular(r), clockwise: false)
        ..lineTo(size.width, size.height - len),
    );
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) =>
      oldDelegate.stroke != stroke ||
      oldDelegate.glow != glow ||
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.cornerRadius != cornerRadius;
}
