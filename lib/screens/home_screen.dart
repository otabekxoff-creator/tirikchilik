import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/ad_model.dart';
import '../theme/ios_theme.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';
import 'watch_ad_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      const _HomeTab(),
      const WalletScreen(),
      const ProfileScreen(),
      if (user.isAdmin) const AdminScreen(),
    ];

    final navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Asosiy'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet),
        label: 'Hamyon',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      if (user.isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    return Scaffold(
      backgroundColor: IOSTheme.systemGroupedBackground,
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: IOSTheme.systemBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: IOSTheme.systemBackground,
            selectedItemColor: IOSTheme.systemBlue,
            unselectedItemColor: IOSTheme.systemGray,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: navItems,
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  Future<void> _refreshData() async {
    final provider = context.read<AppProvider>();
    await provider.init();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final wallet = provider.wallet;

    return Scaffold(
      backgroundColor: IOSTheme.systemGroupedBackground,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: IOSTheme.systemBlue,
        backgroundColor: IOSTheme.systemBackground,
        child: CustomScrollView(
          slivers: [
            // iOS Style Large Navigation Bar
            SliverAppBar(
              expandedHeight: 180,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: IOSTheme.systemGroupedBackground,
              actions: [
                IconButton(
                  icon: Icon(Icons.leaderboard, color: IOSTheme.systemBlue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'Salom, ${user?.name ?? "Foydalanuvchi"}!',
                  style: IOSTheme.title3.copyWith(color: IOSTheme.label),
                ),
                background: Container(
                  color: IOSTheme.systemGroupedBackground,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          // iOS Style Balance Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: IOSTheme.premiumGradient,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: IOSTheme.mediumShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Balans',
                                        style: IOSTheme.subhead.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${wallet?.balance.toStringAsFixed(0) ?? "0"} so\'m',
                                        style: IOSTheme.largeTitle.copyWith(
                                          color: Colors.white,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // iOS Style Warning Banner
                    if (!provider.canWatchAd)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: IOSTheme.systemOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: IOSTheme.systemOrange.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: IOSTheme.systemOrange,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Siz bugun maksimal reklama ko\'rdingiz. Ertaga qaytib keling!',
                                style: IOSTheme.subhead.copyWith(
                                  color: IOSTheme.systemOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // iOS Style Premium Card
                    if (user?.isPremium ?? false)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: IOSTheme.goldGradient,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: IOSTheme.smallShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Premium faol',
                                    style: IOSTheme.headline.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Muddati: ${DateFormat('dd.MM.yyyy').format(user!.premiumExpiry!)}',
                                    style: IOSTheme.footnote.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(),
                    // iOS Style Daily Progress Card
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: IOSTheme.systemBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: IOSTheme.smallShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: provider.canWatchAd
                                      ? IOSTheme.systemBlue.withValues(
                                          alpha: 0.1,
                                        )
                                      : IOSTheme.systemGray5,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  provider.canWatchAd
                                      ? Icons.timer
                                      : Icons.timer_off,
                                  color: provider.canWatchAd
                                      ? IOSTheme.systemBlue
                                      : IOSTheme.systemGray,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bugunlik reklamalar',
                                      style: IOSTheme.headline.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${provider.remainingAds} / ${provider.dailyAdLimit} ta qoldi',
                                      style: IOSTheme.subhead.copyWith(
                                        color: IOSTheme.secondaryLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!provider.canWatchAd)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: IOSTheme.systemRed.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'LIMIT',
                                    style: IOSTheme.caption2.copyWith(
                                      color: IOSTheme.systemRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // iOS Style Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value:
                                  provider.remainingAds / provider.dailyAdLimit,
                              backgroundColor: IOSTheme.systemGray5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                provider.canWatchAd
                                    ? IOSTheme.systemBlue
                                    : IOSTheme.systemRed,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 8),
                    // iOS Style Section Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Reklama bo\'limlari',
                        style: IOSTheme.title3.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // iOS Style Ad Level Cards
                    _buildIOSLevelCard(
                      context,
                      AdLevel.oddiy,
                      'Oddiy reklamalar',
                      'Tez va oson pul ishlang',
                      Icons.play_circle_outline,
                      IOSTheme.systemGreen,
                    ).animate().fadeIn(delay: 100.ms).slideX(),
                    const SizedBox(height: 12),
                    _buildIOSLevelCard(
                      context,
                      AdLevel.orta,
                      "O'rta darajali reklamalar",
                      'Ko\'proq pul ishlang',
                      Icons.star_border,
                      IOSTheme.systemOrange,
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                    const SizedBox(height: 12),
                    _buildIOSLevelCard(
                      context,
                      AdLevel.jiddiy,
                      'Jiddiy reklamalar',
                      'Eng ko\'p pul ishlang',
                      Icons.workspace_premium,
                      IOSTheme.systemPurple,
                    ).animate().fadeIn(delay: 300.ms).slideX(),
                    const SizedBox(height: 24),
                    // iOS Style Stats Card
                    Container(
                      decoration: IOSTheme.iosCard,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildIOSStatItem(
                            'Reklamalar',
                            '${user?.totalAdsWatched ?? 0}',
                            Icons.visibility,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: IOSTheme.separator,
                          ),
                          _buildIOSStatItem(
                            'Jami',
                            '${user?.totalEarned.toStringAsFixed(0) ?? "0"} so\'m',
                            Icons.attach_money,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // iOS Style Level Card
  Widget _buildIOSLevelCard(
    BuildContext context,
    AdLevel level,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final provider = context.read<AppProvider>();
    final reward = provider.isPremium ? level.reward * 1.5 : level.reward;
    final isDisabled = !provider.canWatchAd;

    return Container(
      decoration: BoxDecoration(
        color: isDisabled ? IOSTheme.systemGray6 : IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDisabled ? [] : IOSTheme.smallShadow,
      ),
      child: InkWell(
        onTap: isDisabled
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Bugunlik reklama limiti tugagan!',
                      style: IOSTheme.subhead.copyWith(color: Colors.white),
                    ),
                    backgroundColor: IOSTheme.systemOrange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WatchAdScreen(level: level),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? IOSTheme.systemGray5
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDisabled ? IOSTheme.systemGray : color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: IOSTheme.headline.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDisabled
                            ? IOSTheme.secondaryLabel
                            : IOSTheme.label,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: IOSTheme.footnote.copyWith(
                        color: IOSTheme.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: isDisabled ? IOSTheme.systemGray : color,
                          size: 16,
                        ),
                        Text(
                          '+${reward.toStringAsFixed(0)}',
                          style: IOSTheme.subhead.copyWith(
                            color: isDisabled ? IOSTheme.systemGray : color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (provider.isPremium) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.workspace_premium,
                            color: isDisabled
                                ? IOSTheme.systemGray3
                                : IOSTheme.systemOrange,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDisabled ? IOSTheme.systemGray4 : IOSTheme.systemGray3,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // iOS Style Stat Item
  Widget _buildIOSStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: IOSTheme.systemBlue, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: IOSTheme.title3.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: IOSTheme.footnote.copyWith(color: IOSTheme.secondaryLabel),
        ),
      ],
    );
  }
}
