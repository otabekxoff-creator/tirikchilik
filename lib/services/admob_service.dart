import '../utils/app_logger.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      AppLogger.info('AdMob initialized (stub)');
      _initialized = true;
    } catch (e, st) {
      AppLogger.error('AdMob init error', e, st);
    }
  }

  bool get isInitialized => _initialized;

  Future<void> loadInterstitialAd() async {
    AppLogger.info('Loading interstitial ad (stub)');
  }

  Future<void> loadRewardedAd() async {
    AppLogger.info('Loading rewarded ad (stub)');
  }
}
