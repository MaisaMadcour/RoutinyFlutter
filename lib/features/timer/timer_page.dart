import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../theme/app_colors.dart';
import 'focus_running_screen.dart';
import 'focus_settings.dart';
import 'focus_stats_screen.dart';
import 'minutes_picker_sheet.dart';
import 'pomodoro_settings_screen.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool _pomodoro = true;
  int _pomodoroMinutes = 25;
  int _timerMinutes = 1;

  @override
  void initState() {
    super.initState();
    _pomodoroMinutes = FocusSettings.pomodoroMinutes;
  }

  int get _minutes => _pomodoro ? _pomodoroMinutes : _timerMinutes;

  Future<void> _pickMinutes() async {
    final v = await showMinutesPicker(
      context,
      title: _pomodoro ? S.pomodoroDurationTitle : S.timerDurationTitle,
      min: 1,
      max: 120,
      initial: _minutes,
    );
    if (v == null) return;
    setState(() {
      if (_pomodoro) {
        _pomodoroMinutes = v;
        FocusSettings.pomodoroMinutes = v;
      } else {
        _timerMinutes = v;
      }
    });
  }

  void _start() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FocusRunningScreen(
          focusMinutes: _minutes,
          totalPomodoros: _pomodoro ? FocusSettings.pomodoroCycle : 1,
          breakMinutes: _pomodoro ? FocusSettings.shortBreakMinutes : 0,
          isPomodoro: _pomodoro,
          taskTitle: _pomodoro ? 'تركيز' : 'تايم',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _modeTabs(),
            const Spacer(flex: 2),
            _timerCircle(),
            const SizedBox(height: 20),
            _focusDropdown(),
            const Spacer(flex: 3),
            _actionRow(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _modeTabs() {
    Widget tab(String label, bool active, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding:
              const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active
                      ? AppColors.chocolate
                      : AppColors.mutedTab)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DCD0),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab('بومودورو', _pomodoro, () => setState(() => _pomodoro = true)),
          tab('تايم', !_pomodoro, () => setState(() => _pomodoro = false)),
        ],
      ),
    );
  }

  // force Latin (English) digits regardless of the device locale
  String _toLatin(String s) {
    const ar = '٠١٢٣٤٥٦٧٨٩';
    return s.split('').map((c) {
      final i = ar.indexOf(c);
      return i >= 0 ? '$i' : c;
    }).join();
  }

  Widget _timerCircle() {
    final mm = _minutes.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: _pickMinutes,
      child: SizedBox(
        width: 360,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(330, 150),
              painter: _HandDrawnOval(),
            ),
            // hand-drawn stars (pomodoro) — same colour as the oval
            if (_pomodoro) ...[
              Positioned(
                  left: 30,
                  top: 18,
                  child: CustomPaint(
                      size: const Size(28, 28),
                      painter: _HandDrawnStar())),
              Positioned(
                  right: 36,
                  bottom: 20,
                  child: CustomPaint(
                      size: const Size(20, 20),
                      painter: _HandDrawnStar())),
            ],
            // hand-drawn hearts (timer) — same colour as the oval
            if (!_pomodoro) ...[
              Positioned(
                  right: 28,
                  top: 14,
                  child: CustomPaint(
                      size: const Size(26, 26),
                      painter: _HandDrawnHeart())),
              Positioned(
                  right: 60,
                  bottom: 18,
                  child: CustomPaint(
                      size: const Size(18, 18),
                      painter: _HandDrawnHeart())),
            ],
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${_toLatin(mm)}:00',
                style: const TextStyle(
                  fontFamily: 'InterDisplay',
                  fontSize: 84,
                  height: 1.0,
                  letterSpacing: -3,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _focusDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text('تركيز',
            style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 17,
                color: AppColors.mutedTab)),
        SizedBox(width: 6),
        Text('‹',
            style: TextStyle(fontSize: 20, color: AppColors.ribbonNeutral)),
      ],
    );
  }

  Widget _actionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _circleBtn(Icons.settings_outlined, () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PomodoroSettingsScreen()));
            setState(() => _pomodoroMinutes = FocusSettings.pomodoroMinutes);
          }),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 62,
              child: ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: Text(_pomodoro ? S.startFocus : S.startTimer,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          _circleBtn(Icons.history, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const FocusStatsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFF3E6DD),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1C1C1C), size: 24),
      ),
    );
  }
}

/// A doodle-style wobbly oval stroke around the timer digits.
class _HandDrawnOval extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2 - 6;
    final ry = size.height / 2 - 6;
    final paint = Paint()
      ..color = const Color(0xFFE3A593)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const steps = 80;
    for (var pass = 0; pass < 2; pass++) {
      final path = Path();
      for (var i = 0; i <= steps; i++) {
        final t = i / steps * 2 * math.pi;
        final wobble = math.sin(t * 5 + pass) * 4 + math.cos(t * 3) * 3;
        final x = cx + (rx + wobble) * math.cos(t) + pass * 2;
        final y = cy + (ry + wobble) * math.sin(t) - pass * 1.5;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        paint..color = Color.fromARGB(pass == 0 ? 235 : 130, 227, 165, 147),
      );
    }
  }

  @override
  bool shouldRepaint(_HandDrawnOval old) => false;
}

const _doodleColor = Color(0xFFE3A593); // same hue as the hand-drawn oval

/// A doodle-style 5-point star, sketched with a slightly wobbly stroke.
class _HandDrawnStar extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2 - 1.5;
    final inner = outer * 0.42;
    final paint = Paint()
      ..color = _doodleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i <= 10; i++) {
      final r = i.isEven ? outer : inner;
      // start pointing up, add a tiny wobble for the hand-drawn feel
      final a = -math.pi / 2 + i * math.pi / 5;
      final wob = math.sin(i * 2.0) * 0.6;
      final x = cx + (r + wob) * math.cos(a);
      final y = cy + (r + wob) * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HandDrawnStar old) => false;
}

/// A doodle-style heart outline, sketched with a wobbly stroke.
class _HandDrawnHeart extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = _doodleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.10
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const steps = 60;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps * 2 * math.pi;
      // classic heart parametric curve, normalised into the box
      final hx = 16 * math.pow(math.sin(t), 3).toDouble();
      final hy = 13 * math.cos(t) -
          5 * math.cos(2 * t) -
          2 * math.cos(3 * t) -
          math.cos(4 * t);
      final wob = math.sin(t * 6) * 0.25;
      final x = w / 2 + (hx + wob) / 17 * (w / 2);
      final y = h / 2 - (hy + wob) / 17 * (h / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HandDrawnHeart old) => false;
}
