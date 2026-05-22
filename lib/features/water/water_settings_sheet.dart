import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'water_prefs.dart';

String formatInterval(int min) {
  if (min < 60) return 'كل $min دقيقة';
  if (min == 60) return 'كل ساعة';
  if (min == 120) return 'كل ساعتين';
  if (min % 60 == 0) return 'كل ${min ~/ 60} ساعات';
  return 'كل $min دقيقة';
}

Future<void> showWaterSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _WaterSettingsSheet(),
  );
}

class _WaterSettingsSheet extends StatefulWidget {
  const _WaterSettingsSheet();

  @override
  State<_WaterSettingsSheet> createState() => _WaterSettingsSheetState();
}

class _WaterSettingsSheetState extends State<_WaterSettingsSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('إعدادات شرب الميّة ⚙️',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const SizedBox(height: 16),
          _row('🎯', 'الهدف اليومي', '${WaterPrefs.dailyGoal} كاسات', () async {
            final v = await _pickNumber(
                'الهدف اليومي (كاسات)', 1, 20, WaterPrefs.dailyGoal);
            if (v != null) setState(() => WaterPrefs.dailyGoal = v);
          }),
          _row('🥛', 'حجم الكاسة', '${WaterPrefs.cupSizeMl} مل', () async {
            final v = await _pickChoice('حجم الكاسة',
                const [150, 200, 250, 300, 350, 400, 500],
                (n) => '$n مل', WaterPrefs.cupSizeMl);
            if (v != null) setState(() => WaterPrefs.cupSizeMl = v);
          }),
          _switchRow('🔔', 'تذكيرات تلقائية', WaterPrefs.reminderEnabled,
              (v) => setState(() => WaterPrefs.reminderEnabled = v)),
          _row('⏰', 'كل قد إيه؟', formatInterval(WaterPrefs.reminderIntervalMin),
              () async {
            final v = await _pickChoice('فترة التذكير',
                const [30, 60, 90, 120, 150, 180, 240],
                formatInterval, WaterPrefs.reminderIntervalMin);
            if (v != null) setState(() => WaterPrefs.reminderIntervalMin = v);
          }),
          _switchRow('💧', 'صوت الإشعار', WaterPrefs.notificationSoundEnabled,
              (v) => setState(
                  () => WaterPrefs.notificationSoundEnabled = v)),
        ],
      ),
    );
  }

  Widget _row(String emoji, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 15,
                      color: AppColors.deepChocolate)),
            ),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 13,
                    color: AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(
      String emoji, String label, bool value, ValueChanged<bool> onCh) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 15,
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
    );
  }

  Future<int?> _pickNumber(String title, int min, int max, int current) {
    var value = current;
    final controller =
        FixedExtentScrollController(initialItem: current - min);
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title,
            style: const TextStyle(fontFamily: 'Raleway', fontSize: 16)),
        content: SizedBox(
          height: 150,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 44,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) => value = min + i,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: max - min + 1,
              builder: (context, i) => Center(
                child: Text('${min + i}',
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 24,
                        color: AppColors.deepChocolate)),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, value),
              child: const Text('تم')),
        ],
      ),
    );
  }

  Future<int?> _pickChoice(String title, List<int> options,
      String Function(int) label, int current) {
    return showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        backgroundColor: AppColors.surface,
        title: Text(title,
            style: const TextStyle(fontFamily: 'Raleway', fontSize: 16)),
        children: [
          for (final o in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, o),
              child: Row(
                children: [
                  Icon(
                    o == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(label(o),
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          color: AppColors.deepChocolate)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
