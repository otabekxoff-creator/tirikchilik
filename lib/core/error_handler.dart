import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';
import '../services/firebase_service.dart';

class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;

  AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.severity = ErrorSeverity.error,
  });

  @override
  String toString() => 'AppError[$code]: $message';
}

enum ErrorSeverity { info, warning, error, critical }

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final _errorController = StreamController<AppError>.broadcast();
  Stream<AppError> get errorStream => _errorController.stream;

  void handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    bool showUser = true,
    BuildContext? ctx,
  }) {
    final appError = _convertToAppError(error, stackTrace);

    // Log error
    _logError(appError, context);

    // Report to Firebase Crashlytics
    _reportToCrashlytics(appError);

    // Notify listeners
    _errorController.add(appError);

    // Show user-friendly message if needed
    if (showUser && ctx != null && ctx.mounted) {
      _showUserMessage(ctx, appError);
    }
  }

  AppError _convertToAppError(dynamic error, StackTrace? stackTrace) {
    if (error is AppError) return error;

    if (error is Exception) {
      return AppError(
        message: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
        severity: ErrorSeverity.error,
      );
    }

    return AppError(
      message: 'Unknown error occurred',
      code: 'UNKNOWN',
      originalError: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.error,
    );
  }

  void _logError(AppError error, String? context) {
    final message = context != null
        ? '[$context] ${error.message}'
        : error.message;

    switch (error.severity) {
      case ErrorSeverity.info:
        AppLogger.info(message);
        break;
      case ErrorSeverity.warning:
        AppLogger.warning(message);
        break;
      case ErrorSeverity.error:
        AppLogger.error(message, error.originalError, error.stackTrace);
        break;
      case ErrorSeverity.critical:
        AppLogger.error(
          'CRITICAL: $message',
          error.originalError,
          error.stackTrace,
        );
        break;
    }
  }

  void _reportToCrashlytics(AppError error) {
    if (error.severity == ErrorSeverity.error ||
        error.severity == ErrorSeverity.critical) {
      FirebaseService().recordError(
        error.originalError ?? error,
        error.stackTrace,
        reason: error.message,
      );
    }
  }

  void _showUserMessage(BuildContext context, AppError error) {
    String userMessage = _getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage),
        backgroundColor: _getSeverityColor(error.severity),
        behavior: SnackBarBehavior.floating,
        action: error.severity == ErrorSeverity.critical
            ? SnackBarAction(
                label: 'Report',
                textColor: Colors.white,
                onPressed: () => _reportError(error),
              )
            : null,
      ),
    );
  }

  String _getUserFriendlyMessage(AppError error) {
    switch (error.code) {
      case 'NETWORK_ERROR':
        return 'Internet ulanishi yo\'q. Iltimos, ulanishni tekshiring.';
      case 'AUTH_ERROR':
        return 'Kirishda xatolik. Iltimos, qayta urining.';
      case 'SERVER_ERROR':
        return 'Serverda xatolik. Keyinroq qayta urining.';
      case 'TIMEOUT':
        return 'So\'rov vaqti tugadi. Qayta urining.';
      default:
        return 'Xatolik yuz berdi: ${error.message}';
    }
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.purple;
    }
  }

  void _reportError(AppError error) {
    // Send error report to server
    FirebaseService().logEvent(
      'error_reported',
      parameters: {
        'error_code': error.code ?? 'unknown',
        'error_message': error.message,
      },
    );
  }

  // Helper method for async operations
  Future<T> runAsync<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
    BuildContext? ctx,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      handleError(e, stack, context: context, ctx: ctx);
      if (defaultValue != null) return defaultValue;
      rethrow;
    }
  }

  // Safe widget builder
  Widget buildSafely(
    Widget Function() builder, {
    Widget? fallback,
    String? context,
  }) {
    try {
      return builder();
    } catch (e, stack) {
      handleError(e, stack, context: context, showUser: false);
      return fallback ?? const SizedBox.shrink();
    }
  }

  void dispose() {
    _errorController.close();
  }
}
