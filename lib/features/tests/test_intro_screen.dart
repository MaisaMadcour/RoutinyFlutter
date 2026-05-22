import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'test_models.dart';
import 'test_question_screen.dart';

class TestIntroScreen extends StatelessWidget {
  const TestIntroScreen({super.key, required this.test});
  final MentalTest test;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  Image.asset('assets/images/${test.coverAsset}.jpg',
                      width: double.infinity, height: 360, fit: BoxFit.cover),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: _circleBtn(Icons.close,
                        () => Navigator.pop(context)),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(test.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepChocolate)),
                      const SizedBox(height: 14),
                      Text(test.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 15,
                              height: 1.4,
                              color: AppColors.secondaryText)),
                      const SizedBox(height: 20),
                      _section('لمحة عامة',
                          'هذا الاختبار سيستغرق ٣ دقائق فقط لمساعدتك في دعم مشاعرك بشكل أفضل'),
                      const SizedBox(height: 14),
                      _section('ما ستحصلين عليه', test.outcome),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('ابدأ الاختبار الآن',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 22, color: AppColors.deepChocolate),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}
