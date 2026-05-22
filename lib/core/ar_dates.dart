/// Arabic date label helpers.
class ArDates {
  ArDates._();

  static const months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// Short day name. DateTime weekday: Mon=1..Sun=7.
  static const _dayByWeekday = {
    7: 'أحد',
    1: 'اثنين',
    2: 'ثلاثاء',
    3: 'أربعاء',
    4: 'خميس',
    5: 'جمعة',
    6: 'سبت',
  };

  static String dayName(DateTime d) => _dayByWeekday[d.weekday] ?? '';

  static String monthYear(DateTime d) => '${months[d.month - 1]} ${d.year}';

  /// Sunday-based index 0..6 (Sun=0).
  static int sundayIndex(DateTime d) => d.weekday % 7;

  static DateTime startOfWeek(DateTime d) {
    final base = DateTime(d.year, d.month, d.day);
    return base.subtract(Duration(days: sundayIndex(base)));
  }

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
