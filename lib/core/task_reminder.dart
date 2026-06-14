import 'package:flutter/services.dart';

import 'models.dart';

/// Bridge to the native AlarmManager-based task-reminder scheduler.
/// A task with a set time + reminder enabled fires a notification at that time.
class TaskReminder {
  TaskReminder._();
  // reuses the same platform channel as the focus timer
  static const _channel = MethodChannel('com.routiny.routiny/focus');

  static Future<void> _schedule(
      int id, String title, int hour, int minute) async {
    try {
      await _channel.invokeMethod('scheduleTaskReminder', {
        'id': id,
        'title': title,
        'hour': hour,
        'minute': minute,
      });
    } catch (_) {}
  }

  static Future<void> cancel(int id) async {
    try {
      await _channel.invokeMethod('cancelTaskReminder', {'id': id});
    } catch (_) {}
  }

  /// Schedules (or cancels) a reminder for [task] based on its reminder flag
  /// and time. [id] is the task's database id (used as the notification id).
  static Future<void> sync(int id, TaskEntity task) async {
    final t = task.time;
    if (task.hasReminder && t.contains(':')) {
      final parts = t.split(':');
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      await _schedule(id, task.title, hour, minute);
    } else {
      await cancel(id);
    }
  }
}
