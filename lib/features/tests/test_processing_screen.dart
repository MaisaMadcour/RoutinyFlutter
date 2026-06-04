import 'package:flutter/material.dart';

import '../../core/ads/interstitial_manager.dart';
import '../../core/image_palette.dart';
import '../../theme/app_colors.dart';
import 'test_models.dart';
import 'test_result_screen.dart';

class TestProcessingScreen extends StatefulWidget {
  const TestProcessingScreen({
    super.key,
    required this.test,
    required this.score,
    required this.maxScore,
  });
  final MentalTest test;
  final int score;
  final int maxScore;

  @override
  State<TestProcessingScreen> createState() => _TestProcessingScreenState();
}

class _TestProcessingScreenState extends State<TestProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Color _edge;
  bool _navigated = false;

  static const _steps = [
    'تحليل المشاعر والحالة النفسية',
    'تحليل الدعم والعلاقات الاجتماعية',
    'تحليل التأثير على الهوية والسلوك',
  ];

  @override
  void initState() {
    super.initState();
    _edge = AppColors.parseHex(widget.test.cardBgColor);
    ImagePalette.from(
      'assets/images/${widget.test.coverAsset}.jpg',
      fallback: AppColors.parseHex(widget.test.cardBgColor),
    ).then((c) { if (mounted) setState(() => _edge = c); });

    // 0 → 100% over 5 s, linear (matches Android DURATION_MS = 5000)
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..addListener(() {
        if (_ctrl.value >= 1.0 && !_navigated) {
          _navigated = true;
          _goToResult();
        } else {
          setState(() {});
        }
      });
    _ctrl.forward();
  }

  void _goToResult() {
    final tier = ((widget.score / widget.maxScore) * widget.test.resultTiers.length)
        .floor()
        .clamp(0, widget.test.resultTiers.length - 1);
    // show an interstitial (cap 5 min) before the result, then navigate
    InterstitialManager.instance.showIfReady(
      InterstitialManager.ctxTestResult,
      onDone: () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TestResultScreen(test: widget.test, tierIndex: tier),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_ctrl.value * 100).round();
    return Scaffold(
      backgroundColor: _edge,
      body: SafeArea(
        child: Stack(
          children: [
            // ── title near the top ─────────────────────────────────────
            Positioned(
              top: 80,
              left: 28,
              right: 28,
              child: Text(
                'جاري تحليل نتيجة اختبار ${widget.test.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),

            // ── big circular progress + percentage (centred) ───────────
            Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: _ctrl.value,
                        strokeWidth: 10,
                        backgroundColor: const Color(0x33FFFFFF),
                        color: Colors.white,
                      ),
                    ),
                    Text('$pct%',
                        style: const TextStyle(
                            fontFamily: 'InterDisplay',
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),

            // ── steps near the bottom ──────────────────────────────────
            Positioned(
              left: 28,
              right: 28,
              bottom: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: 22),
                    _stepRow(_steps[i], _stepVisible(i)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Android reveals steps at 25 / 60 / 90 %
  bool _stepVisible(int i) {
    final v = _ctrl.value * 100;
    return switch (i) {
      0 => v >= 25,
      1 => v >= 60,
      _ => v >= 90,
    };
  }

  Widget _stepRow(String text, bool visible) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: visible ? 1 : 0,
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
