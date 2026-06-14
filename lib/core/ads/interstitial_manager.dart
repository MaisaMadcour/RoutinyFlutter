import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

/// Interstitial (full-screen) ad manager — 1:1 with the Android
/// `InterstitialAdManager`. Preloads in the background and supports a separate
/// frequency cap per context so the user isn't spammed.
class InterstitialManager {
  InterstitialManager._();
  static final InterstitialManager instance = InterstitialManager._();

  // ─── contexts + caps ───
  static const ctxFocusEnd = 'focus_end';
  static const ctxTestResult = 'test_result';
  static const ctxReflectionResult = 'reflection_result';
  static const ctxArticleClose = 'article_close';
  static const ctxSupport = 'support_us';

  static const _caps = <String, Duration>{
    ctxFocusEnd: Duration(minutes: 3),
    ctxTestResult: Duration(minutes: 5),
    ctxReflectionResult: Duration(minutes: 5),
    ctxArticleClose: Duration(minutes: 3),
    ctxSupport: Duration.zero,
  };

  InterstitialAd? _ad;
  bool _loading = false;
  final Map<String, DateTime> _lastShown = {};

  bool get isReady => _ad != null;

  void preload() {
    if (_ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  /// Shows an interstitial if one is ready and the per-context cap has elapsed.
  /// Always calls [onDone] afterwards so navigation can continue.
  void showIfReady(String context, {void Function()? onDone}) {
    final done = onDone ?? () {};
    final cap = _caps[context] ?? const Duration(minutes: 1);
    final last = _lastShown[context];
    final ad = _ad;

    final tooSoon = last != null &&
        cap > Duration.zero &&
        DateTime.now().difference(last) < cap;

    if (ad == null || tooSoon) {
      if (ad == null) preload();
      done();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _lastShown[context] = DateTime.now();
        preload();
        done();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        preload();
        done();
      },
      onAdShowedFullScreenContent: (ad) {
        _lastShown[context] = DateTime.now();
      },
    );
    _ad = null;
    ad.show();
  }
}
