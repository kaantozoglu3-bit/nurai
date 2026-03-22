/// AdMob configuration.
/// Set [useTestAds] = false after Play Store approval and replace
/// production IDs with real AdMob ad unit IDs.
class AdConstants {
  AdConstants._();

  /// Switch to false after receiving AdMob approval + Play Store listing.
  static const bool useTestAds = true;

  static String get rewardedAdUnitId => useTestAds
      ? 'ca-app-pub-3940256099942544/5224354917' // Google test ID
      : 'BURAYA_GERCEK_REWARDED_ID';

  static String get bannerAdUnitId => useTestAds
      ? 'ca-app-pub-3940256099942544/6300978111' // Google test ID
      : 'BURAYA_GERCEK_BANNER_ID';
}
