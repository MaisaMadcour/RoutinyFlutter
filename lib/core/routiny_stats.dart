import 'prefs.dart';

String ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Streak / completion / profile stats — mirrors Android RoutinyStats.
class RoutinyStats {
  RoutinyStats._();

  static const _kSubChecks = 'stats_subtask_checks';
  static const _kCompletedDays = 'stats_completed_task_days';
  static const _kCreationDates = 'stats_task_creation_dates';
  static const _kBreathingDays = 'stats_breathing_days';
  static const _kUserName = 'user_name';
  static const _kAvatarPath = 'avatar_path';

  // ---- subtask checks ----
  // Keyed per DATE ("taskId|index|yyyy-MM-dd") so each day is independent —
  // a future/other day starts unchecked and only the user can mark it.
  static bool isSubtaskChecked(int taskId, int index, String dateYmd) =>
      Prefs.I.setContains(_kSubChecks, '$taskId|$index|$dateYmd');

  static Future<void> setSubtaskChecked(
      int taskId, int index, String dateYmd, bool checked) async {
    if (checked) {
      await Prefs.I.addToSet(_kSubChecks, '$taskId|$index|$dateYmd');
    } else {
      await Prefs.I.removeFromSet(_kSubChecks, '$taskId|$index|$dateYmd');
    }
  }

  static Future<void> clearSubtaskChecks(int taskId) async {
    final list = Prefs.I.getList(_kSubChecks)
      ..removeWhere((e) => e.startsWith('$taskId|'));
    await Prefs.I.setList(_kSubChecks, list);
  }

  // ---- completed task-days ----
  static Future<void> recordTaskCompleted(int taskId, String dateYmd) async {
    await Prefs.I.addToSet(_kCompletedDays, '$taskId|$dateYmd');
  }

  static Future<void> unrecordTaskCompleted(int taskId, String dateYmd) async {
    await Prefs.I.removeFromSet(_kCompletedDays, '$taskId|$dateYmd');
  }

  static int get tasksCompletedCount => Prefs.I.getList(_kCompletedDays).length;

  static Set<int> completedDaysInMonth(int year, int month) {
    // entries look like "taskId|yyyy-MM-dd"
    final ym = '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}';
    final days = <int>{};
    for (final e in Prefs.I.getList(_kCompletedDays)) {
      final parts = e.split('|');
      if (parts.length != 2) continue;
      final date = parts[1]; // yyyy-MM-dd
      if (date.length == 10 && date.startsWith('$ym-')) {
        final day = int.tryParse(date.substring(8));
        if (day != null) days.add(day);
      }
    }
    return days;
  }

  // ---- breathing days ----
  static Future<void> recordBreathingDay() async {
    await Prefs.I.addToSet(_kBreathingDays, ymd(DateTime.now()));
  }

  static Set<int> breathingDaysInMonth(int year, int month) {
    final ym = '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}';
    final days = <int>{};
    for (final date in Prefs.I.getList(_kBreathingDays)) {
      if (date.length == 10 && date.startsWith('$ym-')) {
        final day = int.tryParse(date.substring(8));
        if (day != null) days.add(day);
      }
    }
    return days;
  }

  // ---- creation / streak ----
  static Future<void> recordTaskCreation() async {
    await Prefs.I.addToSet(_kCreationDates, ymd(DateTime.now()));
  }

  static int get dayStreak => Prefs.I.getList(_kCreationDates).length;

  // ---- profile ----
  static String get userName =>
      Prefs.I.getString(_kUserName) ?? 'اسم المستخدم';
  static Future<void> setUserName(String v) =>
      Prefs.I.setString(_kUserName, v);

  static String? get avatarPath => Prefs.I.getString(_kAvatarPath);
  static Future<void> setAvatarPath(String v) =>
      Prefs.I.setString(_kAvatarPath, v);
}
