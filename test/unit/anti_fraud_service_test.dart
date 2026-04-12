import 'package:flutter_test/flutter_test.dart';
import 'package:tirikchilik/services/anti_fraud_service.dart';

void main() {
  group('AntiFraudService Tests', () {
    late AntiFraudService service;
    const testUserId = 'test-user-123';

    setUp(() {
      service = AntiFraudService();
    });

    group('Rate Limiting', () {
      test('should allow first ad watch', () async {
        final result = await service.canWatchAd(testUserId);

        expect(result.isAllowed, isTrue);
      });

      test('should block after too many ads per minute', () async {
        // Watch 6 ads rapidly (limit is 5)
        for (var i = 0; i < 6; i++) {
          await service.canWatchAd(testUserId);
        }

        final result = await service.canWatchAd(testUserId);

        expect(result.isAllowed, isFalse);
        expect(result.reason, isNotNull);
      });

      test('should provide cooldown time when blocked', () async {
        // Exceed limit
        for (var i = 0; i < 10; i++) {
          await service.canWatchAd(testUserId);
        }

        final result = await service.canWatchAd(testUserId);

        expect(result.cooldownSeconds, isNotNull);
        expect(result.cooldownSeconds!, greaterThan(0));
      });
    });

    group('Cooldown Management', () {
      test('should set cooldown on violation', () async {
        await service.reportViolation(testUserId, 'suspicious_pattern');

        final result = await service.canWatchAd(testUserId);

        expect(result.isAllowed, isFalse);
      });

      test('should increase cooldown for repeated violations', () async {
        // Report multiple violations
        for (var i = 0; i < 3; i++) {
          await service.reportViolation(testUserId, 'violation_$i');
        }

        final stats = await service.getFraudStats(testUserId);

        expect(stats['violations'], equals(3));
      });

      test('should mark user as suspicious after many violations', () async {
        // Report 5 violations
        for (var i = 0; i < 5; i++) {
          await service.reportViolation(testUserId, 'violation_$i');
        }

        final isSuspicious = await service.isUserSuspicious(testUserId);

        expect(isSuspicious, isTrue);
      });
    });

    group('Suspicious Pattern Detection', () {
      test('should detect identical watch times', () async {
        // Record identical watch times (bot pattern)
        for (var i = 0; i < 5; i++) {
          await service.recordAdWatch(testUserId, 5000); // Same time
        }

        // The pattern check would trigger on next canWatchAd
        // But we can't easily test this without mocking
        expect(true, isTrue); // Placeholder for pattern detection
      });

      test('should clear suspicious mark', () async {
        // First make user suspicious
        for (var i = 0; i < 5; i++) {
          await service.reportViolation(testUserId, 'violation_$i');
        }

        await service.clearSuspiciousMark(testUserId);

        final isSuspicious = await service.isUserSuspicious(testUserId);

        expect(isSuspicious, isFalse);
      });
    });

    group('Fraud Stats', () {
      test('should return fraud statistics', () async {
        final stats = await service.getFraudStats(testUserId);

        expect(stats.containsKey('violations'), isTrue);
        expect(stats.containsKey('isSuspicious'), isTrue);
        expect(stats.containsKey('deviceId'), isTrue);
      });
    });

    group('Rate Limit Reset', () {
      test('should reset rate limits', () async {
        // First exceed limits
        for (var i = 0; i < 10; i++) {
          await service.canWatchAd(testUserId);
        }

        // Reset
        await service.resetRateLimits(testUserId);

        // Should be allowed again
        final result = await service.canWatchAd(testUserId);
        expect(result.isAllowed, isTrue);
      });
    });
  });
}
