import 'dart:math';
import '../models/ad_model.dart';
import 'ad_storage_service.dart';

class AdService {
  final Random _random = Random();
  final AdStorageService _adStorage = AdStorageService();

  Future<List<Map<String, dynamic>>> getAvailableAds(AdLevel level) async {
    return await _adStorage.getAdsByLevel(level);
  }

  Future<AdModel> getNextAd(AdLevel level) async {
    // First, try to get custom ads from admin
    final customAds = await getAvailableAds(level);

    if (customAds.isNotEmpty) {
      // Pick a random custom ad
      final adData = customAds[_random.nextInt(customAds.length)];
      return AdModel(
        id: adData['id'],
        level: level,
        durationSeconds: adData['durationSeconds'] ?? 30,
      );
    }

    // Fallback to generated ad if no custom ads available
    return generateAd(level);
  }

  AdModel generateAd(AdLevel level) {
    final id =
        'ad_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';

    int duration;
    switch (level) {
      case AdLevel.oddiy:
        duration = 15 + _random.nextInt(15);
        break;
      case AdLevel.orta:
        duration = 20 + _random.nextInt(20);
        break;
      case AdLevel.jiddiy:
        duration = 30 + _random.nextInt(30);
        break;
    }

    return AdModel(id: id, level: level, durationSeconds: duration);
  }

  double calculateReward(AdLevel level, {bool isPremium = false}) {
    double baseReward = level.reward;
    if (isPremium) {
      baseReward *= 1.5;
    }
    return double.parse(baseReward.toStringAsFixed(2));
  }

  double calculateCustomReward(
    Map<String, dynamic> ad, {
    bool isPremium = false,
  }) {
    double baseReward = (ad['reward'] ?? 0.10).toDouble();
    if (isPremium) {
      baseReward *= 1.5;
    }
    return double.parse(baseReward.toStringAsFixed(2));
  }

  List<AdModel> generateDailyAds() {
    final List<AdModel> ads = [];

    for (int i = 0; i < 10; i++) {
      ads.add(generateAd(AdLevel.oddiy));
    }
    for (int i = 0; i < 8; i++) {
      ads.add(generateAd(AdLevel.orta));
    }
    for (int i = 0; i < 5; i++) {
      ads.add(generateAd(AdLevel.jiddiy));
    }

    ads.shuffle(_random);
    return ads;
  }
}
