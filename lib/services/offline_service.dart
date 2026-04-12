import '../models/ad_model.dart';
import '../utils/app_logger.dart';
import 'cache_service.dart';
import 'network_service.dart';

class OfflineAd {
  final String id;
  final AdLevel level;
  final DateTime queuedAt;
  final String? customData;

  OfflineAd({
    required this.id,
    required this.level,
    required this.queuedAt,
    this.customData,
  });

  factory OfflineAd.fromJson(Map<String, dynamic> json) {
    return OfflineAd(
      id: json['id'] ?? '',
      level: AdLevel.values.firstWhere(
        (e) => e.toString() == 'AdLevel.${json['level']}',
        orElse: () => AdLevel.orta,
      ),
      queuedAt: DateTime.parse(
        json['queuedAt'] ?? DateTime.now().toIso8601String(),
      ),
      customData: json['customData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level.toString().split('.').last,
      'queuedAt': queuedAt.toIso8601String(),
      'customData': customData,
    };
  }
}

class PendingReward {
  final String userId;
  final double amount;
  final String description;
  final AdLevel? adLevel;
  final DateTime earnedAt;

  PendingReward({
    required this.userId,
    required this.amount,
    required this.description,
    this.adLevel,
    required this.earnedAt,
  });

  factory PendingReward.fromJson(Map<String, dynamic> json) {
    return PendingReward(
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      adLevel: json['adLevel'] != null
          ? AdLevel.values.firstWhere(
              (e) => e.toString() == 'AdLevel.${json['adLevel']}',
              orElse: () => AdLevel.orta,
            )
          : null,
      earnedAt: DateTime.parse(
        json['earnedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'description': description,
      'adLevel': adLevel?.toString().split('.').last,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final _cacheService = CacheService();
  final _networkService = NetworkService();

  bool get isOnline => _networkService.isConnected;

  Future<void> initialize() async {
    await _cacheService.initialize();
    AppLogger.info('OfflineService initialized');
  }

  // Queue an ad for offline watching
  Future<void> queueOfflineAd(
    String userId,
    AdLevel level, {
    String? customData,
  }) async {
    final offlineAd = OfflineAd(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      level: level,
      queuedAt: DateTime.now(),
      customData: customData,
    );

    final key = 'offline_ads_$userId';
    final existing = await _getOfflineAds(userId);
    existing.add(offlineAd);

    await _cacheService.cacheData(
      CacheService.offlineBox,
      key,
      existing.map((e) => e.toJson()).toList(),
    );

    AppLogger.info('Ad queued for offline watching: ${offlineAd.id}');
  }

  Future<List<OfflineAd>> _getOfflineAds(String userId) async {
    final key = 'offline_ads_$userId';
    final data = await _cacheService.getCachedData<List<dynamic>>(
      CacheService.offlineBox,
      key,
    );

    if (data == null) return [];

    return data
        .map((e) => OfflineAd.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Get queued offline ads
  Future<List<OfflineAd>> getQueuedAds(String userId) async {
    return await _getOfflineAds(userId);
  }

  // Watch an offline ad
  Future<void> watchOfflineAd(String userId, String adId) async {
    final ads = await _getOfflineAds(userId);
    final ad = ads.firstWhere((a) => a.id == adId);

    // Calculate reward
    final reward = _calculateReward(ad.level);

    // Queue the reward
    await _queuePendingReward(
      userId,
      reward,
      'Offline ${ad.level.name} ad watched',
      ad.level,
    );

    // Remove the ad from queue
    ads.removeWhere((a) => a.id == adId);
    await _cacheService.cacheData(
      CacheService.offlineBox,
      'offline_ads_$userId',
      ads.map((e) => e.toJson()).toList(),
    );

    AppLogger.info('Offline ad watched: $adId, reward: $reward');
  }

  double _calculateReward(AdLevel level) {
    switch (level) {
      case AdLevel.oddiy:
        return 0.1;
      case AdLevel.orta:
        return 0.2;
      case AdLevel.jiddiy:
        return 0.5;
    }
  }

  // Queue a pending reward
  Future<void> _queuePendingReward(
    String userId,
    double amount,
    String description,
    AdLevel? adLevel,
  ) async {
    final reward = PendingReward(
      userId: userId,
      amount: amount,
      description: description,
      adLevel: adLevel,
      earnedAt: DateTime.now(),
    );

    final key = 'pending_rewards_$userId';
    final existing = await _getPendingRewards(userId);
    existing.add(reward);

    await _cacheService.cacheData(
      CacheService.offlineBox,
      key,
      existing.map((e) => e.toJson()).toList(),
    );

    AppLogger.info('Reward queued for sync: $amount so\'m');
  }

  Future<List<PendingReward>> _getPendingRewards(String userId) async {
    final key = 'pending_rewards_$userId';
    final data = await _cacheService.getCachedData<List<dynamic>>(
      CacheService.offlineBox,
      key,
    );

    if (data == null) return [];

    return data
        .map((e) => PendingReward.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Get pending rewards
  Future<List<PendingReward>> getPendingRewards(String userId) async {
    return await _getPendingRewards(userId);
  }

  // Sync pending rewards when online
  Future<SyncResult> syncPendingRewards(String userId) async {
    if (!isOnline) {
      return SyncResult(
        success: false,
        message: 'Internet ulanishi yo\'q',
        syncedCount: 0,
      );
    }

    final rewards = await _getPendingRewards(userId);
    if (rewards.isEmpty) {
      return SyncResult(
        success: true,
        message: 'Sinxronlashish uchun ma\'lumot yo\'q',
        syncedCount: 0,
      );
    }

    int syncedCount = 0;
    double totalSynced = 0.0;

    try {
      // In a real app, this would call your backend API
      // For now, we'll just process them locally
      for (final reward in rewards) {
        // Add to wallet
        // await _walletService.addEarning(...)
        syncedCount++;
        totalSynced += reward.amount;
      }

      // Clear synced rewards
      await _cacheService.cacheData(
        CacheService.offlineBox,
        'pending_rewards_$userId',
        [],
      );

      AppLogger.info('Synced $syncedCount rewards, total: $totalSynced so\'m');

      return SyncResult(
        success: true,
        message: '$syncedCount ta mukofot sinxronlandi',
        syncedCount: syncedCount,
        totalAmount: totalSynced,
      );
    } catch (e) {
      AppLogger.error('Error syncing rewards', e);
      return SyncResult(
        success: false,
        message: 'Sinxronlashda xatolik: $e',
        syncedCount: syncedCount,
      );
    }
  }

  // Get offline stats
  Future<Map<String, dynamic>> getOfflineStats(String userId) async {
    final queuedAds = await _getOfflineAds(userId);
    final pendingRewards = await _getPendingRewards(userId);

    final totalPendingAmount = pendingRewards.fold<double>(
      0.0,
      (sum, r) => sum + r.amount,
    );

    return {
      'queuedAds': queuedAds.length,
      'pendingRewards': pendingRewards.length,
      'totalPendingAmount': totalPendingAmount,
      'isOnline': isOnline,
    };
  }

  // Check if sync is needed
  Future<bool> needsSync(String userId) async {
    final rewards = await _getPendingRewards(userId);
    return rewards.isNotEmpty;
  }

  // Clear all offline data
  Future<void> clearOfflineData(String userId) async {
    await _cacheService.delete(CacheService.offlineBox, 'offline_ads_$userId');
    await _cacheService.delete(
      CacheService.offlineBox,
      'pending_rewards_$userId',
    );
    AppLogger.info('Offline data cleared for user $userId');
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final double? totalAmount;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    this.totalAmount,
  });
}
