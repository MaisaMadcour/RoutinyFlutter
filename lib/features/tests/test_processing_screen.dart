import 'dart:async';
import 'package:flutter/material.dart';

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

class _TestProcessingScreenState extends State<TestProcessingScreen> {
  int _step = 0;
  final _steps = const [
    'تحليل المشاعر والحالة النفسية',
    'تحليل الدعم والعلاقات الاجتماعية',
    'تحليل التأثير على الهوية والسلوك',
  ];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _step = i + 1);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final tier = ((widget.score / widget.maxScore) * 5)
        .floor()
        .clamp(0, widget.test.resultTiers.length - 1);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TestResultScreen(
          test: widget.test,
          tierIndex: tier,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parseHex(widget.test.cardBgColor),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 5),
              ),
              const SizedBox(height: 28),
              Text('جاري تحليل نتيجة اختبار ${widget.test.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
              const SizedBox(height: 30),
              for (var i = 0; i < _steps.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _step > i
                              ? AppColors.primary
                              : Colors.white,
                        ),
                        child: _step > i
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_steps[i],
                            style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 14,
                                color: _step > i
                                    ? AppColors.deepChocolate
                                    : AppColors.secondaryText)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
