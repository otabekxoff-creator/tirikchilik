import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/shared_preferences_service.dart';

// Language state
class LanguageState extends StateNotifier<Locale> {
  LanguageState() : super(const Locale('uz')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final languageCode = prefs.getString('language_code') ?? 'uz';
    state = Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    final prefs = SharedPreferencesService.instance.prefs;
    await prefs.setString('language_code', locale.languageCode);
  }

  String getLanguageName() {
    switch (state.languageCode) {
      case 'uz':
        return "O'zbekcha";
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return "O'zbekcha";
    }
  }
}

// Theme state
class ThemeState extends StateNotifier<ThemeStateData> {
  ThemeState() : super(ThemeStateData(false)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final isDarkMode = prefs.getBool('dark_mode') ?? false;
    state = ThemeStateData(isDarkMode);
  }

  Future<void> toggleTheme() async {
    final isDarkMode = !state.isDarkMode;
    state = ThemeStateData(isDarkMode);
    final prefs = SharedPreferencesService.instance.prefs;
    await prefs.setBool('dark_mode', isDarkMode);
  }
}

class ThemeStateData {
  final bool isDarkMode;
  const ThemeStateData(this.isDarkMode);
}

// Providers
final languageProviderProvider = StateNotifierProvider<LanguageState, Locale>((
  ref,
) {
  return LanguageState();
});

final themeProviderProvider = StateNotifierProvider<ThemeState, ThemeStateData>(
  (ref) {
    return ThemeState();
  },
);
