import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../reflection/reflection_activity.dart';
import '../water/water_glass.dart';
import '../water/water_prefs.dart';
import '../water/water_tracker_screen.dart';
import 'breathing_exercise_screen.dart';
import 'care_article_screen.dart';
import 'care_data.dart';
import 'care_models.dart';
import 'quote_dialog.dart';
import 'quotes_data.dart';

class CarePage extends StatefulWidget {
  const CarePage({super.key});

  @override
  State<CarePage> createState() => _CarePageState();
}

class _CarePageState extends State<CarePage> {
  // Icon per section title
  static const _sectionIcons = <String, IconData>{
    'سلوكياتك ونفسيتك': Icons.psychology,
    'استمري في روتينك': Icons.event_repeat,
    'يومك بيحكي': Icons.wb_sunny,
    'طوري ذاتك': Icons.trending_up,
    'جمالك بدون تعقيد': Icons.face_retouching_natural,
    'روتين وحياة': Icons.spa,
    'اخرى': Icons.category,
  };

  // section accent colours (one per section, cycled)
  static const _accents = [
    Color(0xFFE8A0A0),
    Color(0xFFF5C24E),
    Color(0xFFFFB582),
    Color(0xFF9DBE92),
    Color(0xFFE89999),
    Color(0xFFA2BE8E),
    Color(0xFFA89DC4),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          Column(
            children: [
              _header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 14, bottom: 110),
                  children: [
                    _quoteCard(),
                    const SizedBox(height: 2),
                    _reflectionCard(),
                    const SizedBox(height: 6),
                    _breathingBanner(),
                    const SizedBox(height: 6),
                    for (var i = 0; i < careSections.length; i++)
                      _section(careSections[i], _accents[i % _accents.length]),
                  ],
                ),
              ),
            ],
          ),
          // Water glass — 2 px above the bottom navigation bar
          Positioned(
            right: 16,
            bottom: bottomPad + 70 + 2,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WaterTrackerScreen()));
                setState(() {});
              },
              child: SizedBox(
                width: 68,
                height: 82,
                child: WaterGlass(
                  progress: WaterPrefs.goalMl == 0
                      ? 0
                      : (WaterPrefs.todayMl / WaterPrefs.goalMl)
                          .clamp(0.0, 1.0),
                  baseline: 0.35,
                  strokeWidth: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.routinyBg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
              color: const Color(0x1A000000),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 8),
          child: Center(
            child: Text(
              'عناية',
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate),
            ),
          ),
        ),
      ),
    );
  }

  // ── Quote card ────────────────────────────────────────────────────────────
  Widget _quoteCard() {
    return GestureDetector(
      onTap: () => showQuoteTodayDialog(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border(
            // start = right side in RTL
            right: const BorderSide(color: AppColors.primary, width: 4),
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            // decorative opening quote — top-start (top-right in RTL)
            Positioned(
              top: 6,
              right: 14,
              child: Text(
                '❝', // ❝
                style: TextStyle(
                    fontFamily: 'InterDisplay',
                    fontSize: 32,
                    height: 1.0,
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
            ),
            // decorative closing quote — bottom-end (bottom-left in RTL)
            Positioned(
              bottom: 4,
              left: 14,
              child: Text(
                '❞', // ❞
                style: TextStyle(
                    fontFamily: 'InterDisplay',
                    fontSize: 32,
                    height: 1.0,
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
            ),
            // main content
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Text(
                    'كوته',
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentLoveYourselfQuote(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        height: 1.55,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reflection card ───────────────────────────────────────────────────────
  Widget _reflectionCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ReflectionActivity())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9EBE4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8C8BE), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // text on the right (RTL start → first child)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'حاسة بإيه النهاردة؟',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'خدي دقيقتين تشوفي شعورك إزاي النهارده',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 13,
                        color: Color(0xFF9E6A56)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // cloud + rain icon on the left (RTL end → last child)
            _cloudRainIcon(),
          ],
        ),
      ),
    );
  }

  Widget _cloudRainIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud, color: AppColors.primary, size: 36),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rainDrop(),
            const SizedBox(width: 4),
            _rainDrop(),
            const SizedBox(width: 4),
            _rainDrop(),
            const SizedBox(width: 4),
            _rainDrop(),
          ],
        ),
      ],
    );
  }

  Widget _rainDrop() => Container(
        width: 3,
        height: 9,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  // ── Breathing banner ──────────────────────────────────────────────────────
  Widget _breathingBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const BreathingExerciseScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        height: 215,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
        child: Image.asset(
          'assets/images/care_breathing_card.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  // ── Section row ───────────────────────────────────────────────────────────
  Widget _section(CareSectionDef section, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section header — pill with margin + meaningful icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFEDD5C8),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    _sectionIcons[section.title] ?? Icons.auto_awesome,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    section.title,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: section.cardH,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: section.cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final card = section.cards[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CareArticleScreen(
                        card: card,
                        accent: accent,
                        cardAspect: section.cardW / section.cardH,
                        related: section.cards
                            .where(
                                (c) => c.articleKey != card.articleKey)
                            .take(6)
                            .toList(),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: section.cardW,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/${card.imageAsset}.jpg',
                            width: section.cardW,
                            height: section.cardH,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text('اقرئي المزيد',
                                style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
