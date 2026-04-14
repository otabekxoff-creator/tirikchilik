import 'dart:convert';

import '../utils/app_logger.dart';
import 'shared_preferences_service.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final SharedPreferencesService _prefs = SharedPreferencesService.instance;

  Future<void> initialize() async {
    await _prefs.initialize();
    AppLogger.info('CacheService initialized');
  }

  Future<void> set(String key, dynamic value, {Duration? expiry}) async {
    final data = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await _prefs.setString('cache_$key', jsonEncode(data));
  }

  Future<dynamic> get(String key) async {
    final data = _prefs.getString('cache_$key');
    if (data == null) return null;

    try {
      final decoded = jsonDecode(data);
      final expiry = decoded['expiry'] as int?;
      if (expiry != null) {
        final timestamp = decoded['timestamp'] as int;
        final expiryTime = timestamp + expiry;
        if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
          await delete(key);
          return null;
        }
      }
      return decoded['value'];
    } catch (e, st) {
      AppLogger.error('Cache get error', e, st);
      return null;
    }
  }

  Future<void> delete(String key) async {
    await _prefs.remove('cache_$key');
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
