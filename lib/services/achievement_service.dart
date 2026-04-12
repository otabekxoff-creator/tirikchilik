import 'dart:convert';
import '../models/achievement_model.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';
import 'shared_preferences_service.dart';
import 'wallet_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final _walletService = WalletService();

  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'achievements_$userId';
    final json = prefs.getString(key);

    if (json == null) return [];

    try {
      final List<dynamic> list = jsonDecode(json);
      return list.map((e) => UserAchievement.fromJson(e)).toList();
    } catch (e) {
      AppLogger.error('Error loading achievements', e);
      return [];
    }
  }

  Future<void> _saveUserAchievements(
    String userId,
    List<UserAchievement> achievements,
  ) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'achievements_$userId';
    final json = jsonEncode(achievements.map((e) => e.toJson()).toList());
    await prefs.setString(key, json);
  }

  Future<List<Achievement>> checkAndUnlockAchievements(UserModel user) async {
    final unlocked = await getUserAchievements(user.id);
    final unlockedIds = unlocked.map((e) => e.achievementId).toSet();
    final newlyUnlocked = <Achievement>[];

    for (final achievement in Achievement.allAchievements) {
      if (unlockedIds.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.adsWatched:
          shouldUnlock = user.totalAdsWatched >= achievement.requirement;
          break;
        case AchievementType.streak:
          shouldUnlock = user.currentStreak >= achievement.requirement;
          break;
        case AchievementType.referrals:
          shouldUnlock = user.totalReferrals >= achievement.requirement;
          break;
        case AchievementType.earnings:
          shouldUnlock = user.totalEarned >= achievement.requirement;
          break;
        case AchievementType.special:
          // Special achievements checked separately
          break;
      }

      if (shouldUnlock) {
        final userAchievement = UserAchievement(
          achievementId: achievement.id,
          unlockedAt: DateTime.now(),
        );
        unlocked.add(userAchievement);
        newlyUnlocked.add(achievement);

        AppLogger.info(
          'Achievement unlocked: ${achievement.title} for user ${user.id}',
        );
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _saveUserAchievements(user.id, unlocked);
    }

    return newlyUnlocked;
  }

  Future<bool> claimAchievementReward(
    String userId,
    String achievementId,
  ) async {
    final achievements = await getUserAchievements(userId);
    final index = achievements.indexWhere(
      (a) => a.achievementId == achievementId,
    );

    if (index == -1) return false;
    if (achievements[index].rewardClaimed) return false;

    final achievement = Achievement.allAchievements.firstWhere(
      (a) => a.id == achievementId,
    );

    if (achievement.reward > 0) {
      await _walletService.addBonus(
        userId,
        achievement.reward,
        'Achievement: ${achievement.title}',
      );
    }

    achievements[index] = UserAchievement(
      achievementId: achievementId,
      unlockedAt: achievements[index].unlockedAt,
      rewardClaimed: true,
    );

    await _saveUserAchievements(userId, achievements);
    return true;
  }

  Future<StreakInfo> getStreakInfo(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'streak_$userId';
    final json = prefs.getString(key);

    if (json == null) {
      return StreakInfo(
        lastLoginDate: DateTime.now().subtract(const Duration(days: 2)),
      );
    }

    try {
      return StreakInfo.fromJson(jsonDecode(json));
    } catch (e) {
      AppLogger.error('Error loading streak info', e);
      return StreakInfo(
        lastLoginDate: DateTime.now().subtract(const Duration(days: 2)),
      );
    }
  }

  Future<StreakInfo> updateLoginStreak(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'streak_$userId';

    var streakInfo = await getStreakInfo(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
      streakInfo.lastLoginDate.year,
      streakInfo.lastLoginDate.month,
      streakInfo.lastLoginDate.day,
    );

    if (lastLogin.isAtSameMomentAs(today)) {
      // Already logged in today
      return streakInfo;
    }

    final yesterday = today.subtract(const Duration(days: 1));

    if (lastLogin.isAtSameMomentAs(yesterday)) {
      // Continue streak
      streakInfo = StreakInfo(
        currentStreak: streakInfo.currentStreak + 1,
        longestStreak: streakInfo.longestStreak < streakInfo.currentStreak + 1
            ? streakInfo.currentStreak + 1
            : streakInfo.longestStreak,
        lastLoginDate: now,
        loginDates: [...streakInfo.loginDates, today],
      );
    } else {
      // Streak broken
      streakInfo = StreakInfo(
        currentStreak: 1,
        longestStreak: streakInfo.longestStreak,
        lastLoginDate: now,
        loginDates: [...streakInfo.loginDates, today],
      );
    }

    await prefs.setString(key, jsonEncode(streakInfo.toJson()));
    AppLogger.info(
      'Streak updated for user $userId: ${streakInfo.currentStreak} days',
    );

    return streakInfo;
  }

  Future<void> unlockSpecialAchievement(
    String userId,
    String achievementId,
  ) async {
    final achievements = await getUserAchievements(userId);

    if (achievements.any((a) => a.achievementId == achievementId)) return;

    final newAchievement = UserAchievement(
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
    );

    achievements.add(newAchievement);
    await _saveUserAchievements(userId, achievements);

    AppLogger.info(
      'Special achievement unlocked: $achievementId for user $userId',
    );
  }

  List<LeaderboardEntry> getMockLeaderboard() {
    return [
      LeaderboardEntry(
        userId: '1',
        userName: 'Azizbek',
        totalAdsWatched: 5432,
        totalEarnings: 1250.0,
        rank: 1,
      ),
      LeaderboardEntry(
        userId: '2',
        userName: 'Dilshod',
        totalAdsWatched: 4891,
        totalEarnings: 1080.0,
        rank: 2,
      ),
      LeaderboardEntry(
        userId: '3',
        userName: 'Malika',
        totalAdsWatched: 4234,
        totalEarnings: 950.0,
        rank: 3,
      ),
      LeaderboardEntry(
        userId: '4',
        userName: 'Jasur',
        totalAdsWatched: 3891,
        totalEarnings: 820.0,
        rank: 4,
      ),
      LeaderboardEntry(
        userId: '5',
        userName: 'Nodira',
        totalAdsWatched: 3456,
        totalEarnings: 750.0,
        rank: 5,
      ),
    ];
  }
}
