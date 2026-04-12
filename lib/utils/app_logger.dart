import 'dart:developer' as developer;
import 'package:logging/logging.dart';

/// Logger class for professional logging in the application.
class AppLogger {
  static final Logger _logger = Logger('AppLogger');

  /// Initializes the logger with the specified log level.
  static void init({Level level = Level.INFO}) {
    Logger.root.level = level; // Set the default log level.
    Logger.root.onRecord.listen((LogRecord rec) {
      final timeStamp = DateTime.now().toUtc().toIso8601String();
      developer.log(
        rec.message,
        time: DateTime.parse(timeStamp),
        level: rec.level.value,
        name: rec.loggerName,
      );
    });
  }

  /// Logs a message at the INFO level.
  static void info(String message) {
    _logger.info(message);
  }

  /// Logs a message at the WARNING level.
  static void warning(String message) {
    _logger.warning(message);
  }

  /// Logs a message at the SEVERE level.
  static void severe(String message) {
    _logger.severe(message);
  }

  /// Logs an error with optional exception and stack trace.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  /// Logs a message at the FINE level.
  static void fine(String message) {
    _logger.fine(message);
  }

  /// Logs a message at the FINEST level (debug).
  static void debug(String message) {
    _logger.finest(message);
  }

  /// Logs a message at the ALL level.
  static void all(String message) {
    _logger.finest(message);
  }
}
