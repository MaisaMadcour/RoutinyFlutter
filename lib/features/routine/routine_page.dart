import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/ar_dates.dart';
import '../../core/database.dart';
import '../../core/models.dart';
import '../../core/routiny_defaults.dart';
import '../../core/routiny_stats.dart';
import '../../core/task_reminder.dart';
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
      // user cancelled — nothing changed
      return;
    }
    if (result.title.isEmpty) {
      // Navigation hint from _insertMultiDayTasks: jump to the first
      // occurrence so the user can immediately see the new recurring task.
      final d = DateTime.tryParse(result.date);
      if (d != null) {
        _weekCtrl.jumpToWeekOf(d);
        _selectDay(d);
        setState(() => _visibleWeek = ArDates.startOfWeek(d));
      } else {
        await _reload();
      }
      return;
    }
    if (edit == null) {
      final id = await AppDatabase.instance.insertTask(result);
      await RoutinyStats.recordTaskCreation();
      await TaskReminder.sync(id, result);
    } else {
      await AppDatabase.instance.updateTask(result);
      await TaskReminder.sync(result.id, result);
    }
    await _reload();
  }

  Future<void> _deleteTask(TaskEntity t) async {
    await AppDatabase.instance.deleteTask(t.id);
    await RoutinyStats.clearSubtaskChecks(t.id);
    await TaskReminder.cancel(t.id);
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
            // "روتيني اليوم" + count now scroll with the task list (inside it)
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
                  child: Text(S.todayBtn,
                      style: const TextStyle(
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
          Text(S.routineToday,
              style: const TextStyle(
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
    // The "روتيني اليوم" header is the first scrollable item so it moves with
    // the task list instead of staying pinned.
    Widget body;
    if (!_seeded) {
      body = const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_tasks.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Text(S.noTasksToday,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  color: AppColors.secondaryText)),
        ),
      );
    } else {
      // Masonry: two independent columns, each card dropped into the currently
      // shorter column — so a short card is followed straight by the next one
      // (no big gap under it, unlike a uniform 2-col grid).
      final colStart = <Widget>[]; // right column in RTL
      final colEnd = <Widget>[];
      var hStart = 0.0, hEnd = 0.0;
      for (var i = 0; i < _tasks.length; i++) {
        final t = _tasks[i];
        final est = 96.0 + t.subTasks.length * 32.0; // rough card height
        if (hStart <= hEnd) {
          colStart.add(_card(t, i));
          hStart += est;
        } else {
          colEnd.add(_card(t, i));
          hEnd += est;
        }
      }
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: colStart)),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: colEnd)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 160),
      children: [
        _todayHeader(),
        body,
      ],
    );
  }

  Widget _card(TaskEntity t, int position) {
    return TaskCard(
      key: ValueKey(t.id),
      task: t,
      position: position,
      dateYmd: ymd(_selected),
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
      child: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

