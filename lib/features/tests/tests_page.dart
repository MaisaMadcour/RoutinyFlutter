import 'package:flutter/material.dart';

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
                childAspectRatio: 180 / 252,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
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
      padding: const EdgeInsets.only(top: 36, bottom: 22),
      decoration: const BoxDecoration(
        color: AppColors.routinyBg,
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('اختبري نفسكِ واكتشفيها',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
            ),
            const SizedBox(height: 6),
            const Text('قلبكِ بيقول إيه',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 13,
                    color: AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({required this.test});
  final MentalTest test;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TestIntroScreen(test: test)),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.parseHex(test.cardBgColor),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                child: Image.asset(
                  'assets/images/${test.coverAsset}.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: Text(
                test.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.parseHex(test.cardTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
