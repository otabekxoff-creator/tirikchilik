import 'dart:async';
import 'dart:math';

import '../models/ad_model.dart';
import '../models/wallet_model.dart';
import '../utils/app_logger.dart';
import 'wallet_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final WalletService _walletService = WalletService();
  final Random _random = Random();

  AdModel? _currentAd;
  bool _isAdLoading = false;
  bool _isAdPlaying = false;

  final StreamController<AdEvent> _adEventsController =
      StreamController<AdEvent>.broadcast();
  Stream<AdEvent> get adEvents => _adEventsController.stream;

  /// Generate daily ads for the user
  List<AdModel> generateDailyAds() {
    final List<AdModel> ads = [];
    final now = DateTime.now();

    // Generate 10 simple ads
    for (int i = 0; i < 10; i++) {
      ads.add(
        AdModel(
          id: 'ad_${now.millisecondsSinceEpoch}_$i',
          level: AdLevel.oddiy,
          durationSeconds: 15 + _random.nextInt(30),
        ),
      );
    }

    // Generate 5 medium ads
    for (int i = 0; i < 5; i++) {
      ads.add(
        AdModel(
          id: 'ad_${now.millisecondsSinceEpoch}_medium_$i',
          level: AdLevel.orta,
          durationSeconds: 30 + _random.nextInt(30),
        ),
      );
    }

    // Generate 3 hard ads
    for (int i = 0; i < 3; i++) {
      ads.add(
        AdModel(
          id: 'ad_${now.millisecondsSinceEpoch}_hard_$i',
          level: AdLevel.jiddiy,
          durationSeconds: 45 + _random.nextInt(60),
        ),
      );
    }

    return ads;
  }

  /// Get available ads (not watched)
  Future<List<AdModel>> getAvailableAds(String userId) async {
    // In real app, this would filter out already watched ads
    return generateDailyAds().where((ad) => !ad.isWatched).toList();
  }

  /// Calculate reward based on ad level and premium status
  double calculateReward(AdLevel level, {bool isPremium = false}) {
    double baseReward;
    switch (level) {
      case AdLevel.oddiy:
        baseReward = 500 + _random.nextInt(500).toDouble();
      case AdLevel.orta:
        baseReward = 1000 + _random.nextInt(1000).toDouble();
      case AdLevel.jiddiy:
        baseReward = 2000 + _random.nextInt(2000).toDouble();
    }

    // Premium users get 2x reward
    return isPremium ? baseReward * 2 : baseReward;
  }

  Future<bool> loadAd(AdLevel level) async {
    if (_isAdLoading) return false;

    _isAdLoading = true;
    _adEventsController.add(AdEvent.loading);

    try {
      await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1500)));

      _currentAd = AdModel(
        id: 'ad_${DateTime.now().millisecondsSinceEpoch}',
        level: level,
        durationSeconds: level == AdLevel.oddiy
            ? 15 + _random.nextInt(30)
            : level == AdLevel.orta
            ? 30 + _random.nextInt(30)
            : 45 + _random.nextInt(60),
      );

      _isAdLoading = false;
      _adEventsController.add(AdEvent.loaded);
      return true;
    } catch (e, st) {
      _isAdLoading = false;
      _adEventsController.add(AdEvent.error);
      AppLogger.error('Ad load error', e, st);
      return false;
    }
  }

  Future<AdResult> watchAd(String userId, AdLevel level) async {
    if (_isAdPlaying) {
      return AdResult(alreadyWatching: true);
    }

    if (_currentAd == null || _currentAd!.level != level) {
      final loaded = await loadAd(level);
      if (!loaded) {
        return AdResult(error: 'Reklama yuklanmadi');
      }
    }

    _isAdPlaying = true;
    _adEventsController.add(AdEvent.started);

    try {
      await Future.delayed(Duration(seconds: _currentAd!.durationSeconds));

      final reward = calculateReward(level);
      final transaction = await _walletService.addEarnings(
        userId,
        reward,
        '${level.label} reklama ko\'rildi',
        adLevel: level.label,
      );

      _isAdPlaying = false;
      _adEventsController.add(AdEvent.completed);

      return AdResult(success: true, reward: reward, transaction: transaction);
    } catch (e, st) {
      _isAdPlaying = false;
      _adEventsController.add(AdEvent.error);
      AppLogger.error('Ad watch error', e, st);
      return AdResult(error: e.toString());
    }
  }

  void skipAd() {
    _isAdPlaying = false;
    _adEventsController.add(AdEvent.skipped);
  }

  void dispose() {
    _adEventsController.close();
  }
}

enum AdEvent { loading, loaded, started, completed, skipped, error }

class AdResult {
  final bool success;
  final bool alreadyWatching;
  final double? reward;
  final Transaction? transaction;
  final String? error;

  AdResult({
    this.success = false,
    this.alreadyWatching = false,
    this.reward,
    this.transaction,
    this.error,
  });
}
