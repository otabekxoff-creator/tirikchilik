import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences singleton service
/// This ensures we only initialize SharedPreferences once
class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  static SharedPreferences? _preferences;

  SharedPreferencesService._();

  static SharedPreferencesService get instance {
    _instance ??= SharedPreferencesService._();
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  SharedPreferences get prefs {
    if (_preferences == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _preferences!;
  }

  /// Check if SharedPreferences is initialized
  bool get isInitialized => _preferences != null;
}
