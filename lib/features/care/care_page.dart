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
                    _featured(),
                    _reflectionCard(),
                    _breathingBanner(),
                    for (var i = 0; i < careSections.length; i++)
                      _section(careSections[i], _accents[i % _accents.length]),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 120,
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
                  strokeWidth: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 36, bottom: 22),
      decoration: const BoxDecoration(
        color: AppColors.routinyBg,
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: const SafeArea(
        bottom: false,
        child: Center(
          child: Text('عناية',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
        ),
      ),
    );
  }

  Widget _featured() {
    return GestureDetector(
      onTap: () => showQuoteTodayDialog(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('“',
                  style: TextStyle(
                      fontSize: 44, height: 0.7, color: AppColors.primary)),
            ),
            const Text('كوته',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(currentLoveYourselfQuote(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text('”',
                  style: TextStyle(
                      fontSize: 44, height: 0.4, color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reflectionCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ReflectionActivity())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFBE3D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Text('💭', style: TextStyle(fontSize: 44)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('حاسة بإيه النهاردة؟',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepChocolate)),
                  SizedBox(height: 4),
                  Text('خدي دقيقتين تشوفي شعورك إزاي النهارده',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          color: Color(0xFF8A5A1E))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breathingBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const BreathingExerciseScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        height: 150,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Image.asset('assets/images/care_breathing_card.jpg',
            fit: BoxFit.cover),
      ),
    );
  }

  Widget _section(CareSectionDef section, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(section.title,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: section.cardH,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: section.cards.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final card = section.cards[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CareArticleScreen(
                        card: card,
                        accent: accent,
                        related: section.cards
                            .where((c) => c.articleKey != card.articleKey)
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
