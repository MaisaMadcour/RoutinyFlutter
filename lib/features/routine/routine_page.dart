import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/ads/interstitial_manager.dart';
import '../../core/app_strings.dart';
import '../../core/ar_dates.dart';
import '../../core/database.dart';
import '../../core/models.dart';
import '../../core/routiny_defaults.dart';
import '../../core/routiny_stats.dart';
import '../../theme/app_colors.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';
import 'create_task_sheet.dart';
import 'widgets/task_card.dart';
import 'widgets/week_calendar.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  DateTime _selected = DateTime.now();
  DateTime _visibleWeek = ArDates.startOfWeek(DateTime.now());
  List<TaskEntity> _tasks = [];
  int? _expandedId;
  bool _fabOpen = false;
  bool _seeded = false;
  final _weekCtrl = WeekCalendarController();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await RoutinyDefaults.seedIfNeeded();
    _seeded = true;
    await _reload();
  }

  Future<void> _reload() async {
    final list = await AppDatabase.instance.tasksByDate(ymd(_selected));
    if (mounted) setState(() => _tasks = list);
  }

  void _selectDay(DateTime d) {
    setState(() {
      _selected = d;
      _expandedId = null;
    });
    _reload();
  }

  Future<void> _openCreate({TaskEntity? edit}) async {
    final result = await showCreateTaskSheet(context, edit: edit);
    if (result == null) {
      // null can mean cancelled OR weekly tasks already inserted natively
      await _reload();
      return;
    }
    if (edit == null) {
      await AppDatabase.instance.insertTask(result);
      await RoutinyStats.recordTaskCreation();
    } else {
      await AppDatabase.instance.updateTask(result);
    }
    await _reload();
  }

  Future<void> _deleteTask(TaskEntity t) async {
    await AppDatabase.instance.deleteTask(t.id);
    await RoutinyStats.clearSubtaskChecks(t.id);
    setState(() => _expandedId = null);
    await _reload();
  }

  String _remainingText(int n) {
    if (n == 0) return S.noTasksYet;
    if (n == 1) return S.oneTask;
    if (n == 2) return S.twoTasks;
    return S.tasksCount(n);
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final morning = hour >= 1 && hour < 12;
    return Stack(
      children: [
        Column(
          children: [
            _stickyHeader(morning),
            _todayHeader(),
            Expanded(child: _taskGrid()),
          ],
        ),
        _fabCluster(),
      ],
    );
  }

  Widget _stickyHeader(bool morning) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            _profileHeader(morning),
            const SizedBox(height: 14),
            _calendarCard(),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader(bool morning) {
    final avatarPath = RoutinyStats.avatarPath;
    final hasAvatar = avatarPath != null && File(avatarPath).existsSync();
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfilePage()));
            setState(() {});
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.routinyBg,
              border: Border.all(color: AppColors.profileStroke),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasAvatar
                ? Image.file(File(avatarPath), fit: BoxFit.cover)
                : const Icon(Icons.local_florist,
                    color: AppColors.primary, size: 28),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(morning ? S.greetingMorning : S.greetingEvening,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          color: AppColors.greetingText)),
                  const SizedBox(width: 4),
                  Text(morning ? '☀️' : '🌙',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
              Text(
                RoutinyStats.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.nameText),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsPage())),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: const Icon(Icons.notifications_none,
                size: 22, color: AppColors.deepChocolate),
          ),
        ),
      ],
    );
  }

  Widget _calendarCard() {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.calendarCardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selected,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: AppColors.routinyBg,
                          onSurface: AppColors.deepChocolate,
                          secondary: AppColors.primary,
                          onSecondary: Colors.white,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (date != null) {
                    _weekCtrl.jumpToWeekOf(date);
                    _selectDay(date);
                    setState(() => _visibleWeek = ArDates.startOfWeek(date));
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ArDates.monthYear(_visibleWeek),
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.calendarMonthText),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: AppColors.calendarMonthArrow),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final now = DateTime.now();
                  _weekCtrl.jumpToWeekOf(now);
                  _selectDay(now);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.calendarTodayPillStart,
                        AppColors.calendarTodayPillEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text('اليوم',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.calendarTodayPillText)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          WeekCalendar(
            controller: _weekCtrl,
            selected: _selected,
            onSelected: _selectDay,
            onWeekChanged: (w) => setState(() => _visibleWeek = w),
          ),
        ],
      ),
    );
  }

  Widget _todayHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Row(
        children: [
          const Text('روتيني اليوم',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.todayHeaderChipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(_remainingText(_tasks.length),
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    color: AppColors.todayHeaderChipText)),
          ),
        ],
      ),
    );
  }

  Widget _taskGrid() {
    if (!_seeded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_tasks.isEmpty) {
      return const Center(
        child: Text('لا توجد مهام لهذا اليوم',
            style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 14,
                color: AppColors.secondaryText)),
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < _tasks.length; i += 2) {
      final first = _tasks[i];
      final second = i + 1 < _tasks.length ? _tasks[i + 1] : null;
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _card(first, i)),
            Expanded(
                child: second == null
                    ? const SizedBox()
                    : _card(second, i + 1)),
          ],
        ),
      ));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 160),
      children: rows,
    );
  }

  Widget _card(TaskEntity t, int position) {
    return TaskCard(
      key: ValueKey(t.id),
      task: t,
      position: position,
      expanded: _expandedId == t.id,
      onLongPress: () => setState(
          () => _expandedId = _expandedId == t.id ? null : t.id),
      onTapWhenExpanded: () => setState(() => _expandedId = null),
      onEdit: () {
        setState(() => _expandedId = null);
        _openCreate(edit: t);
      },
      onDelete: () => _deleteTask(t),
    );
  }

  Widget _fabCluster() {
    return Positioned(
      right: 20,
      bottom: 24,
      child: SizedBox(
        width: 200,
        height: 170,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              right: _fabOpen ? 70 : 2,
              bottom: _fabOpen ? 80 : 2,
              child: AnimatedOpacity(
                opacity: _fabOpen ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: _miniFab(Icons.add, () {
                  setState(() => _fabOpen = false);
                  _openCreate();
                }),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              right: _fabOpen ? 132 : 2,
              bottom: _fabOpen ? 80 : 2,
              child: AnimatedOpacity(
                opacity: _fabOpen ? 1 : 0,
                duration: const Duration(milliseconds: 240),
                child: _miniFab(Icons.play_arrow, () {
                  setState(() => _fabOpen = false);
                  InterstitialManager.instance.showIfReady(
                    InterstitialManager.ctxSupport,
                    onDone: () {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('شكراً لدعمك 💗')));
                    },
                  );
                }),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => setState(() => _fabOpen = !_fabOpen),
                child: AnimatedRotation(
                  turns: _fabOpen ? 0.125 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniFab(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
                color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
