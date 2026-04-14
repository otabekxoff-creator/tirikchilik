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
    try {
      // Initialize error handling first
      _setupErrorHandling();

      // Initialize App Logger first
      AppLogger.init(
        level: kDebugMode ? logging.Level.ALL : logging.Level.INFO,
      );
      AppLogger.info('AppInitializer starting...');

      // Load environment variables (with error handling)
      try {
        await dotenv.load(fileName: 'assets/.env');
        AppLogger.info('Environment variables loaded');
      } catch (e, stack) {
        AppLogger.warning('Failed to load .env file, using defaults');
        AppLogger.error('.env load error', e, stack);
        // Continue without .env
      }

      // Initialize SharedPreferences
      try {
        await SharedPreferencesService.instance.init();
        AppLogger.info('SharedPreferences initialized');
      } catch (e, stack) {
        AppLogger.error('SharedPreferences initialization failed', e, stack);
      }

      // Initialize Secure Storage
      try {
        await SecureStorageService().initialize();
        AppLogger.info('SecureStorage initialized');
      } catch (e, stack) {
        AppLogger.error('SecureStorage initialization failed', e, stack);
      }

      // Initialize Cache Service
      try {
        await CacheService().initialize();
        AppLogger.info('CacheService initialized');
      } catch (e, stack) {
        AppLogger.error('CacheService initialization failed', e, stack);
      }

      // Initialize Network Service
      try {
        await NetworkService().initialize();
        AppLogger.info('NetworkService initialized');
      } catch (e, stack) {
        AppLogger.error('NetworkService initialization failed', e, stack);
      }

      // Initialize Firebase (if enabled in .env)
      try {
        final firebaseEnabled = dotenv.env['FIREBASE_ENABLED'] == 'true';
        if (firebaseEnabled) {
          await FirebaseService().initialize();
          AppLogger.info('Firebase initialized');
        }
      } catch (e, stack) {
        AppLogger.error(
          'Firebase initialization failed, continuing without Firebase',
          e,
          stack,
        );
      }

      // Initialize AdMob (with error handling)
      try {
        final adMob = AdMobService();
        await adMob.initialize();
        if (adMob.isInitialized) {
          await adMob.loadInterstitialAd();
          await adMob.loadRewardedAd();
        }
        AppLogger.info('AdMob initialized');
      } catch (e, stack) {
        AppLogger.error(
          'AdMob initialization failed, continuing without AdMob',
          e,
          stack,
        );
      }

      // Set preferred orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Set system UI overlay style (iOS style)
      SystemChrome.setSystemUIOverlayStyle(IOSTheme.lightOverlay);

      AppLogger.info('AppInitializer completed successfully');
    } catch (e, stack) {
      AppLogger.error('AppInitializer failed', e, stack);
      // Don't rethrow - allow app to start even if initialization fails
    }
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
