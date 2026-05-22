import 'package:flutter/material.dart';

/// Paints a dashed rounded-rectangle border.
class DashedRectPainter extends CustomPainter {
  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 20,
    this.dash = 6,
    this.gap = 5,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Offset(strokeWidth / 2, strokeWidth / 2) &
          Size(size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(
          metric.extractPath(dist, next.clamp(0, metric.length)),
          paint,
        );
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// Clips a banner/ribbon shape: a rectangle with a triangular notch
/// cut into its trailing (end) edge.
class RibbonClipper extends CustomClipper<Path> {
  RibbonClipper({this.notch = 13});
  final double notch;

  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    // In RTL the ribbon flows from the right; the notch is on the left edge.
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..lineTo(notch, h / 2)
      ..close();
  }

  @override
  bool shouldReclip(RibbonClipper old) => old.notch != notch;
}
