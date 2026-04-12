import 'package:flutter_test/flutter_test.dart';
import 'package:tirikchilik/models/user_model.dart';
import 'package:tirikchilik/services/achievement_service.dart';

void main() {
  group('AchievementService Tests', () {
    late AchievementService service;
    const testUserId = 'test-user-123';

    setUp(() {
      service = AchievementService();
    });

    group('Achievement Checking', () {
      test('should unlock ads watched achievement', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
          totalAdsWatched: 10,
        );

        final unlocked = await service.checkAndUnlockAchievements(user);

        expect(unlocked.any((a) => a.id == 'ads_10'), isTrue);
      });

      test('should unlock streak achievement', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
          currentStreak: 7,
        );

        final unlocked = await service.checkAndUnlockAchievements(user);

        expect(unlocked.any((a) => a.id == 'streak_7'), isTrue);
      });

      test('should unlock referral achievement', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
          totalReferrals: 10,
        );

        final unlocked = await service.checkAndUnlockAchievements(user);

        expect(unlocked.any((a) => a.id == 'ref_10'), isTrue);
      });

      test('should unlock earnings achievement', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
          totalEarned: 1000.0,
        );

        final unlocked = await service.checkAndUnlockAchievements(user);

        expect(unlocked.any((a) => a.id == 'earn_1000'), isTrue);
      });

      test('should not unlock already unlocked achievements', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
          totalAdsWatched: 100,
        );

        // First check
        await service.checkAndUnlockAchievements(user);

        // Second check should not return already unlocked
        final unlocked = await service.checkAndUnlockAchievements(user);

        expect(unlocked.isEmpty, isTrue);
      });
    });

    group('Streak Management', () {
      test('should update streak on consecutive day login', () async {
        final updated = await service.updateLoginStreak(testUserId);

        expect(updated.currentStreak, greaterThanOrEqualTo(1));
      });

      test('should get streak info', () async {
        final streak = await service.getStreakInfo(testUserId);

        expect(streak, isNotNull);
        expect(streak.currentStreak, greaterThanOrEqualTo(0));
      });
    });

    group('Reward Claiming', () {
      test('should claim achievement reward', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
          totalAdsWatched: 10,
        );

        // Unlock first
        await service.checkAndUnlockAchievements(user);

        // Claim reward
        final claimed = await service.claimAchievementReward(
          testUserId,
          'ads_10',
        );

        expect(claimed, isTrue);
      });

      test('should not claim same reward twice', () async {
        final user = UserModel(
          id: testUserId,
          name: 'Test User',
          email: 'test@test.com',
          phone: '+998901234567',
          createdAt: DateTime.now(),
          totalAdsWatched: 10,
        );

        await service.checkAndUnlockAchievements(user);
        await service.claimAchievementReward(testUserId, 'ads_10');

        // Second claim should fail
        final claimed = await service.claimAchievementReward(
          testUserId,
          'ads_10',
        );

        expect(claimed, isFalse);
      });
    });

    group('Leaderboard', () {
      test('should return mock leaderboard', () {
        final leaderboard = service.getMockLeaderboard();

        expect(leaderboard.isNotEmpty, isTrue);
        expect(leaderboard.first.rank, equals(1));
      });
    });
  });
}
