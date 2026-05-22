import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'focus_settings.dart';

class PomodoroSettingsScreen extends StatefulWidget {
  const PomodoroSettingsScreen({super.key});

  @override
  State<PomodoroSettingsScreen> createState() =>
      _PomodoroSettingsScreenState();
}

class _PomodoroSettingsScreenState extends State<PomodoroSettingsScreen> {
  bool _pomodoroTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_forward,
                      color: AppColors.deepChocolate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('الإعدادات',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.chocolate)),
            const SizedBox(height: 18),
            _tabs(),
            const SizedBox(height: 18),
            _togglesCard(),
            if (_pomodoroTab) ...[
              const SizedBox(height: 22),
              const Text('تقنية البومودورو',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
              const SizedBox(height: 12),
              _techniqueCard(),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _showInfo,
                  child: const Text('ازاي تعملي تقنية البومودورو؟',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    Widget tab(String label, bool isPomo) {
      final active = _pomodoroTab == isPomo;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _pomodoroTab = isPomo),
          child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 15,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w400,
                    color: active
                        ? AppColors.chocolate
                        : AppColors.secondaryText)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DCD0),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(children: [tab('بومودورو', true), tab('مؤقت', false)]),
    );
  }

  Widget _togglesCard() {
    final live = _pomodoroTab
        ? FocusSettings.pomodoroLiveActivity
        : FocusSettings.timerLiveActivity;
    final rem = _pomodoroTab
        ? FocusSettings.pomodoroReminders
        : FocusSettings.timerReminders;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _switchRow(Icons.dashboard_customize_outlined, 'النشاط المباشر',
              live, (v) {
            setState(() {
              if (_pomodoroTab) {
                FocusSettings.pomodoroLiveActivity = v;
              } else {
                FocusSettings.timerLiveActivity = v;
              }
            });
          }),
          const Divider(
              height: 1, indent: 40, color: Color(0xFFEBE0D6)),
          _switchRow(Icons.notifications_none, 'التذكيرات', rem, (v) {
            setState(() {
              if (_pomodoroTab) {
                FocusSettings.pomodoroReminders = v;
              } else {
                FocusSettings.timerReminders = v;
              }
            });
          }),
        ],
      ),
    );
  }

  Widget _switchRow(
      IconData icon, String label, bool value, ValueChanged<bool> onCh) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Icon(icon, size: 26, color: AppColors.deepChocolate),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 17,
                      color: AppColors.deepChocolate)),
            ),
            Switch(
              value: value,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              onChanged: onCh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _techniqueCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _valueRow(
            '🍅',
            'دورة البومودورو',
            '${FocusSettings.pomodoroCycle} جلسات',
            () => _pickValue(
              title: 'دورة البومودورو',
              unit: 'جلسات',
              min: 1,
              max: 12,
              initial: FocusSettings.pomodoroCycle,
              description:
                  'عادةً، كل 4 جلسات بومودورو تبني إيقاع تركيز عميق.',
              onPicked: (v) =>
                  setState(() => FocusSettings.pomodoroCycle = v),
            ),
          ),
          const Divider(
              height: 1, indent: 40, color: Color(0xFFEBE0D6)),
          _valueRow(
            '☕',
            'استراحة قصيرة',
            '${FocusSettings.shortBreakMinutes} دقايق',
            () => _pickValue(
              title: 'استراحة قصيرة',
              unit: 'دقايق',
              min: 1,
              max: 30,
              initial: FocusSettings.shortBreakMinutes,
              description:
                  'استراحة قصيرة بعد كل جلسة بومودورو تساعد في تنشيط ذهنك وزيادة الإبداع.',
              onPicked: (v) =>
                  setState(() => FocusSettings.shortBreakMinutes = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueRow(
      String emoji, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        color: AppColors.deepChocolate)),
              ),
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: AppColors.secondaryText)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_left,
                  color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickValue({
    required String title,
    required String unit,
    required int min,
    required int max,
    required int initial,
    required String description,
    required ValueChanged<int> onPicked,
  }) async {
    var value = initial;
    final controller =
        FixedExtentScrollController(initialItem: initial - min);
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close,
                      color: AppColors.deepChocolate),
                ),
              ),
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 70,
                  perspective: 0.004,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) => value = min + i,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: max - min + 1,
                    builder: (context, i) => Center(
                      child: Text('${min + i}',
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1C))),
                    ),
                  ),
                ),
              ),
              Text(unit,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      color: AppColors.mutedTab)),
              const SizedBox(height: 12),
              Text(description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      height: 1.3,
                      color: AppColors.mutedTab)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, value),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('تم',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (result != null) onPicked(result);
  }

  void _showInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.calendarDayStroke,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            const Text('كيف تعمل تقنية البومودورو؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 18),
            for (final line in const [
              'تقنية البومودورو أداة بسيطة لزيادة التركيز والإنتاجية.',
              'اشتغل 25 دقيقة، خد استراحة 5 دقايق، وكرّر.',
              'مثالية للحفاظ على المسار وتجنّب الإرهاق.',
              'التوازن بين الشغل والراحة هو سرّ الإنتاجية على المدى البعيد.',
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🍅', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(line,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              height: 1.25,
                              color: AppColors.chocolate)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('تمام',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
