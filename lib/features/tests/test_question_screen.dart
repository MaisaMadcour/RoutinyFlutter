import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'test_models.dart';
import 'test_processing_screen.dart';

class TestQuestionScreen extends StatefulWidget {
  const TestQuestionScreen({super.key, required this.test});
  final MentalTest test;

  @override
  State<TestQuestionScreen> createState() => _TestQuestionScreenState();
}

class _TestQuestionScreenState extends State<TestQuestionScreen> {
  int _index = 0;
  int _score = 0;
  int? _selected;

  void _pick(int option) {
    setState(() => _selected = option);
  }

  void _next() {
    if (_selected == null) return;
    _score += _selected!;
    if (_index >= widget.test.questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TestProcessingScreen(
            test: widget.test,
            score: _score,
            maxScore: widget.test.questions.length * 2,
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.test.questions[_index];
    final total = widget.test.questions.length;
    return Scaffold(
      backgroundColor: AppColors.parseHex(widget.test.cardBgColor),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_index == 0) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          _index--;
                          _selected = null;
                        });
                      }
                    },
                    child: const Icon(Icons.arrow_forward,
                        color: AppColors.deepChocolate),
                  ),
                  const Spacer(),
                  Text('السؤال ${_index + 1} من $total',
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepChocolate)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppColors.deepChocolate),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: (_index + 1) / total,
                  minHeight: 8,
                  backgroundColor: Colors.white54,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(flex: 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(q.emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text(q.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                            color: AppColors.deepChocolate)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < q.options.length; i++)
                _option(i, q.options[i]),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _selected == null ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(
                      _index == total - 1 ? 'إنهاء' : 'التالي',
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(int i, String text) {
    final selected = _selected == i;
    return GestureDetector(
      onTap: () => _pick(i),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.calendarDayStroke,
          ),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color:
                    selected ? Colors.white : AppColors.deepChocolate)),
      ),
    );
  }
}
