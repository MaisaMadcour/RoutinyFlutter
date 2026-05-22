import 'package:flutter/material.dart';

import '../../../core/ar_dates.dart';
import '../../../theme/app_colors.dart';

/// Horizontally-paged week strip. Week starts Sunday.
class WeekCalendar extends StatefulWidget {
  const WeekCalendar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onWeekChanged,
    required this.controller,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final ValueChanged<DateTime> onWeekChanged; // first day of visible week
  final WeekCalendarController controller;

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class WeekCalendarController {
  _WeekCalendarState? _state;
  void jumpToWeekOf(DateTime day) => _state?._jumpToWeekOf(day);
}

class _WeekCalendarState extends State<WeekCalendar> {
  static const _base = 5000; // middle page
  late final DateTime _anchorWeek; // start of "today" week
  late final PageController _pc;

  @override
  void initState() {
    super.initState();
    _anchorWeek = ArDates.startOfWeek(DateTime.now());
    _pc = PageController(initialPage: _base);
    widget.controller._state = this;
  }

  DateTime _weekStartForPage(int page) =>
      _anchorWeek.add(Duration(days: 7 * (page - _base)));

  void _jumpToWeekOf(DateTime day) {
    final target = ArDates.startOfWeek(day);
    final diff = target.difference(_anchorWeek).inDays ~/ 7;
    _pc.jumpToPage(_base + diff);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: PageView.builder(
        controller: _pc,
        onPageChanged: (p) => widget.onWeekChanged(_weekStartForPage(p)),
        itemBuilder: (context, page) {
          final start = _weekStartForPage(page);
          return Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: _DayCell(
                    day: start.add(Duration(days: i)),
                    selected: ArDates.sameDay(
                        start.add(Duration(days: i)), widget.selected),
                    onTap: () =>
                        widget.onSelected(start.add(Duration(days: i))),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.calendarDaySelStart,
                    AppColors.calendarDaySelEnd,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ArDates.dayName(day),
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 12,
                color: selected ? Colors.white : AppColors.deepChocolate,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.transparent,
                border: selected
                    ? null
                    : Border.all(color: AppColors.calendarDayStroke),
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.calendarDayNumberOnWhite
                      : AppColors.deepChocolate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
