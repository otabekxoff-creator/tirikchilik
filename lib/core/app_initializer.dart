import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart' as logging;
import '../services/firebase_service.dart';
import '../services/admob_service.dart';
import '../services/shared_preferences_service.dart';
import '../services/secure_storage_service.dart';
import '../services/network_service.dart';
import '../services/cache_service.dart';
import '../utils/app_logger.dart';
import '../theme/ios_theme.dart';
import 'error_handler.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // Initialize error handling first
    _setupErrorHandling();

    // Load environment variables
    await dotenv.load(fileName: '.env');

    // Initialize App Logger
    AppLogger.init(level: kDebugMode ? logging.Level.ALL : logging.Level.INFO);
    AppLogger.info('AppInitializer starting...');

    // Initialize SharedPreferences
    await SharedPreferencesService.instance.init();

    // Initialize Secure Storage
    await SecureStorageService().initialize();

    // Initialize Cache Service
    await CacheService().initialize();

    // Initialize Network Service
    await NetworkService().initialize();

    // Initialize Firebase (if enabled in .env)
    final firebaseEnabled = dotenv.env['FIREBASE_ENABLED'] == 'true';
    if (firebaseEnabled) {
      try {
        await FirebaseService().initialize();
        AppLogger.info('Firebase initialized');
      } catch (e, stack) {
        AppLogger.error(
          'Firebase initialization failed, continuing without Firebase',
          e,
          stack,
        );
      }
    }

    // Initialize AdMob
    final adMob = AdMobService();
    await adMob.initialize();
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

    AppLogger.info('AppInitializer completed successfully');
  }

  static void _setupErrorHandling() {
    // Catch Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (!kDebugMode) {
        ErrorHandler().handleError(
          details.exception,
          details.stack,
          context: 'Flutter Framework',
        );
      }
    };

    // Catch async zone errors
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kDebugMode) {
        ErrorHandler().handleError(
          error,
          stack,
          context: 'Platform Dispatcher',
        );
      }
      return true;
    };
  }
}
