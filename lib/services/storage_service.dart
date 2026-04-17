import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('StorageService initialized');
    } catch (e) {
      AppLogger.error('StorageService init error', e);
    }
  }

  Future<String?> read(String key) async {
    try {
      await _ensureInitialized();
      return _prefs?.getString(key);
    } catch (e) {
      AppLogger.error('Storage read error', e);
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    try {
      await _ensureInitialized();
      await _prefs?.setString(key, value);
    } catch (e) {
      AppLogger.error('Storage write error', e);
    }
  }

  Future<void> delete(String key) async {
    try {
      await _ensureInitialized();
      await _prefs?.remove(key);
    } catch (e) {
      AppLogger.error('Storage delete error', e);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _ensureInitialized();
      await _prefs?.clear();
    } catch (e) {
      AppLogger.error('Storage deleteAll error', e);
    }
  }

  Future<Map<String, String>> readAll() async {
    try {
      await _ensureInitialized();
      final keys = _prefs?.getKeys() ?? {};
      final result = <String, String>{};
      for (final key in keys) {
        final value = _prefs?.getString(key);
        if (value != null) {
          result[key] = value;
        }
      }
      return result;
    } catch (e) {
      AppLogger.error('Storage readAll error', e);
      return {};
    }
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
}
