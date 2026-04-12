import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _linkController = StreamController<Uri>.broadcast();
  Stream<Uri> get linkStream => _linkController.stream;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Handle app link when app is launched from terminated state
      // Platform channel to get initial link
      const platform = MethodChannel('app.channel.deeplink');
      final String? initialLink = await platform.invokeMethod('getInitialLink');
      
      if (initialLink != null) {
        _handleLink(initialLink);
      }

      // Listen for links when app is in background
      platform.setMethodCallHandler((call) async {
        if (call.method == 'handleLink') {
          final String link = call.arguments as String;
          _handleLink(link);
        }
        return null;
      });

      _initialized = true;
      AppLogger.info('DeepLinkService initialized');
    } catch (e, stack) {
      AppLogger.error('DeepLinkService initialization failed', e, stack);
    }
  }

  void _handleLink(String link) {
    try {
      final uri = Uri.parse(link);
      _linkController.add(uri);
      AppLogger.info('Deep link received: $uri');
    } catch (e) {
      AppLogger.error('Invalid deep link: $link', e);
    }
  }

  // Parse referral code from deep link
  String? extractReferralCode(Uri uri) {
    if (uri.pathSegments.isEmpty) return null;
    
    // Format: https://tirikchilik.uz/ref/CODE123
    if (uri.pathSegments.first == 'ref' && uri.pathSegments.length > 1) {
      return uri.pathSegments[1];
    }
    
    // Format: https://tirikchilik.uz/?ref=CODE123
    return uri.queryParameters['ref'];
  }

  // Generate referral deep link
  String generateReferralLink(String referralCode) {
    return 'https://tirikchilik.uz/ref/$referralCode';
  }

  void dispose() {
    _linkController.close();
    _initialized = false;
  }
}

// Referral tracking model
class ReferralTracking {
  final String referralCode;
  final String referrerUserId;
  final DateTime createdAt;
  int clicks;
  int signups;
  double totalEarned;

  ReferralTracking({
    required this.referralCode,
    required this.referrerUserId,
    required this.createdAt,
    this.clicks = 0,
    this.signups = 0,
    this.totalEarned = 0.0,
  });

  factory ReferralTracking.fromJson(Map<String, dynamic> json) {
    return ReferralTracking(
      referralCode: json['referralCode'] ?? '',
      referrerUserId: json['referrerUserId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      clicks: json['clicks'] ?? 0,
      signups: json['signups'] ?? 0,
      totalEarned: (json['totalEarned'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'referrerUserId': referrerUserId,
      'createdAt': createdAt.toIso8601String(),
      'clicks': clicks,
      'signups': signups,
      'totalEarned': totalEarned,
    };
  }
}
