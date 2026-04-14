import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' as logging;
import '../utils/app_logger.dart';
import '../theme/ios_theme.dart';

class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Initialize App Logger first
      AppLogger.init(
        level: kDebugMode ? logging.Level.ALL : logging.Level.INFO,
      );
      AppLogger.info('AppInitializer starting...');

      // Set preferred orientations (minimal initialization)
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
}
