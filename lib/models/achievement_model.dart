import 'package:flutter/material.dart';

enum AchievementType { adsWatched, streak, referrals, earnings, special }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int requirement;
  final double reward;
  final Color color;
  final bool isSecret;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requirement,
    this.reward = 0.0,
    required this.color,
    this.isSecret = false,
  });

  static const List<Achievement> allAchievements = [
    // Ads watched achievements
    Achievement(
      id: 'ads_10',
      title: 'Yangi boshlovchi',
      description: '10 ta reklama ko\'ring',
      icon: '🎯',
      type: AchievementType.adsWatched,
      requirement: 10,
      reward: 1.0,
      color: Colors.blue,
    ),
    Achievement(
      id: 'ads_100',
      title: 'Tajribali ko\'ruvchi',
      description: '100 ta reklama ko\'ring',
      icon: '👁️',
      type: AchievementType.adsWatched,
      requirement: 100,
      reward: 5.0,
      color: Colors.green,
    ),
    Achievement(
      id: 'ads_1000',
      title: 'Reklama master',
      description: '1000 ta reklama ko\'ring',
      icon: '🏆',
      type: AchievementType.adsWatched,
      requirement: 1000,
      reward: 50.0,
      color: Colors.orange,
    ),
    Achievement(
      id: 'ads_10000',
      title: 'Legendarni ko\'ruvchi',
      description: '10000 ta reklama ko\'ring',
      icon: '👑',
      type: AchievementType.adsWatched,
      requirement: 10000,
      reward: 500.0,
      color: Colors.purple,
      isSecret: true,
    ),

    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: 'Muntazam foydalanuvchi',
      description: '3 kun ketma-ket kirish',
      icon: '🔥',
      type: AchievementType.streak,
      requirement: 3,
      reward: 2.0,
      color: Colors.red,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Haftalik champion',
      description: '7 kun ketma-ket kirish',
      icon: '📅',
      type: AchievementType.streak,
      requirement: 7,
      reward: 10.0,
      color: Colors.amber,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Oylik marafon',
      description: '30 kun ketma-ket kirish',
      icon: '🗓️',
      type: AchievementType.streak,
      requirement: 30,
      reward: 100.0,
      color: Colors.deepOrange,
      isSecret: true,
    ),

    // Referral achievements
    Achievement(
      id: 'ref_1',
      title: 'Do\'stlar chempioni',
      description: '1 ta do\'st taklif qiling',
      icon: '🤝',
      type: AchievementType.referrals,
      requirement: 1,
      reward: 5.0,
      color: Colors.teal,
    ),
    Achievement(
      id: 'ref_10',
      title: 'Jamoa lideri',
      description: '10 ta do\'st taklif qiling',
      icon: '👥',
      type: AchievementType.referrals,
      requirement: 10,
      reward: 50.0,
      color: Colors.indigo,
    ),
    Achievement(
      id: 'ref_100',
      title: 'Influencer',
      description: '100 ta do\'st taklif qiling',
      icon: '🌟',
      type: AchievementType.referrals,
      requirement: 100,
      reward: 500.0,
      color: Colors.pink,
      isSecret: true,
    ),

    // Earnings achievements
    Achievement(
      id: 'earn_100',
      title: 'Birinchi so\'m',
      description: '100 so\'m ishlang',
      icon: '💰',
      type: AchievementType.earnings,
      requirement: 100,
      reward: 5.0,
      color: Colors.lightGreen,
    ),
    Achievement(
      id: 'earn_1000',
      title: 'Tiyinchi tengi',
      description: '1000 so\'m ishlang',
      icon: '💵',
      type: AchievementType.earnings,
      requirement: 1000,
      reward: 20.0,
      color: Colors.green,
    ),
    Achievement(
      id: 'earn_10000',
      title: 'Tashabbuskor',
      description: '10000 so\'m ishlang',
      icon: '💎',
      type: AchievementType.earnings,
      requirement: 10000,
      reward: 100.0,
      color: Colors.cyan,
    ),

    // Special achievements
    Achievement(
      id: 'premium',
      title: 'Premium foydalanuvchi',
      description: 'Premium obuna sotib oling',
      icon: '⭐',
      type: AchievementType.special,
      requirement: 1,
      reward: 0.0,
      color: Colors.amber,
    ),
    Achievement(
      id: 'first_withdraw',
      title: 'Birinchi yechim',
      description: 'Birinchi marta pul yeching',
      icon: '🏧',
      type: AchievementType.special,
      requirement: 1,
      reward: 10.0,
      color: Colors.deepPurple,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Tunqi cho\'rtan',
      description: 'Tun 2-da reklama ko\'ring',
      icon: '🦉',
      type: AchievementType.special,
      requirement: 1,
      reward: 5.0,
      color: Colors.indigo,
      isSecret: true,
    ),
  ];
}

class UserAchievement {
  final String achievementId;
  final DateTime unlockedAt;
  final bool rewardClaimed;

  UserAchievement({
    required this.achievementId,
    required this.unlockedAt,
    this.rewardClaimed = false,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      achievementId: json['achievementId'] ?? '',
      unlockedAt: DateTime.parse(
        json['unlockedAt'] ?? DateTime.now().toIso8601String(),
      ),
      rewardClaimed: json['rewardClaimed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'rewardClaimed': rewardClaimed,
    };
  }
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastLoginDate;
  final List<DateTime> loginDates;

  StreakInfo({
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastLoginDate,
    this.loginDates = const [],
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastLoginDate: DateTime.parse(
        json['lastLoginDate'] ?? DateTime.now().toIso8601String(),
      ),
      loginDates:
          (json['loginDates'] as List?)
              ?.map((e) => DateTime.parse(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'loginDates': loginDates.map((e) => e.toIso8601String()).toList(),
    };
  }

  bool get isStreakActive {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final lastLogin = DateTime(
      lastLoginDate.year,
      lastLoginDate.month,
      lastLoginDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    return lastLogin.isAtSameMomentAs(yesterday) ||
        lastLogin.isAtSameMomentAs(today);
  }
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final int totalAdsWatched;
  final double totalEarnings;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.totalAdsWatched,
    required this.totalEarnings,
    required this.rank,
  });
}
