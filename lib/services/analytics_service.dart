import 'dart:convert';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../utils/app_logger.dart';
import 'shared_preferences_service.dart';

class AnalyticsData {
  final DateTime date;
  final int newUsers;
  final int activeUsers;
  final int totalAdsWatched;
  final double totalEarnings;
  final double totalWithdrawals;
  final int premiumUsers;
  final double revenue;
  final int totalUsers;

  AnalyticsData({
    required this.date,
    this.newUsers = 0,
    this.activeUsers = 0,
    this.totalUsers = 0,
    this.totalAdsWatched = 0,
    this.totalEarnings = 0.0,
    this.totalWithdrawals = 0.0,
    this.premiumUsers = 0,
    this.revenue = 0.0,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      newUsers: json['newUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalAdsWatched: json['totalAdsWatched'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      totalWithdrawals: (json['totalWithdrawals'] ?? 0.0).toDouble(),
      premiumUsers: json['premiumUsers'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      totalUsers: json['totalUsers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'newUsers': newUsers,
      'activeUsers': activeUsers,
      'totalAdsWatched': totalAdsWatched,
      'totalEarnings': totalEarnings,
      'totalWithdrawals': totalWithdrawals,
      'premiumUsers': premiumUsers,
      'revenue': revenue,
      'totalUsers': totalUsers,
    };
  }
}

class UserStats {
  final String userId;
  final String userName;
  final int adsWatched;
  final double earnings;
  final int referrals;
  final DateTime lastActive;

  UserStats({
    required this.userId,
    required this.userName,
    required this.adsWatched,
    required this.earnings,
    required this.referrals,
    required this.lastActive,
  });
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<void> recordDailyStats(AnalyticsData data) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'analytics_${_formatDate(data.date)}';

    await prefs.setString(key, jsonEncode(data.toJson()));
    AppLogger.info('Analytics recorded for ${data.date}');
  }

  Future<AnalyticsData?> getDailyStats(DateTime date) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'analytics_${_formatDate(date)}';

    final json = prefs.getString(key);
    if (json == null) return null;

    try {
      return AnalyticsData.fromJson(jsonDecode(json));
    } catch (e) {
      AppLogger.error('Error loading analytics', e);
      return null;
    }
  }

  Future<List<AnalyticsData>> getStatsRange(DateTime from, DateTime to) async {
    final results = <AnalyticsData>[];

    var current = from;
    while (!current.isAfter(to)) {
      final data = await getDailyStats(current);
      if (data != null) {
        results.add(data);
      }
      current = current.add(const Duration(days: 1));
    }

    return results;
  }

  Future<AnalyticsData> getTodayStats() async {
    final today = DateTime.now();
    final stats = await getDailyStats(today);

    if (stats != null) return stats;

    // Calculate from current data
    return await _calculateTodayStats();
  }

  Future<AnalyticsData> _calculateTodayStats() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final usersJson = prefs.getString('users');

    int totalUsers = 0;
    int todayUsers = 0;
    int totalAds = 0;
    double totalEarnings = 0;
    int premiumCount = 0;

    if (usersJson != null) {
      final users = (jsonDecode(usersJson) as List)
          .map((e) => UserModel.fromJson(e))
          .toList();

      totalUsers = users.length;
      final today = DateTime.now();

      for (final user in users) {
        totalAds += user.totalAdsWatched;
        totalEarnings += user.totalEarned;

        if (user.isPremium) premiumCount++;

        // Check if user was active today
        if (user.lastAdWatchDate != null) {
          final lastWatch = user.lastAdWatchDate!;
          if (lastWatch.year == today.year &&
              lastWatch.month == today.month &&
              lastWatch.day == today.day) {
            todayUsers++;
          }
        }
      }
    }

    return AnalyticsData(
      date: DateTime.now(),
      activeUsers: todayUsers,
      totalUsers: totalUsers,
      totalAdsWatched: totalAds,
      totalEarnings: totalEarnings,
      premiumUsers: premiumCount,
    );
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final today = await getTodayStats();
    final yesterday = await getDailyStats(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    // Calculate growth
    double userGrowth = 0;
    double earningsGrowth = 0;

    if (yesterday != null) {
      if (yesterday.activeUsers > 0) {
        userGrowth =
            ((today.activeUsers - yesterday.activeUsers) /
                yesterday.activeUsers) *
            100;
      }
      if (yesterday.totalEarnings > 0) {
        earningsGrowth =
            ((today.totalEarnings - yesterday.totalEarnings) /
                yesterday.totalEarnings) *
            100;
      }
    }

    // Get top users
    final topUsers = await getTopUsers(limit: 10);

    // Get 7-day trend
    final last7Days = await getStatsRange(
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now(),
    );

    return {
      'today': today.toJson(),
      'yesterday': yesterday?.toJson(),
      'userGrowth': userGrowth.toStringAsFixed(1),
      'earningsGrowth': earningsGrowth.toStringAsFixed(1),
      'topUsers': topUsers
          .map(
            (u) => {
              'id': u.userId,
              'name': u.userName,
              'ads': u.adsWatched,
              'earnings': u.earnings,
            },
          )
          .toList(),
      'trend7Days': last7Days.map((d) => d.toJson()).toList(),
    };
  }

  Future<List<UserStats>> getTopUsers({int limit = 10}) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final usersJson = prefs.getString('users');

    if (usersJson == null) return [];

    final users = (jsonDecode(usersJson) as List)
        .map((e) => UserModel.fromJson(e))
        .toList();

    final stats = <UserStats>[];

    for (final user in users) {
      // Calculate referrals
      final referrals = users.where((u) => u.referredBy == user.id).length;

      stats.add(
        UserStats(
          userId: user.id,
          userName: user.name,
          adsWatched: user.totalAdsWatched,
          earnings: user.totalEarned,
          referrals: referrals,
          lastActive: user.lastAdWatchDate ?? user.createdAt,
        ),
      );
    }

    // Sort by ads watched (descending)
    stats.sort((a, b) => b.adsWatched.compareTo(a.adsWatched));

    return stats.take(limit).toList();
  }

