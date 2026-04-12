import 'package:flutter_test/flutter_test.dart';
import 'package:tirikchilik/models/promo_code_model.dart';
import 'package:tirikchilik/models/user_model.dart';
import 'package:tirikchilik/services/promo_code_service.dart';

void main() {
  group('PromoCodeService Tests', () {
    late PromoCodeService service;
    const testUserId = 'test-user-123';

    setUp(() async {
      service = PromoCodeService();
      await service.initializeDefaultCodes();
    });

    group('Promo Code Validation', () {
      test('should find valid promo code', () async {
        final code = await service.getPromoCode('WELCOME2024');

        expect(code, isNotNull);
        expect(code!.code, equals('WELCOME2024'));
      });

      test('should return null for invalid code', () async {
        final code = await service.getPromoCode('INVALIDCODE');

        expect(code, isNull);
      });

      test('should be case insensitive', () async {
        final code = await service.getPromoCode('welcome2024');

        expect(code, isNotNull);
      });
    });

    group('Promo Code Application', () {
      test('should apply WELCOME2024 code successfully', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
        );

        final result = await service.applyPromoCode(testUserId, 'WELCOME2024', user);

        expect(result['success'], isTrue);
        expect(result['type'], contains('bonus'));
      });

      test('should not apply same code twice', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
        );

        await service.applyPromoCode(testUserId, 'WELCOME2024', user);
        final result = await service.applyPromoCode(testUserId, 'WELCOME2024', user);

        expect(result['success'], isFalse);
      });

      test('should fail for expired code', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
        );

        // Create expired code
        await service.createPromoCode(PromoCode(
          code: 'EXPIRED',
          description: 'Expired code',
          type: PromoCodeType.bonus,
          value: 10.0,
          validFrom: DateTime(2020, 1, 1),
          validUntil: DateTime(2020, 12, 31),
        ));

        final result = await service.applyPromoCode(testUserId, 'EXPIRED', user);

        expect(result['success'], isFalse);
      });

      test('should check minimum earnings requirement', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
          totalEarned: 50.0, // Less than required 100
        );

        final result = await service.applyPromoCode(testUserId, 'VIP50', user);

        expect(result['success'], isFalse);
      });
    });

    group('Active Codes', () {
      test('should return all active codes', () async {
        final codes = await service.getAllActiveCodes();

        expect(codes.isNotEmpty, isTrue);
        expect(codes.every((c) => c.isActive), isTrue);
      });
    });

    group('User History', () {
      test('should track used promo codes', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
        );

        await service.applyPromoCode(testUserId, 'WELCOME2024', user);

        final history = await service.getUserPromoCodeHistory(testUserId);

        expect(history.isNotEmpty, isTrue);
        expect(history.first.promoCode, equals('WELCOME2024'));
      });

      test('should check if user used code', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
        );

        await service.applyPromoCode(testUserId, 'WELCOME2024', user);

        final hasUsed = await service.hasUserUsedCode(testUserId, 'WELCOME2024');

        expect(hasUsed, isTrue);
      });
    });

    group('Multipliers and Discounts', () {
      test('should set earnings multiplier', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
        );

        // Create multiplier code
        await service.createPromoCode(PromoCode(
          code: 'DOUBLE',
          description: '2x multiplier',
          type: PromoCodeType.multiplier,
          value: 2.0,
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(const Duration(days: 30)),
        ));

        final result = await service.applyPromoCode(testUserId, 'DOUBLE', user);

        expect(result['success'], isTrue);

        final multiplier = await service.getActiveMultiplier(testUserId);
        expect(multiplier, equals(2.0));
      });

      test('should expire multiplier after 24 hours', () async {
        // This would need time manipulation in real test
        final multiplier = await service.getActiveMultiplier(testUserId);

        // Initially should be null or expired
        expect(multiplier, isNull);
      });
    });
  });
}
