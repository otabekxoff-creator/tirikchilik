import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/app_logger.dart';
import 'shared_preferences_service.dart';

class FraudCheckResult {
  final bool isAllowed;
  final String? reason;
  final int? cooldownSeconds;

  FraudCheckResult({
    required this.isAllowed,
    this.reason,
    this.cooldownSeconds,
  });

  factory FraudCheckResult.allowed() {
    return FraudCheckResult(isAllowed: true);
  }

  factory FraudCheckResult.blocked(String reason, {int? cooldownSeconds}) {
    return FraudCheckResult(
      isAllowed: false,
      reason: reason,
      cooldownSeconds: cooldownSeconds,
    );
  }
}

class AntiFraudService {
  static final AntiFraudService _instance = AntiFraudService._internal();
  factory AntiFraudService() => _instance;
  AntiFraudService._internal();

  static const int _maxAdsPerMinute = 5;
  static const int _maxAdsPerHour = 30;
  static const int _maxAdsPerDay = 100;
  static const int _minWatchTimeSeconds = 5;
  static const int _cooldownAfterViolation = 300; // 5 minutes

  final _deviceInfo = DeviceInfoPlugin();

  Future<String> _getDeviceIdentifier() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.model}_${info.id}';
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return '${info.model}_${info.identifierForVendor ?? 'unknown'}';
      }
    } catch (e) {
      AppLogger.error('Error getting device identifier', e);
    }
    return 'unknown_device';
  }

  Future<FraudCheckResult> canWatchAd(String userId) async {
    // Check rate limits
    final minuteCheck = await _checkRateLimit(
      userId,
      'minute',
      _maxAdsPerMinute,
      const Duration(minutes: 1),
    );
    if (!minuteCheck.isAllowed) return minuteCheck;

    final hourCheck = await _checkRateLimit(
      userId,
      'hour',
      _maxAdsPerHour,
      const Duration(hours: 1),
    );
    if (!hourCheck.isAllowed) return hourCheck;

    final dayCheck = await _checkRateLimit(
      userId,
      'day',
      _maxAdsPerDay,
      const Duration(days: 1),
    );
    if (!dayCheck.isAllowed) return dayCheck;

    // Check for active cooldown
    final cooldownCheck = await _checkCooldown(userId);
    if (!cooldownCheck.isAllowed) return cooldownCheck;

    // Check device restrictions
    final deviceCheck = await _checkDeviceRestrictions(userId);
    if (!deviceCheck.isAllowed) return deviceCheck;

    // Check for suspicious patterns
    final patternCheck = await _checkSuspiciousPatterns(userId);
    if (!patternCheck.isAllowed) return patternCheck;

    return FraudCheckResult.allowed();
  }

  Future<FraudCheckResult> _checkRateLimit(
    String userId,
    String period,
    int maxCount,
    Duration window,
  ) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'ad_count_${period}_$userId';
    final now = DateTime.now();

    final count = prefs.getInt(key) ?? 0;
    final lastReset = prefs.getString('${key}_reset');

    if (lastReset != null) {
      final resetTime = DateTime.parse(lastReset);
      if (now.isAfter(resetTime.add(window))) {
        // Reset the counter
        await prefs.setInt(key, 1);
        await prefs.setString('${key}_reset', now.toIso8601String());
        return FraudCheckResult.allowed();
      }
    } else {
      await prefs.setString('${key}_reset', now.toIso8601String());
    }

    if (count >= maxCount) {
      final resetTime = DateTime.parse(prefs.getString('${key}_reset')!);
      final remaining = resetTime.add(window).difference(now);

      return FraudCheckResult.blocked(
        '${period == 'minute'
            ? 'Daqiqa'
            : period == 'hour'
            ? 'Soat'
            : 'Kun'} limiti tugadi. Iltimos kuting.',
        cooldownSeconds: remaining.inSeconds,
      );
    }

    await prefs.setInt(key, count + 1);
    return FraudCheckResult.allowed();
  }

  Future<FraudCheckResult> _checkCooldown(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'fraud_cooldown_$userId';
    final cooldownEnd = prefs.getString(key);

    if (cooldownEnd == null) return FraudCheckResult.allowed();

    final endTime = DateTime.parse(cooldownEnd);
    final now = DateTime.now();

    if (now.isBefore(endTime)) {
      final remaining = endTime.difference(now);
      return FraudCheckResult.blocked(
        'Faqat biroz kuting',
        cooldownSeconds: remaining.inSeconds,
      );
    }

    // Clear expired cooldown
    await prefs.remove(key);
    return FraudCheckResult.allowed();
  }

  Future<void> _setCooldown(
    String userId, {
    int seconds = _cooldownAfterViolation,
  }) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'fraud_cooldown_$userId';
    final endTime = DateTime.now().add(Duration(seconds: seconds));
    await prefs.setString(key, endTime.toIso8601String());

    AppLogger.warning('Cooldown set for user $userId: $seconds seconds');
  }

  Future<FraudCheckResult> _checkDeviceRestrictions(String userId) async {
    final deviceId = await _getDeviceIdentifier();
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'device_users_$deviceId';

    final usersJson = prefs.getString(key);
    Set<String> users;

    if (usersJson != null) {
      users = Set<String>.from(usersJson.split(','));
    } else {
      users = <String>{};
    }

    if (users.isNotEmpty && !users.contains(userId)) {
      // Device already has another user
      if (users.length >= 2) {
        return FraudCheckResult.blocked(
          'Bu qurilma boshqa foydalanuvchilar bilan bog\'langan',
        );
      }
    }

    users.add(userId);
    await prefs.setString(key, users.join(','));

    return FraudCheckResult.allowed();
  }

  Future<FraudCheckResult> _checkSuspiciousPatterns(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'watch_times_$userId';

    final timesJson = prefs.getString(key);
    if (timesJson == null) return FraudCheckResult.allowed();

    final List<int> times = timesJson.split(',').map(int.parse).toList();
    if (times.length < 5) return FraudCheckResult.allowed();

    // Check for identical watch times (bot pattern)
    final uniqueTimes = times.toSet();
    if (uniqueTimes.length == 1) {
      // All watch times are identical - likely bot
      await _setCooldown(userId, seconds: 600); // 10 minutes
      return FraudCheckResult.blocked('Shubhali faoliyat aniqlandi');
    }

    // Check for too fast watching
    final recentTimes = times.take(10).toList();
    final avgTime = recentTimes.reduce((a, b) => a + b) / recentTimes.length;

    if (avgTime < _minWatchTimeSeconds * 1000) {
      // in milliseconds
      return FraudCheckResult.blocked(
        'Reklama juda tez ko\'rilmoqda',
        cooldownSeconds: 60,
      );
    }

    return FraudCheckResult.allowed();
  }

  Future<void> recordAdWatch(String userId, int watchTimeMs) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'watch_times_$userId';

    final timesJson = prefs.getString(key);
    List<int> times;

    if (timesJson != null) {
      times = timesJson.split(',').map(int.parse).toList();
    } else {
      times = [];
    }

    times.insert(0, watchTimeMs);
    if (times.length > 50) times = times.take(50).toList();

    await prefs.setString(key, times.join(','));
  }

  Future<void> reportViolation(String userId, String violationType) async {
    AppLogger.warning(
      'Fraud violation reported: $violationType for user $userId',
    );

    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'violations_$userId';

    final violations = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, violations + 1);

    // Set cooldown based on violation count
    final cooldownSeconds = violations >= 3
        ? 1800
        : violations >= 2
        ? 600
        : 300;
    await _setCooldown(userId, seconds: cooldownSeconds);

    // Mark user as suspicious if too many violations
    if (violations >= 5) {
      await prefs.setBool('suspicious_$userId', true);
    }
  }

  Future<bool> isUserSuspicious(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    return prefs.getBool('suspicious_$userId') ?? false;
  }

  Future<void> clearSuspiciousMark(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    await prefs.remove('suspicious_$userId');
    await prefs.remove('violations_$userId');
    AppLogger.info('Suspicious mark cleared for user $userId');
  }

  Future<Map<String, dynamic>> getFraudStats(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;

    return {
      'violations': prefs.getInt('violations_$userId') ?? 0,
      'isSuspicious': prefs.getBool('suspicious_$userId') ?? false,
      'deviceId': await _getDeviceIdentifier(),
    };
  }

  // Admin functions
  Future<List<String>> getUsersOnDevice(String deviceId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'device_users_$deviceId';

    final usersJson = prefs.getString(key);
    if (usersJson == null) return [];

    return usersJson.split(',');
  }

  Future<void> resetRateLimits(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;

    await prefs.remove('ad_count_minute_$userId');
    await prefs.remove('ad_count_hour_$userId');
    await prefs.remove('ad_count_day_$userId');
    await prefs.remove('fraud_cooldown_$userId');

    AppLogger.info('Rate limits reset for user $userId');
  }
}
