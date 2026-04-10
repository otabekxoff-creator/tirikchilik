import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/app_logger.dart';

/// Check if running on web
bool get _isWeb => kIsWeb;

/// Google AdMob service for managing ads
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Ad unit IDs - test IDs for development
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;

    // AdMob doesn't support web platform
    if (_isWeb) {
      AppLogger.info('AdMob not supported on web platform');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      AppLogger.info('AdMob initialized successfully');
    } catch (e) {
      AppLogger.severe('AdMob initialization error: $e');
    }
  }

  /// Load banner ad
  BannerAd? loadBannerAd({VoidCallback? onLoaded}) {
    if (!_isInitialized) {
      AppLogger.warning('AdMob not initialized');
      return null;
    }

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AppLogger.info('Banner ad loaded');
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.severe('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
    return _bannerAd;
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) {
      AppLogger.warning('AdMob not initialized');
      return;
    }

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          AppLogger.info('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          AppLogger.severe('Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      AppLogger.warning('Interstitial ad not loaded');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.severe('Interstitial ad failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
      },
    );

    await _interstitialAd!.show();
  }

  /// Load rewarded ad
  Future<void> loadRewardedAd() async {
    if (!_isInitialized) {
      AppLogger.warning('AdMob not initialized');
      return;
    }

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          AppLogger.info('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          AppLogger.severe('Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Show rewarded ad
  Future<bool> showRewardedAd({required Function(double) onReward}) async {
    if (_rewardedAd == null) {
      AppLogger.warning('Rewarded ad not loaded');
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.severe('Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        final amount = reward.amount.toDouble();
        onReward(amount);
        AppLogger.info('User earned reward: $amount');
      },
    );

    return true;
  }

  /// Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    AppLogger.info('AdMob disposed');
  }
}

/// AdMob widget for displaying banner ads
class AdMobBanner extends StatefulWidget {
  const AdMobBanner({super.key});

  @override
  State<AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<AdMobBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adMob = AdMobService();
    _bannerAd = adMob.loadBannerAd(
      onLoaded: () {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// AdMob test device IDs
class AdMobTestDevices {
  static const List<String> testDeviceIds = [
    'EMULATOR', // For emulator testing
  ];
}
