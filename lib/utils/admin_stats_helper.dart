class AdminStatsHelper {
  static Map<String, dynamic> calculateStats(
    List<dynamic> users,
    List<dynamic> wallets,
  ) {
    final totalUsers = users.length;
    final totalBalance = wallets.fold<double>(
      0,
      (sum, w) => sum + (w.balance ?? 0),
    );
    final totalEarned = users.fold<double>(
      0,
      (sum, u) => sum + (u.totalEarned ?? 0),
    );
    final premiumUsers = users.where((u) => u.isPremium == true).length;
    final activeUsers = users.where((u) {
      if (u.lastAdWatchDate == null) return false;
      return DateTime.now().difference(u.lastAdWatchDate!).inDays <= 1;
    }).length;

    return {
      'totalUsers': totalUsers,
      'totalBalance': totalBalance,
      'totalEarned': totalEarned,
      'premiumUsers': premiumUsers,
      'activeUsers': activeUsers,
    };
  }
}
