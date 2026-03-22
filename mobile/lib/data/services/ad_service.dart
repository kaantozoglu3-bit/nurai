import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/ad_constants.dart';

/// Manages AdMob rewarded and banner ads.
/// Premium users never see ads — check [shouldShowAds] before loading.
class AdService {
  RewardedAd? _rewardedAd;
  bool _isLoadingRewarded = false;

  // ─── Init ─────────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    if (kDebugMode) debugPrint('[AdService] MobileAds initialized');
  }

  // ─── Premium check ────────────────────────────────────────────────────────

  bool shouldShowAds(bool isPremium) => !isPremium && !kIsWeb;

  // ─── Rewarded Ad ──────────────────────────────────────────────────────────

  Future<void> loadRewardedAd() async {
    if (kIsWeb || _isLoadingRewarded || _rewardedAd != null) return;
    _isLoadingRewarded = true;
    await RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
          if (kDebugMode) debugPrint('[AdService] Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoadingRewarded = false;
          if (kDebugMode) debugPrint('[AdService] Rewarded ad failed: ${error.message}');
        },
      ),
    );
  }

  /// Shows the rewarded ad. Returns true if the user earned the reward.
  Future<bool> showRewardedAd() async {
    if (kIsWeb) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      await loadRewardedAd();
      return false;
    }

    final completer = Completer<bool>();
    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        if (kDebugMode) debugPrint('[AdService] Show failed: ${error.message}');
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) {
        rewarded = true;
        if (kDebugMode) debugPrint('[AdService] Reward earned: ${reward.amount}');
      },
    );

    return completer.future;
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  // ─── Banner Ad ────────────────────────────────────────────────────────────

  /// Creates and loads a banner ad. Caller must dispose when done.
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (kDebugMode) debugPrint('[AdService] Banner loaded');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) debugPrint('[AdService] Banner failed: ${error.message}');
        },
      ),
    )..load();
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
