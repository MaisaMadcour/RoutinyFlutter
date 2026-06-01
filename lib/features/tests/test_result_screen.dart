import 'package:flutter/material.dart';

import '../../core/database.dart';
import '../../core/models.dart';
import '../../core/routiny_stats.dart';
import '../../theme/app_colors.dart';
import 'test_intro_screen.dart';
import 'test_models.dart';

class TestResultScreen extends StatefulWidget {
  const TestResultScreen({
    super.key,
    required this.test,
    required this.tierIndex,
  });
  final MentalTest test;
  final int tierIndex;

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  bool _adopted = false;

  TestResultTier get _tier => widget.test.resultTiers[widget.tierIndex];

  Future<void> _adoptRoutine() async {
    await AppDatabase.instance.insertTask(TaskEntity(
      title: widget.test.title.length > 15
          ? widget.test.title.substring(0, 15)
          : widget.test.title,
      iconResName: 'ic_routiny_sparkles',
      colorHex: '#C7745F',
      subTasks: _tier.routine,
      date: ymd(DateTime.now()),
    ));
    await RoutinyStats.recordTaskCreation();
    if (!mounted) return;
    setState(() => _adopted = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم اعتماد الروتين المقترح في صفحة الروتين 💗')));
  }

  @override
  Widget build(BuildContext context) {
    final tier = _tier;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              if (tier.imageAsset.isNotEmpty)
                Image.asset('assets/images/${tier.imageAsset}.jpg',
                    width: double.infinity, height: 340, fit: BoxFit.cover)
              else
                Container(
                    height: 340,
                    color: AppColors.parseHex(widget.test.cardBgColor)),
              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.popUntil(
                      context, (r) => r.isFirst),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        color: AppColors.deepChocolate, size: 22),
                  ),
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text('نتيجتي',
                        style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 13,
                            color: AppColors.secondaryText)),
                  ),
                  const SizedBox(height: 4),
                  Text(tier.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepChocolate)),
                  const SizedBox(height: 18),
                  _levelsBar(),
                  const SizedBox(height: 20),
                  _card('تفاصيل نتيجتك', child: Text(tier.details,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.deepChocolate))),
                  if (tier.traits.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _bulletCard('النصيحة', tier.traits),
                  ],
                  if (tier.strengths.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _bulletCard('نقاط القوة', tier.strengths),
                  ],
                  if (tier.weaknesses.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _bulletCard('نقاط الضعف', tier.weaknesses),
                  ],
                  const SizedBox(height: 20),
                  if (tier.routine.isNotEmpty)
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _adopted ? null : _adoptRoutine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                        ),
                        child: Text(
                            _adopted
                                ? 'تم الاعتماد ✓'
                                : 'اعتماد الروتين المقترح',
                            style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TestIntroScreen(test: widget.test)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: const Text('إعادة',
                          style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelsBar() {
    return Row(
      children: [
        for (var i = 0; i < widget.test.levelLabels.length; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == widget.tierIndex
                        ? AppColors.primary
                        : AppColors.calendarDayStroke,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 6),
                Text(widget.test.levelLabels[i],
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 10,
                        fontWeight: i == widget.tierIndex
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: i == widget.tierIndex
                            ? AppColors.primary
                            : AppColors.secondaryText)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _card(String title, {required Widget child}) {
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _bulletCard(String title, List<String> items) {
    return _card(title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final it in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.primary)),
                    Expanded(
                      child: Text(it,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.deepChocolate)),
                    ),
                  ],
                ),
              ),
          ],
        ));
  }
}
