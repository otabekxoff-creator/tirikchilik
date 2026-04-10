import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/ios_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _topEarners = [];
  List<Map<String, dynamic>> _topWatchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    final authService = AuthService();
    final users = await authService.getAllUsers();

    // Top earners by total earned
    _topEarners = users
        .where((u) => !u.isAdmin)
        .map(
          (u) => {
            'name': u.name,
            'earned': u.totalEarned,
            'avatar': u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
          },
        )
        .toList();
    _topEarners.sort(
      (a, b) => (b['earned'] as double).compareTo(a['earned'] as double),
    );
    _topEarners = _topEarners.take(20).toList();

    // Top watchers by ads watched
    _topWatchers = users
        .where((u) => !u.isAdmin)
        .map(
          (u) => {
            'name': u.name,
            'watched': u.totalAdsWatched,
            'avatar': u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
          },
        )
        .toList();
    _topWatchers.sort(
      (a, b) => (b['watched'] as int).compareTo(a['watched'] as int),
    );
    _topWatchers = _topWatchers.take(20).toList();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? IOSTheme.darkSystemGroupedBackground
          : IOSTheme.systemGroupedBackground,
      appBar: AppBar(
        title: const Text('Liderlar taxtasi'),
        backgroundColor: isDark
            ? IOSTheme.darkTertiarySystemBackground
            : IOSTheme.systemBackground,
        foregroundColor: isDark ? IOSTheme.darkLabel : IOSTheme.label,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? IOSTheme.darkSecondarySystemGroupedBackground
                  : IOSTheme.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(IOSTheme.radius12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(IOSTheme.radius10),
                boxShadow: IOSTheme.smallShadow,
                gradient: const LinearGradient(
                  colors: IOSTheme.premiumGradient,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              labelStyle: IOSTheme.headline,
              unselectedLabelColor: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
              unselectedLabelStyle: IOSTheme.headline,
              tabs: const [
                Tab(
                  icon: Icon(Icons.attach_money_rounded),
                  text: 'Top Daromad',
                ),
                Tab(
                  icon: Icon(Icons.visibility_rounded),
                  text: 'Top Ko\'rilgan',
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildEarnersList(), _buildWatchersList()],
            ),
    );
  }

  Widget _buildEarnersList() {
    if (_topEarners.isEmpty) {
      return _buildEmptyState('Hali ma\'lumot yo\'q');
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      color: IOSTheme.systemBlue,
      backgroundColor: IOSTheme.systemBackground,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _topEarners.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _topEarners[index];
          return _buildLeaderboardItem(
            rank: index + 1,
            name: user['name'] as String,
            value: '${(user['earned'] as double).toStringAsFixed(0)} so\'m',
            subtitle: 'Jami ishlangan',
            avatar: user['avatar'] as String,
            isTop3: index < 3,
            valueColor: IOSTheme.systemGreen,
          );
        },
      ),
    );
  }

  Widget _buildWatchersList() {
    if (_topWatchers.isEmpty) {
      return _buildEmptyState('Hali ma\'lumot yo\'q');
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      color: IOSTheme.systemBlue,
      backgroundColor: IOSTheme.systemBackground,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _topWatchers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _topWatchers[index];
          return _buildLeaderboardItem(
            rank: index + 1,
            name: user['name'] as String,
            value: '${user['watched']} ta reklama',
            subtitle: 'Jami ko\'rilgan',
            avatar: user['avatar'] as String,
            isTop3: index < 3,
            valueColor: IOSTheme.systemBlue,
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required String value,
    required String subtitle,
    required String avatar,
    required bool isTop3,
    required Color valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTop = rank == 1;
    final isSecond = rank == 2;
    final isThird = rank == 3;

    // Top 3 uchun maxsus ranglar
    Color rankBadgeColor;
    IconData? rankIcon;
    Color badgeTextColor;
    Gradient? gradient;

    if (isTop) {
      rankBadgeColor = IOSTheme.systemYellow;
      rankIcon = Icons.emoji_events_rounded;
      badgeTextColor = Colors.white;
      gradient = const LinearGradient(
        colors: IOSTheme.goldGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isSecond) {
      rankBadgeColor = IOSTheme.systemGray2;
      rankIcon = Icons.emoji_events_rounded;
      badgeTextColor = Colors.white;
      gradient = LinearGradient(
        colors: [
          isDark ? IOSTheme.darkSecondaryLabel : IOSTheme.systemGray2,
          isDark ? IOSTheme.darkTertiaryLabel : IOSTheme.systemGray3,
        ],
      );
    } else if (isThird) {
      rankBadgeColor = IOSTheme.systemOrange;
      rankIcon = Icons.emoji_events_rounded;
      badgeTextColor = Colors.white;
      gradient = const LinearGradient(
        colors: [IOSTheme.systemOrange, IOSTheme.systemYellow],
      );
    } else {
      rankBadgeColor = isDark
          ? IOSTheme.darkTertiarySystemBackground
          : IOSTheme.systemGray6;
      rankIcon = null;
      badgeTextColor = isDark
          ? IOSTheme.darkSecondaryLabel
          : IOSTheme.secondaryLabel;
      gradient = null;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? IOSTheme.darkSecondarySystemGroupedBackground
            : IOSTheme.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(IOSTheme.radius16),
        border: isTop3
            ? Border.all(
                color: isTop
                    ? IOSTheme.systemYellow.withValues(alpha: 0.4)
                    : isSecond
                    ? IOSTheme.systemGray2.withValues(alpha: 0.3)
                    : IOSTheme.systemOrange.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: isTop3 ? IOSTheme.mediumShadow : IOSTheme.smallShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Rank badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradient,
                    boxShadow: isTop3
                        ? [
                            BoxShadow(
                              color: rankBadgeColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: rankIcon != null
                        ? Icon(rankIcon, color: badgeTextColor, size: 24)
                        : Text(
                            '#$rank',
                            style: IOSTheme.headline.copyWith(
                              color: badgeTextColor,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isTop3
                          ? [IOSTheme.systemBlue, IOSTheme.systemPurple]
                          : [
                              isDark
                                  ? IOSTheme.darkTertiarySystemBackground
                                  : IOSTheme.systemGray6,
                              isDark
                                  ? IOSTheme
                                        .darkSecondarySystemGroupedBackground
                                  : IOSTheme.systemGray5,
                            ],
                    ),
                    boxShadow: IOSTheme.smallShadow,
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: IOSTheme.title3.copyWith(
                        color: isTop3
                            ? Colors.white
                            : (isDark ? IOSTheme.darkLabel : IOSTheme.label),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: IOSTheme.headline.copyWith(
                          fontWeight: isTop3
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: IOSTheme.caption1.copyWith(
                          color: isDark
                              ? IOSTheme.darkSecondaryLabel
                              : IOSTheme.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Value badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: valueColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(IOSTheme.radius12),
                    border: Border.all(
                      color: valueColor.withValues(alpha: 0.24),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value,
                    style: IOSTheme.footnote.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  IOSTheme.systemBlue.withValues(alpha: 0.1),
                  IOSTheme.systemPurple.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.leaderboard_rounded,
              size: 64,
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: IOSTheme.title3.copyWith(
              color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Foydalanuvchilar ko\'payganda bu yerda ko\'rinadi',
            style: IOSTheme.footnote.copyWith(
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
