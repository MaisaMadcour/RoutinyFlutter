import 'package:flutter/services.dart';

class WaterReminderService {
  static const _channel = MethodChannel('com.routiny.routiny/focus');

  static Future<void> apply({required bool enabled}) async {
    try {
      if (enabled) {
        await _channel.invokeMethod('scheduleWaterReminder');
      } else {
        await _channel.invokeMethod('cancelWaterReminder');
      }
    } on PlatformException catch (_) {
      // non-Android platforms
    }
  }
}
