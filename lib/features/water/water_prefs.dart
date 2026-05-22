import '../../core/prefs.dart';
import '../../core/routiny_stats.dart';

/// Water-tracker preferences & intake log — mirrors Android WaterPrefs.
class WaterPrefs {
  WaterPrefs._();

  static int get dailyGoal => Prefs.I.getInt('water_daily_goal', 8).clamp(1, 30);
  static set dailyGoal(int v) =>
      Prefs.I.setInt('water_daily_goal', v.clamp(1, 30));

  static int get cupSizeMl =>
      Prefs.I.getInt('water_cup_size_ml', 250).clamp(50, 1000);
  static set cupSizeMl(int v) =>
      Prefs.I.setInt('water_cup_size_ml', v.clamp(50, 1000));

  static bool get reminderEnabled =>
      Prefs.I.getBool('water_reminder_enabled', true);
  static set reminderEnabled(bool v) =>
      Prefs.I.setBool('water_reminder_enabled', v);

  static int get reminderIntervalMin =>
      Prefs.I.getInt('water_reminder_interval_min', 120).clamp(30, 240);
  static set reminderIntervalMin(int v) =>
      Prefs.I.setInt('water_reminder_interval_min', v.clamp(30, 240));

  static bool get notificationSoundEnabled =>
      Prefs.I.getBool('water_notification_sound_enabled', true);
  static set notificationSoundEnabled(bool v) =>
      Prefs.I.setBool('water_notification_sound_enabled', v);

  static int mlForDate(DateTime d) => Prefs.I.getInt('water_ml_${ymd(d)}', 0);

  static int get todayMl => mlForDate(DateTime.now());

  static Future<void> addMl(int ml) async {
    final key = 'water_ml_${ymd(DateTime.now())}';
    await Prefs.I.setInt(key, Prefs.I.getInt(key, 0) + ml);
    await Prefs.I.setInt('water_last_${ymd(DateTime.now())}', ml);
  }

  static Future<void> undoLast() async {
    final lastKey = 'water_last_${ymd(DateTime.now())}';
    final last = Prefs.I.getInt(lastKey, 0);
    if (last == 0) return;
    final key = 'water_ml_${ymd(DateTime.now())}';
    await Prefs.I.setInt(key, (Prefs.I.getInt(key, 0) - last).clamp(0, 1 << 30));
    await Prefs.I.setInt(lastKey, 0);
  }

  static int get goalMl => dailyGoal * cupSizeMl;

  static int currentStreak() {
    var streak = 0;
    var day = DateTime.now();
    if (mlForDate(day) < goalMl) {
      day = day.subtract(const Duration(days: 1));
    }
    for (var i = 0; i < 90; i++) {
      if (mlForDate(day) >= goalMl) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
