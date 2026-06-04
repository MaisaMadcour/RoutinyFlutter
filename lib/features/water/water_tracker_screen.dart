import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/ar_dates.dart';
import '../../theme/app_colors.dart';
import 'water_glass.dart';
import 'water_prefs.dart';
import 'water_settings_sheet.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  void _add(int ml) {
    final before = WaterPrefs.todayMl;
    WaterPrefs.addMl(ml).then((_) {
      if (!mounted) return;
      final crossed =
          before < WaterPrefs.goalMl && WaterPrefs.todayMl >= WaterPrefs.goalMl;
      setState(() {});
      if (crossed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.waterGoalReached)));
      }
    });
  }

  Future<void> _customAmount() async {
    final ctrl = TextEditingController();
    final v = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('كمية مخصوصة',
            style: TextStyle(fontFamily: 'Raleway', fontSize: 18)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'بالـ ml (مثلاً 350)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () {
                final n = int.tryParse(ctrl.text) ?? 0;
                Navigator.pop(context, n.clamp(1, 5000));
              },
              child: const Text('إضافة')),
        ],
      ),
    );
    if (v != null && v > 0) _add(v);
  }

  @override
  Widget build(BuildContext context) {
    final goal = WaterPrefs.dailyGoal;
    final cupSize = WaterPrefs.cupSizeMl;
    final ml = WaterPrefs.todayMl;
    final cups = cupSize == 0 ? 0 : ml ~/ cupSize;
    final goalMl = WaterPrefs.goalMl;
    final percent = goalMl == 0 ? 0 : (ml / goalMl * 100).round();
    final streak = WaterPrefs.currentStreak();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await showWaterSettings(context);
                    setState(() {});
                  },
                  child: const Icon(Icons.settings_outlined,
                      color: AppColors.deepChocolate),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_forward,
                      color: AppColors.deepChocolate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('شرب الميّة 💧',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 240,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    WaterGlass(
                      progress:
                          goalMl == 0 ? 0 : (ml / goalMl).clamp(0.0, 1.0),
                      baseline: 0.5,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$cups',
                            style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 64,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('من $goal كاسات',
                            style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 14,
                                color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('$percent% — $ml / $goalMl مل',
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: AppColors.secondaryText)),
            ),
            if (streak >= 2) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE9C8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('🔥 $streak أيام متتالية',
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8A5A1E))),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                _chip('نص كاسة', '${cupSize ~/ 2} مل',
                    () => _add(cupSize ~/ 2)),
                const SizedBox(width: 10),
                _chip('كاسة', '$cupSize مل', () => _add(cupSize)),
                const SizedBox(width: 10),
                _chip('كاسة كبيرة', '${cupSize * 2} مل',
                    () => _add(cupSize * 2)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _flatChip('✎ كمية مخصوصة', _customAmount),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _flatChip('↶ تراجع', () async {
                    await WaterPrefs.undoLast();
                    setState(() {});
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('آخر 7 أيام',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 12),
            _history(),
          ],
        ),
      ),
    );
  }

  Widget _chip(String title, String sub, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F1F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.waterDark)),
              Text(sub,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 11,
                      color: AppColors.secondaryText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flatChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.calendarDayStroke),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.deepChocolate)),
      ),
    );
  }

  Widget _history() {
    final today = DateTime.now();
    final week = List.generate(7, (i) {
      final d = today.subtract(Duration(days: today.weekday % 7 - i));
      return d;
    });
    final maxMl = week
        .map((d) => WaterPrefs.mlForDate(d))
        .fold<int>(1, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in week)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    () {
                      final m = WaterPrefs.mlForDate(d);
                      return m >= 1000
                          ? '${(m / 1000).toStringAsFixed(1)} ل'
                          : '$m مل';
                    }(),
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: (WaterPrefs.mlForDate(d) / maxMl * 100)
                        .clamp(4, 100),
                    decoration: BoxDecoration(
                      color: AppColors.waterBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(ArDates.dayName(d),
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 11,
                          fontWeight: ArDates.sameDay(d, today)
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: ArDates.sameDay(d, today)
                              ? AppColors.primary
                              : const Color(0xFF5C8389))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