  Future<Map<String, dynamic>> getRevenueStats() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final usersJson = prefs.getString('users');

    double totalPaid = 0;
    double pendingWithdrawals = 0;
    int withdrawalCount = 0;

    if (usersJson != null) {
      final users = (jsonDecode(usersJson) as List)
          .map((e) => UserModel.fromJson(e))
          .toList();

      for (final user in users) {
        final walletJson = prefs.getString('wallet_${user.id}');
        if (walletJson != null) {
          final wallet = WalletModel.fromJson(jsonDecode(walletJson));
          totalPaid += wallet.balance;
          pendingWithdrawals += wallet.pendingBalance;

          withdrawalCount += wallet.transactions
              .where((t) => t.type == TransactionType.withdrawal)
              .length;
        }
      }
    }

    // Calculate estimated ad revenue
    final stats = await getTodayStats();
    final estimatedAdRevenue = stats.totalAdsWatched * 0.001; // $0.001 per ad

    return {
      'totalPaid': totalPaid,
      'pendingWithdrawals': pendingWithdrawals,
      'withdrawalCount': withdrawalCount,
      'estimatedAdRevenue': estimatedAdRevenue,
      'profit': estimatedAdRevenue - totalPaid,
    };
  }

  Future<void> incrementNewUser() async {
    final today = DateTime.now();
    var stats = await getDailyStats(today);

    stats ??= await _calculateTodayStats();

    final updated = AnalyticsData(
      date: stats.date,
      newUsers: stats.newUsers + 1,
      activeUsers: stats.activeUsers,
      totalAdsWatched: stats.totalAdsWatched,
      totalEarnings: stats.totalEarnings,
      totalWithdrawals: stats.totalWithdrawals,
      premiumUsers: stats.premiumUsers,
      revenue: stats.revenue,
    );

    await recordDailyStats(updated);
  }

  Future<void> recordPremiumPurchase(double amount) async {
    final today = DateTime.now();
    var stats = await getDailyStats(today);

    stats ??= await _calculateTodayStats();

    final updated = AnalyticsData(
      date: stats.date,
      newUsers: stats.newUsers,
      activeUsers: stats.activeUsers,
      totalAdsWatched: stats.totalAdsWatched,
      totalEarnings: stats.totalEarnings,
      totalWithdrawals: stats.totalWithdrawals,
      premiumUsers: stats.premiumUsers + 1,
      revenue: stats.revenue + amount,
    );

    await recordDailyStats(updated);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
