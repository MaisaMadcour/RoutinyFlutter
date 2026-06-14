import 'package:flutter/foundation.dart';

/// Central AdMob unit IDs — 1:1 with the Android `AdMobConfig`.
/// Debug builds use Google's official test IDs so real metrics aren't hit.
class AdMobConfig {
  AdMobConfig._();

  // ─── Production (Play Store) ───
  static const _bannerReal = 'ca-app-pub-1631773372582425/8000135908';
  static const _interstitialReal = 'ca-app-pub-1631773372582425/6435772797';
  // TODO: create a Rewarded ad unit in the AdMob account (…582425) and paste
  // its id here. Until then it falls back to Google's test rewarded id.
  static const _rewardedReal = 'ca-app-pub-3940256099942544/5224354917';

  // ─── Google's official test IDs ───
  static const _bannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialTest = 'ca-app-pub-3940256099942544/1033173712';
  static const _rewardedTest = 'ca-app-pub-3940256099942544/5224354917';

  static String get bannerId => kDebugMode ? _bannerTest : _bannerReal;
  static String get interstitialId =>
      kDebugMode ? _interstitialTest : _interstitialReal;
  static String get rewardedId => kDebugMode ? _rewardedTest : _rewardedReal;
}
