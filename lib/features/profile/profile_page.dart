import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/ar_dates.dart';
import '../../core/database.dart';
import '../../core/models.dart';
import '../../core/routiny_stats.dart';
import '../../theme/app_colors.dart';
import '../reflection/reflection_models.dart';
import 'mini_month_calendar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _editingName = false;
  final _nameCtrl = TextEditingController();
  List<ReflectionEntity> _reflections = [];
  DateTime _moodMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = RoutinyStats.userName;
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    final list = await AppDatabase.instance.allReflections();
    if (mounted) setState(() => _reflections = list);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    await RoutinyStats.setAvatarPath(file.path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = RoutinyStats.avatarPath;
    final hasAvatar = avatarPath != null && File(avatarPath).existsSync();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            Row(
              children: [
                const Text('الملف الشخصي',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.chocolate)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      color: AppColors.deepChocolate),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.profileStroke),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasAvatar
                      ? Image.file(File(avatarPath), fit: BoxFit.cover)
                      : const Icon(Icons.local_florist,
                          color: AppColors.primary, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _editingName = !_editingName),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('تعديل الاسم',
                        style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.chocolate)),
                    SizedBox(width: 6),
                    Icon(Icons.edit, size: 20, color: AppColors.chocolate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_editingName)
              Center(
                child: SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _nameCtrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'اكتبي اسمكِ هنا',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                    onSubmitted: (v) async {
                      await RoutinyStats.setUserName(v.trim());
                      setState(() => _editingName = false);
                    },
                  ),
                ),
              )
            else
              Center(
                child: Text(RoutinyStats.userName,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText)),
              ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _statCard('${RoutinyStats.dayStreak}', '☀️',
                      'يوم متواصل'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard('${RoutinyStats.tasksCompletedCount}',
                      '✨', 'مهمة مكتملة'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('إحصائيات المهام',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: MiniMonthCalendar(
                highlightProvider: (y, m) =>
                    RoutinyStats.completedDaysInMonth(y, m),
              ),
            ),
            const SizedBox(height: 22),
            _moodStats(),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String emoji, String label) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.chocolate)),
              const SizedBox(width: 6),
              Text(emoji, style: const TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  color: Color(0xFF5C4A3E))),
        ],
      ),
    );
  }

  Widget _moodStats() {
    final monthStart = DateTime(_moodMonth.year, _moodMonth.month, 1);
    final monthEnd = DateTime(_moodMonth.year, _moodMonth.month + 1, 1);
    final inMonth = _reflections.where((r) {
      final d = DateTime.fromMillisecondsSinceEpoch(r.timestamp);
      return !d.isBefore(monthStart) && d.isBefore(monthEnd);
    }).toList();
    final counts = <String, int>{};
    for (final r in inMonth) {
      counts[r.mood] = (counts[r.mood] ?? 0) + 1;
    }
    final total = inMonth.length;
    final isCurrentMonth = _moodMonth.year == DateTime.now().year &&
        _moodMonth.month == DateTime.now().month;

    String totalLabel() {
      if (total == 0) return 'مفيش إحساسات';
      if (total == 1) return 'إحساس واحد';
      if (total == 2) return 'إحساسين';
      if (total <= 10) return '$total إحساسات';
      return '$total إحساس';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('إحصائيات إحساساتك',
            style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.deepChocolate)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _moodMonth = DateTime(
                        _moodMonth.year, _moodMonth.month - 1, 1)),
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.deepChocolate),
                  ),
                  Expanded(
                    child: Text(ArDates.monthYear(_moodMonth),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepChocolate)),
                  ),
                  IconButton(
                    onPressed: isCurrentMonth
                        ? null
                        : () => setState(() => _moodMonth = DateTime(
                            _moodMonth.year, _moodMonth.month + 1, 1)),
                    icon: Icon(Icons.chevron_left,
                        color: isCurrentMonth
                            ? AppColors.deepChocolate
                                .withValues(alpha: 0.35)
                            : AppColors.deepChocolate),
                  ),
                ],
              ),
              Text(totalLabel(),
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
              const SizedBox(height: 12),
              if (total == 0)
                const Text(
                    'مفيش إحساسات في الشهر ده — جربي تسجلي إحساسك من صفحة العناية 🤍',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 13,
                        color: AppColors.secondaryText))
              else
                for (final m in kMoods)
                  _moodRow(m, counts[m.id] ?? 0, total),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moodRow(Mood m, int count, int total) {
    final frac = total == 0 ? 0.0 : count / total;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE0D6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(m.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(m.label,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 13,
                    color: AppColors.chocolate)),
          ),
          Container(
            width: 80,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFD8C9BC),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: count == 0 ? 0 : frac.clamp(0.05, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count',
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}
