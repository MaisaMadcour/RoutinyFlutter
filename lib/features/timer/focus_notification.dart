import 'package:flutter/services.dart';

/// Bridge to the native foreground service that shows the persistent focus
/// timer notification (lock screen + status bar).
class FocusNotification {
  FocusNotification._();
  static const _channel = MethodChannel('com.routiny.routiny/focus');

  /// Start the foreground service + notification for a [minutes] session.
  static Future<void> start({
    required int minutes,
    required String taskTitle,
    required int pomodoroNumber,
  }) async {
    try {
      await _channel.invokeMethod('start', {
        'minutes': minutes,
        'taskTitle': taskTitle,
        'pomodoroNumber': pomodoroNumber,
      });
    } catch (_) {/* service start can fail on some OEMs — ignore */}
  }

  /// Push the authoritative remaining time (used when a phase changes,
  /// e.g. focus → break → next pomodoro).
  static Future<void> update({
    required int seconds,
    required String taskTitle,
    required int pomodoroNumber,
  }) async {
    try {
      await _channel.invokeMethod('update', {
        'seconds': seconds,
        'taskTitle': taskTitle,
        'pomodoroNumber': pomodoroNumber,
      });
    } catch (_) {}
  }

  /// Stop the service + clear the notification.
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {}
  }
}
