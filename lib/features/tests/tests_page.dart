import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/image_palette.dart';
import '../../theme/app_colors.dart';
import 'test_data.dart';
import 'test_intro_screen.dart';
import 'test_models.dart';

class TestsPage extends StatelessWidget {
  const TestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _header(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 120),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 180 / 220,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemCount: mentalTests.length,
              itemBuilder: (context, i) => _TestCard(test: mentalTests[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE8DA),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: const Color(0x1A000000),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Text(
              S.testsHeader,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate),
            ),
            const SizedBox(height: 3),
            Text(
              S.testsSubheader,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends StatefulWidget {
  const _TestCard({required this.test});
  final MentalTest test;

  @override
  State<_TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<_TestCard> {
  // card/title background = lighten(edge, 0.55) — matches Android TestsGridAdapter
  late Color _cardBg;

  @override
  void initState() {
    super.initState();
    _cardBg = AppColors.parseHex(widget.test.cardBgColor);
    ImagePalette.from(
      'assets/images/${widget.test.coverAsset}.jpg',
      fallback: AppColors.parseHex(widget.test.cardBgColor),
    ).then((edge) {
      if (mounted) {
        setState(() => _cardBg = ImagePalette.lighten(edge, 0.55));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double r = 22;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TestIntroScreen(test: widget.test)),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(r),
          // a soft frame in a darker shade of the card's own colour
          border: Border.all(
            color: ImagePalette.darken(_cardBg, 0.15),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── illustration ──────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(r),
                  topRight: Radius.circular(r),
                ),
                child: Image.asset(
                  'assets/images/${widget.test.coverAsset}.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // ── title — sits on the lightened card background ─────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: Text(
                S.localize(widget.test.title, widget.test.titleFusha),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: Color(0xFF5C3D2E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
