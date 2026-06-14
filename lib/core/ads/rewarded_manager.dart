import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

/// Rewarded ad manager — used to gate the optional "مذكراتي" journal feature.
/// Preloads in the background.
///
/// Fail-closed: the reward is granted ONLY when the user actually watches a
/// rewarded ad to completion. If no ad is available (no internet / no fill) or
/// the user closes it early, [onUnavailable] fires and the feature stays locked.
class RewardedManager {
  RewardedManager._();
  static final RewardedManager instance = RewardedManager._();

  RewardedAd? _ad;
  bool _loading = false;

  bool get isReady => _ad != null;

  void preload() {
    if (_ad != null || _loading) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  /// Shows a rewarded ad. Calls [onReward] only after the user fully watches
  /// it and earns the reward. If no ad is ready (no internet / not loaded yet)
  /// or the user dismisses it early, [onUnavailable] fires instead.
  void show({
    required void Function() onReward,
    void Function()? onUnavailable,
  }) {
    final unavailable = onUnavailable ?? () {};
    final ad = _ad;
    if (ad == null) {
      preload(); // try to have one ready for the next attempt
      unavailable();
      return;
    }
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        preload();
        if (earned) {
          onReward();
        } else {
          unavailable(); // closed before earning → stay locked
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _ad = null;
        preload();
        unavailable();
      },
    );
    _ad = null;
    ad.show(onUserEarnedReward: (_, __) => earned = true);
  }
}
