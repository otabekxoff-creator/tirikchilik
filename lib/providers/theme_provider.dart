import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/shared_preferences_service.dart';

class ThemeNotifier extends StateNotifier<bool> {
  static const String _darkModeKey = 'is_dark_mode';

  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    state = isDarkMode;
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = SharedPreferencesService.instance.prefs;
    await prefs.setBool(_darkModeKey, isDark);
    state = isDark;
  }

  Future<void> toggleTheme() async {
    await setDarkMode(!state);
  }

  bool get isDarkMode => state;
}

final themeProviderProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);
