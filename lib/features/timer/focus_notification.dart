import 'package:flutter/services.dart';

/// Bridge to the native foreground service that shows the persistent focus
/// timer notification (lock screen + status bar).
class FocusNotification {
  FocusNotification._();
  static const _channel = MethodChannel('com.routiny.routiny/focus');

  /// Called when the user taps "stop" on the notification — the active running
  /// screen registers this so it can end the in-app session too.
  static void Function()? onStoppedFromNotification;
  static bool _handlerSet = false;

  /// Wire up the native→Dart channel once (native invokes 'stoppedFromNotification').
  static void _ensureHandler() {
    if (_handlerSet) return;
    _handlerSet = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'stoppedFromNotification') {
        onStoppedFromNotification?.call();
      }
      return null;
    });
  }

  /// Start the foreground service + notification for a [minutes] session.
  static Future<void> start({
    required int minutes,
    required String taskTitle,
    required int pomodoroNumber,
    required bool isPomodoro,
    required bool isFinalPhase,
  }) async {
    _ensureHandler();
    try {
      await _channel.invokeMethod('start', {
        'minutes': minutes,
        'taskTitle': taskTitle,
        'pomodoroNumber': pomodoroNumber,
        'isPomodoro': isPomodoro,
        'isFinalPhase': isFinalPhase,
      });
    } catch (_) {/* service start can fail on some OEMs — ignore */}
  }

  /// Push the authoritative remaining time (used when a phase changes,
  /// e.g. focus → break → next pomodoro).
  static Future<void> update({
    required int seconds,
    required String taskTitle,
    required int pomodoroNumber,
    required bool isPomodoro,
    required bool isFinalPhase,
  }) async {
    try {
      await _channel.invokeMethod('update', {
        'seconds': seconds,
        'taskTitle': taskTitle,
        'pomodoroNumber': pomodoroNumber,
        'isPomodoro': isPomodoro,
        'isFinalPhase': isFinalPhase,
      });
    } catch (_) {}
  }

  /// Session finished naturally → pop a heads-up "time's up" notification
  /// and stop the service.
  static Future<void> complete({required bool isPomodoro}) async {
    try {
      await _channel.invokeMethod('complete', {'isPomodoro': isPomodoro});
    } catch (_) {}
  }

  /// Stop the service + clear the notification (no completion alert).
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {}
  }
}
