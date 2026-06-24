import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Firebase Cloud Messaging — lets the admin broadcast a push notification to
/// every user (via the "all" topic) at any time, even when the app is closed.
///
/// Background / killed: the system tray shows FCM "notification" payloads
/// automatically. Foreground: we post it ourselves through the native channel.
class PushNotifications {
  PushNotifications._();

  static const _channel = MethodChannel('com.routiny.routiny/focus');
  static const _broadcastTopic = 'all';

  /// Call once after Firebase.initializeApp(). Safe to fail (e.g. no config).
  static Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      // Everyone is subscribed to "all" → admin sends to that topic to reach
      // the whole user base in one shot.
      await messaging.subscribeToTopic(_broadcastTopic);

      // Foreground messages don't auto-display — post them via native.
      FirebaseMessaging.onMessage.listen((msg) {
        final n = msg.notification;
        if (n == null) return;
        _showNative(n.title ?? 'روتيني', n.body ?? '');
      });
    } catch (e) {
      if (kDebugMode) debugPrint('PushNotifications.init failed: $e');
    }
  }

  static Future<void> _showNative(String title, String body) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
      });
    } catch (_) {
      // native handler unavailable — ignore
    }
  }
}

/// Background isolate handler — required entry point for FCM when the app is
/// backgrounded/terminated. The system already renders the tray notification;
/// this just keeps the isolate valid.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
