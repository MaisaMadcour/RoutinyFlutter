import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A miniature month calendar (LTR) that highlights selected days.
class MiniMonthCalendar extends StatefulWidget {
  const MiniMonthCalendar({super.key, required this.highlightProvider});

  /// (year, month) → set of day numbers to highlight.
  final Set<int> Function(int year, int month) highlightProvider;

  @override
  State<MiniMonthCalendar> createState() => _MiniMonthCalendarState();
}

class _MiniMonthCalendarState extends State<MiniMonthCalendar> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final highlights =
        widget.highlightProvider(_month.year, _month.month);
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;
    final daysInMonth =
        DateTime(_month.year, _month.month + 1, 0).day;
    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final hl = highlights.contains(d);
      cells.add(Center(
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: hl
              ? const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle)
              : null,
          child: Text('$d',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  fontWeight: hl ? FontWeight.w700 : FontWeight.w400,
                  color: hl ? Colors.white : const Color(0xFF3E2818))),
        ),
      ));
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _month =
                    DateTime(_month.year, _month.month - 1)),
                icon: const Icon(Icons.chevron_left,
                    color: AppColors.deepChocolate),
              ),
              Expanded(
                child: Text(
                    '${_monthsEn[_month.month - 1]}, ${_month.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E2818))),
              ),
              IconButton(
                onPressed: () => setState(() => _month =
                    DateTime(_month.year, _month.month + 1)),
                icon: const Icon(Icons.chevron_right,
                    color: AppColors.deepChocolate),
              ),
            ],
          ),
          Row(
            children: [
              for (final w in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Expanded(
                  child: Center(
                    child: Text(w,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 11,
                            color: AppColors.secondaryText)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: cells,
          ),
        ],
      ),
    );
  }
}
