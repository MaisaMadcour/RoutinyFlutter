import 'package:flutter/material.dart';

import '../../core/image_palette.dart';
import '../../theme/app_colors.dart';
import 'test_models.dart';
import 'test_question_screen.dart';

class TestIntroScreen extends StatefulWidget {
  const TestIntroScreen({super.key, required this.test});
  final MentalTest test;

  @override
  State<TestIntroScreen> createState() => _TestIntroScreenState();
}

class _TestIntroScreenState extends State<TestIntroScreen> {
  // page bg = exact edge colour; derived shades match Android TestIntroActivity
  late Color _bg;

  Color get _card  => ImagePalette.lighten(_bg, 0.30); // cards: lighter than page
  Color get _dark  => ImagePalette.darken(_bg, 0.18);  // start button: a bit darker
  Color get _label => ImagePalette.darken(_bg, 0.40);  // card titles
  MentalTest get test => widget.test;

  @override
  void initState() {
    super.initState();
    _bg = AppColors.parseHex(widget.test.cardBgColor);
    ImagePalette.from(
      'assets/images/${widget.test.coverAsset}.jpg',
      fallback: _bg,
    ).then((c) { if (mounted) setState(() => _bg = c); });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      color: _bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── scrollable content ─────────────────────────────────────────
            ListView(
              padding: EdgeInsets.zero,
              children: [
                // cover image with X button
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/${test.coverAsset}.jpg',
                      width: double.infinity,
                      height: 340,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 44,
                      left: 16,
                      child: SafeArea(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 26),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── content directly on the extracted bg ───────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        test.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.parseHex(test.cardTextColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        test.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          height: 1.4,
                          color: AppColors.deepChocolate,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _section(
                        icon: Icons.timer_outlined,
                        title: 'لمحة عامة',
                        body: 'هذا الاختبار سيستغرق ٣ دقائق فقط'
                            ' لمساعدتك في دعم مشاعرك بشكل أفضل',
                      ),
                      const SizedBox(height: 14),
                      _section(
                        icon: Icons.emoji_events_outlined,
                        title: 'ما ستحصلين عليه',
                        body: test.outcome,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),

            // ── start button ───────────────────────────────────────────────
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TestQuestionScreen(test: test)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'ابدأ الاختبار الآن',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _section({
    required IconData icon,
    required String title,
    required String body,
  }) {
    final sentences = _splitSentences(body);
    const bulletIcons = [
      Icons.lightbulb_outline,
      Icons.psychology_alt,
      Icons.self_improvement,
      Icons.star_outline,
      Icons.check_circle_outline,
      Icons.favorite_border,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _label),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _label)),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < sentences.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    bulletIcons[i % bulletIcons.length],
                    size: 15,
                    color: AppColors.deepChocolate.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(sentences[i],
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.deepChocolate)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<String> _splitSentences(String text) {
    final parts = text
        .split(RegExp(r'(?<=[.،])'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? [text.trim()] : parts;
  }
}
