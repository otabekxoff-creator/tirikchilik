import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_logger.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  bool _initialized = false;

  // Box names
  static const String _usersBox = 'users_cache';
  static const String _walletBox = 'wallet_cache';
  static const String _adsBox = 'ads_cache';
  static const String _settingsBox = 'settings_cache';
  static const String _analyticsBox = 'analytics_cache';
  static const String _offlineBox = 'offline_cache';

  // Public box names for external use
  static String get offlineBox => _offlineBox;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();

      // Open boxes
      await Hive.openBox<Map<String, dynamic>>(_usersBox);
      await Hive.openBox<Map<String, dynamic>>(_walletBox);
      await Hive.openBox<Map<String, dynamic>>(_adsBox);
      await Hive.openBox<dynamic>(_settingsBox);
      await Hive.openBox<Map<String, dynamic>>(_analyticsBox);
      await Hive.openBox<dynamic>(_offlineBox);

      _initialized = true;
      AppLogger.info('CacheService initialized');
    } catch (e, stack) {
      AppLogger.error('CacheService initialization failed', e, stack);
      rethrow;
    }
  }

  // Generic cache operations
  Future<void> cacheData(String boxName, String key, dynamic data) async {
    try {
      final box = Hive.box<dynamic>(boxName);
      await box.put(key, {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e, stack) {
      AppLogger.error('Error caching data: $boxName/$key', e, stack);
    }
  }

  Future<T?> getCachedData<T>(
    String boxName,
    String key, {
    Duration? maxAge,
  }) async {
    try {
      final box = Hive.box<dynamic>(boxName);
      final cached = box.get(key);

      if (cached == null) return null;

      final timestamp = DateTime.parse(cached['timestamp']);

      // Check if cache is expired
      if (maxAge != null) {
        final age = DateTime.now().difference(timestamp);
        if (age > maxAge) {
          await box.delete(key);
          return null;
        }
      }

      return cached['data'] as T?;
    } catch (e, stack) {
      AppLogger.error('Error getting cached data: $boxName/$key', e, stack);
      return null;
    }
  }

  // User cache
  Future<void> cacheUser(String userId, Map<String, dynamic> userData) async {
    await cacheData(_usersBox, userId, userData);
  }

  Future<Map<String, dynamic>?> getCachedUser(String userId) async {
    return getCachedData<Map<String, dynamic>>(
      _usersBox,
      userId,
      maxAge: Duration(hours: 1),
    );
  }

  // Wallet cache
  Future<void> cacheWallet(
    String userId,
    Map<String, dynamic> walletData,
  ) async {
    await cacheData(_walletBox, userId, walletData);
  }

  Future<Map<String, dynamic>?> getCachedWallet(String userId) async {
    return getCachedData<Map<String, dynamic>>(
      _walletBox,
      userId,
      maxAge: Duration(minutes: 5),
    );
  }

  // Ads cache
  Future<void> cacheAds(
    String cacheKey,
    List<Map<String, dynamic>> adsData,
  ) async {
    await cacheData(_adsBox, cacheKey, adsData);
  }

  Future<List<Map<String, dynamic>>?> getCachedAds(String cacheKey) async {
    return getCachedData<List<Map<String, dynamic>>>(
      _adsBox,
      cacheKey,
      maxAge: Duration(hours: 6),
    );
  }

  // Settings cache
  Future<void> cacheSetting(String key, dynamic value) async {
    try {
      final box = Hive.box<dynamic>(_settingsBox);
      await box.put(key, value);
    } catch (e, stack) {
      AppLogger.error('Error caching setting: $key', e, stack);
    }
  }

  Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    try {
      final box = Hive.box<dynamic>(_settingsBox);
      final value = box.get(key);
      return value ?? defaultValue;
    } catch (e, stack) {
      AppLogger.error('Error getting setting: $key', e, stack);
      return defaultValue;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await Hive.deleteFromDisk();
      _initialized = false;
      await initialize();
      AppLogger.info('Cache cleared');
    } catch (e, stack) {
      AppLogger.error('Error clearing cache', e, stack);
    }
  }

  Future<void> clearBox(String boxName) async {
    try {
      final box = Hive.box<dynamic>(boxName);
      await box.clear();
      AppLogger.info('Box cleared: $boxName');
    } catch (e, stack) {
      AppLogger.error('Error clearing box: $boxName', e, stack);
    }
  }

  Future<void> delete(String boxName, String key) async {
    try {
      final box = Hive.box<dynamic>(boxName);
      await box.delete(key);
      AppLogger.info('Deleted: $boxName/$key');
    } catch (e, stack) {
      AppLogger.error('Error deleting: $boxName/$key', e, stack);
    }
  }

  // Cache statistics
  Map<String, int> getCacheStats() {
    final stats = <String, int>{};
    try {
      stats['users'] = Hive.box<dynamic>(_usersBox).length;
      stats['wallet'] = Hive.box<dynamic>(_walletBox).length;
      stats['ads'] = Hive.box<dynamic>(_adsBox).length;
      stats['settings'] = Hive.box<dynamic>(_settingsBox).length;
      stats['analytics'] = Hive.box<dynamic>(_analyticsBox).length;
    } catch (e) {
      AppLogger.error('Error getting cache stats', e);
    }
    return stats;
  }

  void dispose() {
    Hive.close();
    _initialized = false;
  }
}
