import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/ads/rewarded_manager.dart';
import '../../core/ar_dates.dart';
import '../../core/database.dart';
import '../../core/models.dart';
import '../../core/routiny_stats.dart';
import '../../theme/app_colors.dart';
import '../reflection/reflection_models.dart';
import 'avatar_editor_screen.dart';
import 'journal_screen.dart';
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
    RewardedManager.instance.preload();
  }

  void _openJournal() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const JournalScreen()));
  }

  // مذكراتي is gated EVERY time: tap → confirm → watch a rewarded ad → open.
  void _onJournalTap() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('افتحي مذكراتي 🔓',
            style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.deepChocolate)),
        content: const Text(
          'شوفي إعلان قصير وافتحي مذكراتك 🌸',
          style: TextStyle(
              fontFamily: 'Raleway', fontSize: 14, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('مش دلوقتي',
                style: TextStyle(
                    fontFamily: 'Raleway', color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              RewardedManager.instance.show(
                onReward: () {
                  if (mounted) _openJournal();
                },
                onUnavailable: () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'محتاجة اتصال بالإنترنت عشان تشوفي إعلان وتفتحي مذكراتك 🌐'),
                    ),
                  );
                },
              );
            },
            child: const Text('شوفي إعلان وافتحي',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
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

  Future<void> _saveName() async {
    await RoutinyStats.setUserName(_nameCtrl.text.trim());
    FocusScope.of(context).unfocus();
    setState(() => _editingName = false);
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    // open the zoom/pan editor, then save the framed result
    final cropped = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => AvatarEditorScreen(image: File(file.path))),
    );
    if (cropped == null) return;
    await RoutinyStats.setAvatarPath(cropped);
    if (mounted) setState(() {});
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
                    color: const Color(0xFFF5E1D6), // bg_profile_avatar
                    border: Border.all(color: const Color(0xFFE8D5CC)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasAvatar
                      ? Image.file(File(avatarPath), fit: BoxFit.cover)
                      : const Icon(Icons.person,
                          color: Color(0xFFBC8A7B), size: 44),
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
                child: Column(
                  children: [
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _nameCtrl,
                        autofocus: true,
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
                        onSubmitted: (_) => _saveName(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 240,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _saveName,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                          elevation: 0,
                        ),
                        child: const Text('حفظ',
                            style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ],
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
                  child: _statCard('${RoutinyStats.dayStreak}',
                      Icons.wb_sunny, const Color(0xFFF5A623), 'يوم متواصل'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard('${RoutinyStats.tasksCompletedCount}',
                      Icons.auto_awesome, const Color(0xFF5A8DBF),
                      'مهمة مكتملة'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            // ── tasks-completed calendar ──
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('احصائيات ايام انجاز المهام',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _statDecoration,
              child: MiniMonthCalendar(
                highlightProvider: (y, m) =>
                    RoutinyStats.completedDaysInMonth(y, m),
              ),
            ),
            const SizedBox(height: 22),
            // ── mood stats ──
            _moodStats(),
            const SizedBox(height: 22),
            // ── breathing calendar ──
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('احصائيات التنفس',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _statDecoration,
              child: MiniMonthCalendar(
                highlightProvider: (y, m) =>
                    RoutinyStats.breathingDaysInMonth(y, m),
              ),
            ),
            const SizedBox(height: 22),
            // ── مذكراتي (last) — gated behind a rewarded ad every time ──
            GestureDetector(
              onTap: _onJournalTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cardStroke),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined,
                        size: 22, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('مذكراتي',
                          style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E2818))),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Text('🔒', style: TextStyle(fontSize: 14)),
                    ),
                    const Icon(Icons.lock_outline,
                        size: 20, color: AppColors.deepChocolate),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // shared white card with a hairline stroke — matches bg_profile_stats_card
  static const _cardWhite = Color(0xFFFFFFFF);
  static const _cardStroke = Color(0xFFEBE0D6);
  static BoxDecoration get _statDecoration => BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardStroke),
      );

  Widget _statCard(String value, IconData icon, Color iconColor, String label) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _statDecoration,
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
                      color: Color(0xFF3E2818))),
              const SizedBox(width: 6),
              Icon(icon, size: 22, color: iconColor),
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
        const Text('احصائيات احساسك',
            style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.deepChocolate)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _statDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _moodMonth = DateTime(
                        _moodMonth.year, _moodMonth.month - 1, 1)),
                    icon: const Icon(Icons.chevron_left,
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
                    icon: Icon(Icons.chevron_right,
                        color: isCurrentMonth
                            ? AppColors.deepChocolate
                                .withValues(alpha: 0.35)
                            : AppColors.deepChocolate),
                  ),
                ],
              ),
              // total + dominant mood row
              Row(
                children: [
                  Text(totalLabel(),
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepChocolate)),
                  const Spacer(),
                  if (total > 0) Text(_dominantLabel(counts),
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          color: AppColors.secondaryText)),
                ],
              ),
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

  // dominant mood, e.g. "😊 غالبًا سعيدة" (matches Android ProfileActivity)
  String _dominantLabel(Map<String, int> counts) {
    String? topId;
    var topCount = 0;
    counts.forEach((id, c) {
      if (c > topCount) {
        topCount = c;
        topId = id;
      }
    });
    if (topId == null) return '';
    final m = kMoods.firstWhere((e) => e.id == topId,
        orElse: () => kMoods.first);
    return '${m.emoji} غالبًا ${m.label}';
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
