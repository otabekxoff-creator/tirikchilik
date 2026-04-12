import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart' as logging;
import '../services/admob_service.dart';
import '../services/shared_preferences_service.dart';
import '../utils/app_logger.dart';
import '../theme/ios_theme.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');

    // Initialize SharedPreferences
    await SharedPreferencesService.instance.init();

    // Initialize App Logger
    AppLogger.init(level: logging.Level.INFO);

    // Initialize AdMob
    final adMob = AdMobService();
    await adMob.initialize();
    // Only load ads on mobile platforms
    if (adMob.isInitialized) {
      await adMob.loadInterstitialAd();
      await adMob.loadRewardedAd();
    }

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style (iOS style)
    SystemChrome.setSystemUIOverlayStyle(IOSTheme.lightOverlay);
  }
}
