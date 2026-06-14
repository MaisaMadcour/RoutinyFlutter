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
    // proportions ported 1:1 from the Kotlin WaterGlassView
    final padX = w * 0.18;
    final topY = h * 0.18;
    final bottomY = h * 0.88;
    final topLeft = padX;
    final topRight = w - padX;
    final bottomLeft = padX + w * 0.06;
    final bottomRight = w - padX - w * 0.06;

    final cup = Path()
      ..moveTo(topLeft, topY)
      ..lineTo(topRight, topY)
      ..lineTo(bottomRight, bottomY)
      ..quadraticBezierTo(w / 2, bottomY + h * 0.05, bottomLeft, bottomY)
      ..close();

    final rim = Path()
      ..addOval(Rect.fromLTRB(
          topLeft, topY - h * 0.035, topRight, topY + h * 0.035));

    canvas.save();
    canvas.clipPath(cup);

    // fill height = progress, lifted by an optional baseline floor (0 = none)
    final fillFrac = baseline + (1 - baseline) * progress;
    final waterTop = h - h * fillFrac;

    void wave(Color color, double amp, double phaseScale) {
      final p = Path()..moveTo(0, waterTop);
      const segments = 24;
      for (var i = 0; i <= segments; i++) {
        final x = w * i / segments;
        final y = waterTop +
            amp *
                math.sin(phase * phaseScale +
                    (i / segments) * 2 * math.pi * 1.5);
        p.lineTo(x, y);
      }
      p
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(p, Paint()..color = color..isAntiAlias = true);
    }

    wave(AppColors.waterDark, 6, 0.7); // back wave (deeper, slower)
    wave(AppColors.waterBlue, 8, 1.0); // front wave

    // glossy highlight line inside the glass
    canvas.drawPath(
      Path()
        ..moveTo(topLeft + w * 0.05, topY + h * 0.10)
        ..lineTo(topLeft + w * 0.10, bottomY - h * 0.12),
      Paint()
        ..color = const Color(0xA0FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // cup outline + rim with a soft shadow
    final outline = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawShadow(cup, const Color(0x40000000), 4, false);
    canvas.drawPath(cup, outline);
    canvas.drawPath(rim, outline);
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.progress != progress || old.phase != phase;
}
