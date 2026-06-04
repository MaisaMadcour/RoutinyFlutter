import 'package:flutter/foundation.dart';

/// Central AdMob unit IDs — 1:1 with the Android `AdMobConfig`.
/// Debug builds use Google's official test IDs so real metrics aren't hit.
class AdMobConfig {
  AdMobConfig._();

  // ─── Production (Play Store) ───
  static const _bannerReal = 'ca-app-pub-1631773372582425/8000135908';
  static const _interstitialReal = 'ca-app-pub-1631773372582425/6435772797';

  // ─── Google's official test IDs ───
  static const _bannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialTest = 'ca-app-pub-3940256099942544/1033173712';

  static String get bannerId => kDebugMode ? _bannerTest : _bannerReal;
  static String get interstitialId =>
      kDebugMode ? _interstitialTest : _interstitialReal;
}
