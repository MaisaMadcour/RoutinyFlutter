import 'dart:math' as math;
import 'package:flutter/material.dart';

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
      title: _pomodoro ? 'اضبط مدة البومودورو' : 'اضبط مدة المؤقت',
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
          taskTitle: _pomodoro ? 'تركيز' : 'مؤقت',
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
          tab('مؤقت', !_pomodoro, () => setState(() => _pomodoro = false)),
        ],
      ),
    );
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
            if (_pomodoro) ...const [
              Positioned(
                  left: 30, top: 18, child: Text('✨', style: TextStyle(fontSize: 26))),
              Positioned(
                  right: 36,
                  bottom: 20,
                  child: Text('✨', style: TextStyle(fontSize: 18))),
            ],
            if (!_pomodoro) ...const [
              Positioned(
                  right: 28, top: 14, child: Text('🤍', style: TextStyle(fontSize: 24))),
              Positioned(
                  right: 60,
                  bottom: 18,
                  child: Text('🤍', style: TextStyle(fontSize: 16))),
            ],
            Text(
              '$mm:00',
              style: const TextStyle(
                fontFamily: 'InterDisplay',
                fontSize: 84,
                height: 1.0,
                letterSpacing: -3,
                color: AppColors.textDark,
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
                child: Text(_pomodoro ? 'ابدأ التركيز' : 'ابدأ المؤقت',
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
