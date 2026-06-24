import 'package:flutter/services.dart';

import 'prefs.dart';

/// Schedules one-off seasonal "campaign" notifications at exact times via the
/// native AlarmManager. Each campaign is scheduled at most once (guarded by a
/// Prefs flag) and the native side ignores any trigger time already in the past.
class CampaignNotifications {
  CampaignNotifications._();

  static const _channel = MethodChannel('com.routiny.routiny/focus');

  /// One entry per one-off notification.
  static final List<_Campaign> _campaigns = [
    _Campaign(
      id: 7101,
      flag: 'campaign_ashura_night',
      title: 'عاشوراء يوم مغفرة وصفاء قلب 🤍',
      body: 'لا تفوّتي صيامه ودعواتك الحلوة 🌙 سجّلي نيّتك ومهامك في روتيني 🤍',
      // ليلة عاشوراء — 12 منتصف الليل (بداية 25 يونيو 2026)
      when: DateTime(2026, 6, 25, 0, 0),
    ),
    _Campaign(
      id: 7102,
      flag: 'campaign_ashura_noon',
      title: 'عاشوراء يوم مبارك 🌿',
      body: 'خصصي لحظة لنفسك… تأمّلي، ادعي، واكتبي نيّتك في روتيني 🤍',
      // ظهر عاشوراء — 12 الظهر (25 يونيو 2026)
      when: DateTime(2026, 6, 25, 12, 0),
    ),
  ];

  /// Schedule any pending campaigns. Safe to call on every app launch.
  static Future<void> scheduleAll() async {
    for (final c in _campaigns) {
      if (Prefs.I.getBool(c.flag)) continue; // already scheduled once
      try {
        await _channel.invokeMethod('scheduleCampaign', {
          'id': c.id,
          'title': c.title,
          'body': c.body,
          'triggerAtMillis': c.when.millisecondsSinceEpoch,
        });
        await Prefs.I.setBool(c.flag, true);
      } catch (_) {
        // platform without the handler (e.g. iOS) — skip silently
      }
    }
  }
}

class _Campaign {
  const _Campaign({
    required this.id,
    required this.flag,
    required this.title,
    required this.body,
    required this.when,
  });

  final int id;
  final String flag;
  final String title;
  final String body;
  final DateTime when;
}
