import 'package:flutter/material.dart';

import '../../core/image_palette.dart';
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
  int? _selected;
  bool _locked = false; // blocks taps during the brief reveal delay
  final List<int> _answers = [];

  // page bg = exact edge colour (matches Android TestQuestionActivity)
  late Color _edge;

  @override
  void initState() {
    super.initState();
    _edge = AppColors.parseHex(widget.test.cardBgColor);
    ImagePalette.from(
      'assets/images/${widget.test.coverAsset}.jpg',
      fallback: AppColors.parseHex(widget.test.cardBgColor),
    ).then((c) { if (mounted) setState(() => _edge = c); });
  }

  void _onAnswer(int option) {
    if (_locked) return;
    setState(() {
      _selected = option;
      _locked = true;
    });
    // brief delay so the vivid selection is visible, then advance (320ms = Android)
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      _answers.add(option);
      if (_index >= widget.test.questions.length - 1) {
        _finish();
      } else {
        setState(() {
          _index++;
          _selected = null;
          _locked = false;
        });
      }
    });
  }

  void _finish() {
    final total = _answers.fold<int>(0, (a, b) => a + b);
    final maxScore = widget.test.questions.length * 2;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TestProcessingScreen(
          test: widget.test,
          score: total,
          maxScore: maxScore,
        ),
      ),
    );
  }

  void _goBack() {
    if (_index == 0) {
      Navigator.pop(context);
    } else {
      setState(() {
        if (_answers.isNotEmpty) _answers.removeLast();
        _index--;
        _selected = null;
        _locked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.test.questions[_index];
    final total = widget.test.questions.length;

    return Scaffold(
      backgroundColor: _edge,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // ── top bar (fixed) ──────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: _goBack,
                    child: const Icon(Icons.arrow_back,
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

              // ── progress bar (fixed) ─────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: (_index + 1) / total,
                  minHeight: 8,
                  backgroundColor: const Color(0x33FFFFFF),
                  color: Colors.white,
                ),
              ),

              // ── question + options ───────────────────────────────────
              // Centered when there's room, scrollable when the screen is
              // short — so the card and options never overlap on any phone.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // ── question card ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: ImagePalette.lighten(_edge, 0.50),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Text(q.emoji,
                                    style: const TextStyle(fontSize: 40)),
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
                          // ── answer options (tap = auto-advance) ──
                          for (var i = 0; i < q.options.length; i++)
                            _option(i, q.options[i]),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(int i, String text) {
    final selected = _selected == i;
    final pale = ImagePalette.lighten(_edge, 0.55);
    return GestureDetector(
      onTap: () => _onAnswer(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _edge : pale,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? ImagePalette.darken(_edge, 0.15)
                : ImagePalette.lighten(_edge, 0.35),
            width: selected ? 1.5 : 1.2,
          ),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected
                    ? (ImagePalette.isDark(_edge)
                        ? Colors.white
                        : const Color(0xFF1A1A1A))
                    : const Color(0xFF1A1A1A))),
      ),
    );
  }
}
