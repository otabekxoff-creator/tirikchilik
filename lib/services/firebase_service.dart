import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      // Configure Firestore settings
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Configure Crashlytics
      if (!kDebugMode) {
        FlutterError.onError = crashlytics.recordFlutterFatalError;
      }

      // Configure Analytics
      await analytics.setAnalyticsCollectionEnabled(true);

      // Configure Messaging
      await _configureMessaging();

      _initialized = true;
      AppLogger.info('Firebase initialized successfully');
    } catch (e, stack) {
      AppLogger.error('Firebase initialization failed', e, stack);
      rethrow;
    }
  }

  Future<void> _configureMessaging() async {
    // Request permission for notifications
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Get FCM token
    final token = await messaging.getToken();
    AppLogger.info('FCM Token: $token');

    // Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('FCM Token refreshed: $newToken');
    });
  }

  // Analytics methods
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    // Convert Map<String, dynamic> to Map<String, Object>
    final Map<String, Object>? convertedParams = parameters?.map(
      (key, value) => MapEntry(key, value as Object),
    );

    analytics.logEvent(name: name, parameters: convertedParams);
  }

  void logLogin(String method) {
    analytics.logLogin(loginMethod: method);
  }

  void logScreenView(String screenName) {
    analytics.logScreenView(screenName: screenName);
  }

  void logPurchase(double value, String currency) {
    analytics.logPurchase(value: value, currency: currency);
  }

  // Crashlytics methods
  void recordError(dynamic exception, StackTrace? stack, {String? reason}) {
    crashlytics.recordError(exception, stack, reason: reason);
  }

  void setUserIdentifier(String userId) {
    crashlytics.setUserIdentifier(userId);
    analytics.setUserId(id: userId);
  }
}
