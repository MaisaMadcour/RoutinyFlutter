import '../../core/prefs.dart';

/// Pomodoro / timer settings — mirrors Android FocusSettings.
class FocusSettings {
  FocusSettings._();

  static const _kPomoLive = 'fs_pomodoro_live_activity';
  static const _kPomoRem = 'fs_pomodoro_reminders';
  static const _kTimerLive = 'fs_timer_live_activity';
  static const _kTimerRem = 'fs_timer_reminders';
  static const _kPomoMin = 'fs_pomodoro_minutes';
  static const _kCycle = 'fs_pomodoro_cycle_sessions';
  static const _kBreak = 'fs_short_break_minutes';
  static const _kDnd = 'fs_dnd_enabled';

  static bool get pomodoroLiveActivity => Prefs.I.getBool(_kPomoLive, true);
  static set pomodoroLiveActivity(bool v) => Prefs.I.setBool(_kPomoLive, v);

  static bool get pomodoroReminders => Prefs.I.getBool(_kPomoRem, true);
  static set pomodoroReminders(bool v) => Prefs.I.setBool(_kPomoRem, v);

  static bool get timerLiveActivity => Prefs.I.getBool(_kTimerLive, true);
  static set timerLiveActivity(bool v) => Prefs.I.setBool(_kTimerLive, v);

  static bool get timerReminders => Prefs.I.getBool(_kTimerRem, true);
  static set timerReminders(bool v) => Prefs.I.setBool(_kTimerRem, v);

  static int get pomodoroMinutes => Prefs.I.getInt(_kPomoMin, 25);
  static set pomodoroMinutes(int v) => Prefs.I.setInt(_kPomoMin, v);

  static int get pomodoroCycle => Prefs.I.getInt(_kCycle, 4);
  static set pomodoroCycle(int v) => Prefs.I.setInt(_kCycle, v);

  static int get shortBreakMinutes => Prefs.I.getInt(_kBreak, 5);
  static set shortBreakMinutes(int v) => Prefs.I.setInt(_kBreak, v);

  static bool get dndEnabled => Prefs.I.getBool(_kDnd, false);
  static set dndEnabled(bool v) => Prefs.I.setBool(_kDnd, v);
}
