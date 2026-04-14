import '../utils/app_logger.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      AppLogger.info('Firebase initialized (stub)');
      _initialized = true;
    } catch (e, st) {
      AppLogger.error('Firebase init error', e, st);
    }
  }

  bool get isInitialized => _initialized;

  void recordError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    AppLogger.error('Firebase recorded error: $reason', error, stackTrace);
  }

  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    AppLogger.info('Firebase event: $name, params: $parameters');
  }
}
