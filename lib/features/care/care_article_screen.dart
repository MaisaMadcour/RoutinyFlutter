import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'care_data.dart';
import 'care_models.dart';

class CareArticleScreen extends StatelessWidget {
  const CareArticleScreen({
    super.key,
    required this.card,
    required this.accent,
    this.related = const [],
  });

  final CareCardDef card;
  final Color accent;
  final List<CareCardDef> related;

  Color get _bg => Color.lerp(accent, Colors.white, 0.9)!;

  @override
  Widget build(BuildContext context) {
    final article = careArticleFor(card.articleKey);
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  Image.asset('assets/images/${card.imageAsset}.jpg',
                      width: double.infinity,
                      height: 320,
                      fit: BoxFit.cover),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back,
                            color: AppColors.deepChocolate, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
                child: Column(
                  children: [
                    Text(card.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 26,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3D2817))),
                    const SizedBox(height: 18),
                    Text(article.intro,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 18,
                            height: 1.5,
                            color: AppColors.deepChocolate)),
                    for (final s in article.sections) ...[
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color.lerp(accent, Colors.white, 0.6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(s.heading,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepChocolate)),
                      ),
                      const SizedBox(height: 12),
                      Text(s.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 17,
                              height: 1.6,
                              color: AppColors.deepChocolate)),
                    ],
                    if (related.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color.lerp(accent, Colors.white, 0.6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text('مقالات ذات صلة',
                              style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepChocolate)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: related.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final r = related[i];
                            return GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CareArticleScreen(
                                    card: r,
                                    accent: accent,
                                    related: related,
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/images/${r.imageAsset}.jpg',
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
