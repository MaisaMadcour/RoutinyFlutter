import 'package:flutter/material.dart';

import '../../core/ar_dates.dart';
import '../../core/database.dart';
import '../../core/models.dart';
import '../../theme/app_colors.dart';

enum _Range { day, week, month, year }

class FocusStatsScreen extends StatefulWidget {
  const FocusStatsScreen({super.key});

  @override
  State<FocusStatsScreen> createState() => _FocusStatsScreenState();
}

class _FocusStatsScreenState extends State<FocusStatsScreen> {
  _Range _range = _Range.week;
  DateTime _anchor = DateTime.now();
  List<FocusSessionEntity> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime get _start {
    switch (_range) {
      case _Range.day:
        return DateTime(_anchor.year, _anchor.month, _anchor.day);
      case _Range.week:
        final base = DateTime(_anchor.year, _anchor.month, _anchor.day);
        return base.subtract(Duration(days: (base.weekday) % 7)); // Sat start
      case _Range.month:
        return DateTime(_anchor.year, _anchor.month, 1);
      case _Range.year:
        return DateTime(_anchor.year, 1, 1);
    }
  }

  DateTime get _end {
    switch (_range) {
      case _Range.day:
        return _start.add(const Duration(days: 1));
      case _Range.week:
        return _start.add(const Duration(days: 7));
      case _Range.month:
        return DateTime(_anchor.year, _anchor.month + 1, 1);
      case _Range.year:
        return DateTime(_anchor.year + 1, 1, 1);
    }
  }

  Future<void> _load() async {
    final list = await AppDatabase.instance.focusSessionsBetween(
        _start.millisecondsSinceEpoch, _end.millisecondsSinceEpoch);
    if (mounted) setState(() => _sessions = list);
  }

  void _shift(int dir) {
    setState(() {
      switch (_range) {
        case _Range.day:
          _anchor = _anchor.add(Duration(days: dir));
          break;
        case _Range.week:
          _anchor = _anchor.add(Duration(days: 7 * dir));
          break;
        case _Range.month:
          _anchor = DateTime(_anchor.year, _anchor.month + dir, 1);
          break;
        case _Range.year:
          _anchor = DateTime(_anchor.year + dir, 1, 1);
          break;
      }
    });
    _load();
  }

  String get _rangeLabel {
    switch (_range) {
      case _Range.day:
        return '${_start.day} ${ArDates.months[_start.month - 1]} ${_start.year}';
      case _Range.week:
        final e = _end.subtract(const Duration(days: 1));
        return '${_start.day} ${ArDates.months[_start.month - 1]} — '
            '${e.day} ${ArDates.months[e.month - 1]}';
      case _Range.month:
        return ArDates.monthYear(_start);
      case _Range.year:
        return '${_start.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusSessions =
        _sessions.where((s) => s.type == 'focus' && s.completed).toList();
    final pomodoroCount = focusSessions
        .where((s) => s.plannedDurationSec >= 25 * 60)
        .length;
    final uniqueDays = focusSessions
        .map((s) => DateTime.fromMillisecondsSinceEpoch(s.startTime))
        .map((d) => '${d.year}-${d.month}-${d.day}')
        .toSet()
        .length;
    final totalCounts = _sessions.length;
    final totalMinutes =
        _sessions.fold<int>(0, (a, s) => a + s.durationSec ~/ 60);

    return Scaffold(
      backgroundColor: AppColors.routinyBg,
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
            const Text('إحصائيات التركيز',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.chocolate)),
            const SizedBox(height: 18),
            _rangeTabs(),
            const SizedBox(height: 16),
            _dateRow(),
            const SizedBox(height: 16),
            _card1(pomodoroCount, uniqueDays),
            const SizedBox(height: 14),
            _card2(totalCounts, totalMinutes),
            const SizedBox(height: 20),
            const Text('جدول التركيز الزمني',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 12),
            _chart(),
          ],
        ),
      ),
    );
  }

  Widget _rangeTabs() {
    Widget tab(String label, _Range r) {
      final active = _range == r;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() => _range = r);
            _load();
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active
                        ? AppColors.chocolate
                        : AppColors.secondaryText)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DCD0),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(children: [
        tab('يوم', _Range.day),
        tab('أسبوع', _Range.week),
        tab('شهر', _Range.month),
        tab('سنة', _Range.year),
      ]),
    );
  }

  Widget _dateRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () => _shift(1),
            icon: const Icon(Icons.chevron_right,
                color: AppColors.deepChocolate)),
        Text(_rangeLabel,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.deepChocolate)),
        IconButton(
            onPressed: () => _shift(-1),
            icon: const Icon(Icons.chevron_left,
                color: AppColors.deepChocolate)),
      ],
    );
  }

  Widget _card1(int pomodoro, int days) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _stat('🍅 جلسات البومودورو', '$pomodoro')),
          Container(width: 1, height: 56, color: const Color(0xFFF0E1D5)),
          Expanded(child: _stat('أيام التركيز', '$days')),
        ],
      ),
    );
  }

  Widget _card2(int total, int minutes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _row('إجمالي الجلسات', '$total مرة'),
          const Divider(color: Color(0xFFF0E1D5)),
          _row('إجمالي وقت التركيز', '$minutes دقيقة'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    color: AppColors.secondaryText)),
          ),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.deepChocolate)),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 13,
                color: AppColors.secondaryText)),
      ],
    );
  }

  Widget _chart() {
    // bucket minutes by day index across the range
    final buckets = <int, double>{};
    int slots;
    switch (_range) {
      case _Range.day:
        slots = 24;
        break;
      case _Range.week:
        slots = 7;
        break;
      case _Range.month:
        slots = DateTime(_anchor.year, _anchor.month + 1, 0).day;
        break;
      case _Range.year:
        slots = 12;
        break;
    }
    for (final s in _sessions) {
      final d = DateTime.fromMillisecondsSinceEpoch(s.startTime);
      int idx;
      switch (_range) {
        case _Range.day:
          idx = d.hour;
          break;
        case _Range.week:
          idx = d.difference(_start).inDays;
          break;
        case _Range.month:
          idx = d.day - 1;
          break;
        case _Range.year:
          idx = d.month - 1;
          break;
      }
      buckets[idx] = (buckets[idx] ?? 0) + s.durationSec / 60.0;
    }
    final maxV = buckets.values.fold<double>(1, (a, b) => b > a ? b : a);
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < slots; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: FractionallySizedBox(
                  heightFactor: ((buckets[i] ?? 0) / maxV).clamp(0.0, 1.0),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.ribbonNeutral,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
