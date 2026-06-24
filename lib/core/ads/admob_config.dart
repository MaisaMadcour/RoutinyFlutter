import 'dart:io';

import 'package:flutter/foundation.dart';

/// Central AdMob unit IDs — platform-aware (Android + iOS).
/// Debug builds use Google's official test IDs so real metrics aren't hit.
class AdMobConfig {
  AdMobConfig._();

  // ─── Android — Production (Play Store) ───
  static const _bannerAndroid = 'ca-app-pub-1631773372582425/8000135908';
  static const _interstitialAndroid = 'ca-app-pub-1631773372582425/6435772797';
  static const _rewardedAndroid = 'ca-app-pub-1631773372582425/4348951886';

  // ─── iOS — Production (App Store) ───
  // ⚠️ TODO: استبدلي القيم دي بوحدات iOS الحقيقية بعد إنشاء تطبيق iOS في AdMob.
  // App ID بتاع iOS وكمان وحدات الإعلانات لازم تكون iOS — الأندرويد مش بيشتغل.
  static const _bannerIOS = 'ca-app-pub-1631773372582425/0000000001';
  static const _interstitialIOS = 'ca-app-pub-1631773372582425/0000000002';
  static const _rewardedIOS = 'ca-app-pub-1631773372582425/0000000003';

  // ─── Google's official TEST IDs ───
  static const _bannerTestA = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialTestA = 'ca-app-pub-3940256099942544/1033173712';
  static const _rewardedTestA = 'ca-app-pub-3940256099942544/5224354917';
  static const _bannerTestI = 'ca-app-pub-3940256099942544/2934735716';
  static const _interstitialTestI = 'ca-app-pub-3940256099942544/4411468910';
  static const _rewardedTestI = 'ca-app-pub-3940256099942544/1712485313';

  static bool get _ios => Platform.isIOS;

  static String get bannerId {
    if (kDebugMode) return _ios ? _bannerTestI : _bannerTestA;
    return _ios ? _bannerIOS : _bannerAndroid;
  }

  static String get interstitialId {
    if (kDebugMode) return _ios ? _interstitialTestI : _interstitialTestA;
    return _ios ? _interstitialIOS : _interstitialAndroid;
  }

  static String get rewardedId {
    if (kDebugMode) return _ios ? _rewardedTestI : _rewardedTestA;
    return _ios ? _rewardedIOS : _rewardedAndroid;
  }
}
