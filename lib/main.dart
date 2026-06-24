import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/ads/interstitial_manager.dart';
import 'core/ads/rewarded_manager.dart';
import 'core/campaign_notifications.dart';
import 'core/lang_notifier.dart';
import 'core/prefs.dart';
import 'core/push_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.I.init();
  LangNotifier.init();
  await initializeDateFormatting('ar');
  // Firebase + push notifications (broadcast to all users via the "all" topic).
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    PushNotifications.init();
  } catch (_) {
    // Firebase not configured yet — app still runs without push.
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF7E6DE),
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFFDF5F1),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  // Schedule any pending one-off seasonal notifications (e.g. Ashura).
  CampaignNotifications.scheduleAll();
  // Initialize AdMob and preload the first interstitial in the background.
  MobileAds.instance.initialize().then((_) {
    // Register the dev/test phone so it always serves test ads (real users
    // are unaffected). Lets us verify ad slots before the app has live traffic.
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['2D5B5BD9F922B5A226D22B131500CAD5'],
      ),
    );
    InterstitialManager.instance.preload();
    RewardedManager.instance.preload();
  });
  runApp(const RoutinyApp());
}
