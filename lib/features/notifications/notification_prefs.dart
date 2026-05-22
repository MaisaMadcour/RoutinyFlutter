import '../../core/prefs.dart';

/// Notification toggles — mirrors Android NotificationPrefs.
class NotificationPrefs {
  NotificationPrefs._();

  static const _all = 'notif_all_enabled';
  static const _tips = 'notif_tips_enabled';
  static const _habit = 'notif_habit_enabled';
  static const _focusRunning = 'notif_focus_running_enabled';
  static const _focusCompletion = 'notif_focus_completion_enabled';
  static const _inactivity = 'notif_inactivity_enabled';

  static bool get allEnabled => Prefs.I.getBool(_all, true);
  static set allEnabled(bool v) => Prefs.I.setBool(_all, v);

  static bool rawTips() => Prefs.I.getBool(_tips, true);
  static bool rawHabit() => Prefs.I.getBool(_habit, true);
  static bool rawFocusRunning() => Prefs.I.getBool(_focusRunning, true);
  static bool rawFocusCompletion() => Prefs.I.getBool(_focusCompletion, true);
  static bool rawInactivity() => Prefs.I.getBool(_inactivity, true);

  static set tips(bool v) => Prefs.I.setBool(_tips, v);
  static set habit(bool v) => Prefs.I.setBool(_habit, v);
  static set focusRunning(bool v) => Prefs.I.setBool(_focusRunning, v);
  static set focusCompletion(bool v) => Prefs.I.setBool(_focusCompletion, v);
  static set inactivity(bool v) => Prefs.I.setBool(_inactivity, v);

  static bool get tipsEnabled => allEnabled && rawTips();
  static bool get habitEnabled => allEnabled && rawHabit();
  static bool get focusRunningEnabled => allEnabled && rawFocusRunning();
  static bool get focusCompletionEnabled =>
      allEnabled && rawFocusCompletion();
  static bool get inactivityEnabled => allEnabled && rawInactivity();
}
