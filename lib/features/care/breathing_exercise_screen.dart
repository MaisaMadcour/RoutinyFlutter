import 'dart:async';
import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

enum _Phase { inhale, hold, exhale }

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _circle;
  _Phase _phase = _Phase.inhale;
  int _breaths = 0;
  bool _paused = false;
  Timer? _phaseTimer;

  static const _durations = {
    _Phase.inhale: Duration(seconds: 4),
    _Phase.hold: Duration(seconds: 4),
    _Phase.exhale: Duration(seconds: 6),
  };

  @override
  void initState() {
    super.initState();
    _circle = AnimationController(vsync: this, duration: _durations[_Phase.inhale]);
    _runPhase();
  }

  void _runPhase() {
    if (_paused) return;
    switch (_phase) {
      case _Phase.inhale:
        _circle.duration = _durations[_Phase.inhale];
        _circle.forward(from: 0);
        break;
      case _Phase.hold:
        break;
      case _Phase.exhale:
        _circle.duration = _durations[_Phase.exhale];
        _circle.reverse(from: 1);
        break;
    }
    _phaseTimer = Timer(_durations[_phase]!, () {
      if (!mounted || _paused) return;
      setState(() {
        switch (_phase) {
          case _Phase.inhale:
            _phase = _Phase.hold;
            break;
          case _Phase.hold:
            _phase = _Phase.exhale;
            break;
          case _Phase.exhale:
            _phase = _Phase.inhale;
            _breaths++;
            break;
        }
      });
      _runPhase();
    });
  }

  String get _label {
    switch (_phase) {
      case _Phase.inhale:
        return 'شهيق';
      case _Phase.hold:
        return 'امسكي';
      case _Phase.exhale:
        return 'الزفير';
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _circle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E4756),
      body: GestureDetector(
        onLongPress: () => Navigator.pop(context),
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _circle,
                      builder: (context, _) {
                        final scale = 0.6 + 0.4 * _circle.value;
                        return Container(
                          width: 240 * scale,
                          height: 240 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0.08),
                            ]),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(_label,
                              style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                    Text('$_breaths نفس',
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 18,
                            color: Colors.white70)),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    _paused ? 'متوقف مؤقتاً' : 'اضغطي مطولاً للخروج',
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
