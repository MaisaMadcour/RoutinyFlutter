import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../features/care/dynamic_articles.dart';
import '../features/shell/main_shell.dart';
import '../features/tests/test_intro_screen.dart';
import '../features/tests/test_models.dart';

/// Firebase Cloud Messaging — lets the admin broadcast a push notification to
/// every user (via the "all" topic) at any time, even when the app is closed.
///
/// Background / killed: the system tray shows FCM "notification" payloads
/// automatically. Foreground: we post it ourselves through the native channel.
///
/// Deep links: each notification carries a data payload with `type` (article/test)
/// and `id` (Firestore doc ID). Tapping opens the correct screen directly.
class PushNotifications {
  PushNotifications._();

  static const _channel = MethodChannel('com.routiny.routiny/focus');
  static const _broadcastTopic = 'all';

  // Stores a notification tapped while the app was terminated, so MainShell
  // can handle it once the navigator is ready.
  static RemoteMessage? _pendingMessage;

  /// Call once after Firebase.initializeApp(). Safe to fail (e.g. no config).
  static Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      await messaging.subscribeToTopic(_broadcastTopic);

      // Terminated state: user tapped notification that launched the app.
      final initial = await messaging.getInitialMessage();
      if (initial != null) _pendingMessage = initial;

      // Background state: user taps notification while app is in background.
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // Foreground: notification arrives while app is open — show in tray.
      FirebaseMessaging.onMessage.listen((msg) {
        final n = msg.notification;
        if (n == null) return;
        _showNative(n.title ?? 'روتيني', n.body ?? '');
      });
    } catch (e) {
      if (kDebugMode) debugPrint('PushNotifications.init failed: $e');
    }
  }

  /// Call from MainShell.initState (via addPostFrameCallback) to handle any
  /// notification that launched the app from a terminated state.
  static void handlePending() {
    final msg = _pendingMessage;
    if (msg == null) return;
    _pendingMessage = null;
    _handleMessage(msg);
  }

  // ── Deep link routing ────────────────────────────────────────────────────

  static Future<void> _handleMessage(RemoteMessage msg) async {
    final type = msg.data['type'] as String?;
    final id   = msg.data['id']   as String?;
    if (type == null || id == null || id.isEmpty) return;

    if (type == 'article') {
      await _openArticle(id);
    } else if (type == 'test') {
      await _openTest(id);
    }
  }

  static Future<void> _openArticle(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('articles')
          .doc(id)
          .get();
      if (!doc.exists) return;
      final article = DynamicArticle.fromDoc(doc);
      if (article == null) return;

      // Switch to care tab (index 1), then push the article screen.
      ShellController.tab.value = 1;
      await Future.delayed(const Duration(milliseconds: 120));
      final ctx = RoutinyApp.navigatorKey.currentContext;
      if (ctx == null) return;
      Navigator.of(ctx).push(MaterialPageRoute(
        builder: (_) => DynamicArticleScreen(
          article: article,
          accent: const Color(0xFFE8A0A0),
        ),
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('_openArticle failed: $e');
    }
  }

  static Future<void> _openTest(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tests')
          .doc(id)
          .get();
      if (!doc.exists) return;
      final test = MentalTest.fromFirestore(doc);

      // Switch to tests tab (index 4), then push the test intro screen.
      ShellController.tab.value = 4;
      await Future.delayed(const Duration(milliseconds: 120));
      final ctx = RoutinyApp.navigatorKey.currentContext;
      if (ctx == null) return;
      Navigator.of(ctx).push(MaterialPageRoute(
        builder: (_) => TestIntroScreen(test: test),
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('_openTest failed: $e');
    }
  }

  // ── Native foreground notification ───────────────────────────────────────

  static Future<void> _showNative(String title, String body) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }
}

/// Background isolate handler — required entry point for FCM when the app is
/// backgrounded/terminated. The system already renders the tray notification;
/// this just keeps the isolate valid.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
