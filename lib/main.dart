import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/ads/interstitial_manager.dart';
import 'core/lang_notifier.dart';
import 'core/prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.I.init();
  LangNotifier.init();
  await initializeDateFormatting('ar');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF7E6DE),
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFFDF5F1),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  // Initialize AdMob and preload the first interstitial in the background.
  MobileAds.instance.initialize().then((_) {
    InterstitialManager.instance.preload();
  });
  runApp(const RoutinyApp());
}
