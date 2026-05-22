import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Animated water-glass painter shared by the big tracker view and the
/// small floating cup. [progress] is 0..1.
class WaterGlass extends StatefulWidget {
  const WaterGlass({
    super.key,
    required this.progress,
    this.baseline = 0.0,
    this.strokeWidth = 6,
  });

  final double progress;
  final double baseline; // minimum visible fill fraction
  final double strokeWidth;

  @override
  State<WaterGlass> createState() => _WaterGlassState();
}

class _WaterGlassState extends State<WaterGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wave,
      builder: (context, _) => CustomPaint(
        painter: _GlassPainter(
          progress: widget.progress.clamp(0.0, 1.0),
          phase: _wave.value * 2 * math.pi,
          baseline: widget.baseline,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.progress,
    required this.phase,
    required this.baseline,
    required this.strokeWidth,
  });

  final double progress;
  final double phase;
  final double baseline;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final padX = w * 0.18;
    final topY = h * 0.16;
    final bottomY = h * 0.9;
    final cup = Path()
      ..moveTo(padX, topY)
      ..lineTo(w - padX, topY)
      ..lineTo(w - padX * 1.5, bottomY)
      ..quadraticBezierTo(w / 2, bottomY + h * 0.04, padX * 1.5, bottomY)
      ..close();

    canvas.save();
    canvas.clipPath(cup);

    final fillFrac = baseline + (1 - baseline) * progress;
    final waterTop = topY + (bottomY - topY) * (1 - fillFrac);

    void wave(Color color, double amp, double shift) {
      final p = Path()..moveTo(0, h);
      for (var x = 0.0; x <= w; x += 4) {
        final y = waterTop + amp * math.sin(x / w * 2 * math.pi * 2 + phase + shift);
        if (x == 0) {
          p.moveTo(x, y);
        } else {
          p.lineTo(x, y);
        }
      }
      p
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(p, Paint()..color = color);
    }

    wave(AppColors.waterDark, 6, 1.2);
    wave(AppColors.waterBlue, 8, 0);
    canvas.restore();

    canvas.drawPath(
      cup,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.progress != progress || old.phase != phase;
}
