import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../core/database.dart';
import '../../core/models.dart';
import 'focus_result_screen.dart';
import 'focus_sounds.dart';
import 'sound_picker_sheet.dart';

class FocusRunningScreen extends StatefulWidget {
  const FocusRunningScreen({
    super.key,
    required this.focusMinutes,
    required this.totalPomodoros,
    required this.breakMinutes,
    required this.isPomodoro,
    required this.taskTitle,
  });

  final int focusMinutes;
  final int totalPomodoros;
  final int breakMinutes;
  final bool isPomodoro;
  final String taskTitle;

  @override
  State<FocusRunningScreen> createState() => _FocusRunningScreenState();
}

class _FocusRunningScreenState extends State<FocusRunningScreen> {
  late int _remaining; // seconds
  int _currentPomodoro = 1;
  bool _onBreak = false;
  bool _flip = false;
  bool _holding = false;
  Timer? _ticker;
  Timer? _holdTimer;
  late int _sessionStart;
  final _audio = CalmAudioPlayer();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _sessionStart = DateTime.now().millisecondsSinceEpoch;
    _remaining = widget.focusMinutes * 60;
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        _onPhaseComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _onPhaseComplete() {
    if (_onBreak) {
      // break finished -> next focus
      setState(() {
        _onBreak = false;
        _currentPomodoro++;
        _remaining = widget.focusMinutes * 60;
      });
      return;
    }
    // focus finished
    if (_currentPomodoro >= widget.totalPomodoros) {
      _finish(completed: true);
      return;
    }
    if (widget.breakMinutes > 0) {
      setState(() {
        _onBreak = true;
        _remaining = widget.breakMinutes * 60;
      });
    } else {
      setState(() {
        _currentPomodoro++;
        _remaining = widget.focusMinutes * 60;
      });
    }
  }

  Future<void> _finish({required bool completed}) async {
    _ticker?.cancel();
    _holdTimer?.cancel();
    await _audio.stop();
    final now = DateTime.now().millisecondsSinceEpoch;
    final planned = widget.focusMinutes * 60;
    final actual = ((now - _sessionStart) ~/ 1000).clamp(0, planned * 10);
    await AppDatabase.instance.insertFocusSession(FocusSessionEntity(
      taskTitle: widget.taskTitle,
      startTime: _sessionStart,
      endTime: now,
      durationSec: completed ? planned : actual,
      plannedDurationSec: planned,
      type: 'focus',
      completed: completed,
      pomodoroNumber: _currentPomodoro,
    ));
    if (!mounted) return;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => FocusResultScreen(completed: completed)),
    );
  }

  void _holdStart() {
    setState(() => _holding = true);
    _holdTimer = Timer(const Duration(milliseconds: 1400), () {
      _finish(completed: false);
    });
  }

  void _holdEnd() {
    _holdTimer?.cancel();
    setState(() => _holding = false);
  }

  Future<void> _openSounds() async {
    await showSoundPicker(
      context,
      currentId: _audio.currentId,
      onPick: (s) async {
        if (s.id == _audio.currentId) {
          await _audio.stop();
        } else {
          await _audio.play(s);
        }
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _holdTimer?.cancel();
    _audio.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (_remaining % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _holdStart(),
        onTapUp: (_) => _holdEnd(),
        onTapCancel: _holdEnd,
        child: Stack(
          children: [
            Positioned(
              top: 32,
              right: 20,
              child: Column(
                children: [
                  _topBtn(
                    _audio.currentId == 'none'
                        ? Icons.music_off
                        : Icons.music_note,
                    _audio.currentId == 'none'
                        ? const Color(0xFF9C8B7F)
                        : const Color(0xFFE8607E),
                    _openSounds,
                  ),
                  const SizedBox(height: 10),
                  _topBtn(Icons.fullscreen, const Color(0xFF9C8B7F),
                      () => setState(() => _flip = !_flip)),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _pips(),
                  const SizedBox(height: 30),
                  Transform.rotate(
                    angle: _flip ? 1.5708 : 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _clock(mm, ss),
                        const SizedBox(height: 6),
                        CustomPaint(
                          size: const Size(220, 16),
                          painter: _WavyLine(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      _onBreak
                          ? 'assets/lottie/coffee_break_dark.json'
                          : 'assets/lottie/green_bird_waiting.json',
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Text(
                _holding
                    ? 'استمرّ بالضغط لإيقاف التركيز...'
                    : _onBreak
                        ? '🍵 وقت الاستراحة • اضغط مطوّلاً للإيقاف'
                        : 'اضغط مطوّلاً للإيقاف',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 15,
                    color: Color(0xFF7A7A7A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _pips() {
    final total = widget.totalPomodoros;
    final size = total <= 4 ? 26.0 : (total <= 8 ? 20.0 : 14.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= total; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: total <= 8 ? 4 : 3),
            child: Opacity(
              opacity: i < _currentPomodoro
                  ? 0.7
                  : i == _currentPomodoro
                      ? (_onBreak ? 0.55 : 1.0)
                      : 0.4,
              child: Text('🍅', style: TextStyle(fontSize: size)),
            ),
          ),
      ],
    );
  }

  Widget _clock(String mm, String ss) {
    TextStyle digit(Color c) => TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 84,
          height: 1.0,
          letterSpacing: -3,
          color: c,
        );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mm[0], style: digit(const Color(0xFFE8607E))),
          Text(mm[1], style: digit(const Color(0xFF3FA89B))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(':',
                style: digit(Colors.white).copyWith(fontSize: 74)),
          ),
          Text(ss[0], style: digit(const Color(0xFFE8607E))),
          Text(ss[1], style: digit(const Color(0xFF3FA89B))),
        ],
      ),
    );
  }
}

class _WavyLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8607E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final h = size.height / 2;
    path.moveTo(0, h);
    for (var x = 0.0; x <= size.width; x += 2) {
      path.lineTo(x, h + 5 * math.sin(x / 12));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavyLine old) => false;
}
