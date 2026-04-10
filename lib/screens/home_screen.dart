import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/ad_model.dart';
import '../models/user_model.dart';
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

  void _onTabTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: 'Asosiy',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_rounded),
        label: 'Hamyon',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_rounded),
        label: 'Profil',
      ),
      if (user.isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_rounded),
          label: 'Admin',
        ),
    ];

    return Scaffold(
      backgroundColor: isDark
          ? IOSTheme.darkSystemGroupedBackground
          : IOSTheme.systemGroupedBackground,
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? IOSTheme.darkSystemBackground
              : IOSTheme.systemBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTabTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark
                ? IOSTheme.darkSystemBackground
                : IOSTheme.systemBackground,
            selectedItemColor: IOSTheme.systemBlue,
            unselectedItemColor: isDark
                ? IOSTheme.darkSecondaryLabel
                : IOSTheme.systemGray,
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

class _HomeTabState extends State<_HomeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _balanceAnimation;
  double _displayedBalance = 0;
  final ScrollController _scrollController = ScrollController();
  final double _expandedHeight = 180;
  bool _isAppBarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: IOSTheme.slowAnimation,
      vsync: this,
    );
    _balanceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: IOSTheme.iosDecelerate,
      ),
    );
    _animationController.forward();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed = _scrollController.offset > _expandedHeight * 0.6;
    if (collapsed != _isAppBarCollapsed) {
      setState(() => _isAppBarCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = context.read<AppProvider>();
    final wallet = provider.wallet;
    if (wallet != null && _displayedBalance != wallet.balance) {
      _displayedBalance = wallet.balance;
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.mediumImpact();
    final provider = context.read<AppProvider>();
    await provider.init();
  }

  void _showLevelSnackBar(BuildContext context, String message, Color color) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: IOSTheme.subhead.copyWith(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius12),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final wallet = provider.wallet;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? IOSTheme.darkSystemGroupedBackground
          : IOSTheme.systemGroupedBackground,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: IOSTheme.systemBlue,
        backgroundColor: isDark
            ? IOSTheme.darkSystemBackground
            : IOSTheme.systemBackground,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // iOS Style Large Navigation Bar
            SliverAppBar(
              expandedHeight: 180,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: isDark
                  ? IOSTheme.darkSystemGroupedBackground
                  : IOSTheme.systemGroupedBackground,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.leaderboard_rounded,
                    color: IOSTheme.systemBlue,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
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
                  style: IOSTheme.title3.copyWith(
                    color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                  ),
                ),
                background: Container(
                  color: isDark
                      ? IOSTheme.darkSystemGroupedBackground
                      : IOSTheme.systemGroupedBackground,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          // iOS Style Balance Card with Glassmorphism
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WalletScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: IOSTheme.premiumGradient,
                                ),
                                borderRadius: BorderRadius.circular(
                                  IOSTheme.radius20,
                                ),
                                boxShadow: IOSTheme.mediumShadow,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        IOSTheme.radius14,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
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
                                        AnimatedBuilder(
                                          animation: _balanceAnimation,
                                          builder: (context, child) {
                                            final animatedBalance =
                                                (wallet?.balance ?? 0) *
                                                _balanceAnimation.value;
                                            return Text(
                                              '${animatedBalance.toStringAsFixed(0)} so\'m',
                                              style: IOSTheme.largeTitle
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    size: 28,
                                  ),
                                ],
                              ),
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
                          color:
                              (isDark
                                      ? IOSTheme.systemOrange
                                      : IOSTheme.systemOrange)
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            IOSTheme.radius12,
                          ),
                          border: Border.all(
                            color: IOSTheme.systemOrange.withValues(
                              alpha: 0.24,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: IOSTheme.systemOrange,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Siz bugun maksimal reklama ko\'rdingiz. Ertaga qaytib keling!',
                                style: IOSTheme.subhead.copyWith(
                                  color: IOSTheme.systemOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(),
                    // iOS Style Premium Card
                    if (user?.isPremium ?? false)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: IOSTheme.goldGradient,
                          ),
                          borderRadius: BorderRadius.circular(
                            IOSTheme.radius16,
                          ),
                          boxShadow: IOSTheme.mediumShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  IOSTheme.radius10,
                                ),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
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
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 24,
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(),
                    // iOS Style Daily Progress Card
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? IOSTheme.darkSecondarySystemGroupedBackground
                            : IOSTheme.systemBackground,
                        borderRadius: BorderRadius.circular(IOSTheme.radius16),
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
                                      : (isDark
                                            ? IOSTheme
                                                  .darkTertiarySystemBackground
                                            : IOSTheme.systemGray5),
                                  borderRadius: BorderRadius.circular(
                                    IOSTheme.radius10,
                                  ),
                                ),
                                child: Icon(
                                  provider.canWatchAd
                                      ? Icons.timer_rounded
                                      : Icons.timer_off_rounded,
                                  color: provider.canWatchAd
                                      ? IOSTheme.systemBlue
                                      : (isDark
                                            ? IOSTheme.darkSecondaryLabel
                                            : IOSTheme.systemGray),
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
                                        color: isDark
                                            ? IOSTheme.darkLabel
                                            : IOSTheme.label,
                                      ),
                                    ),
                                    Text(
                                      '${provider.remainingAds} / ${provider.dailyAdLimit} ta qoldi',
                                      style: IOSTheme.subhead.copyWith(
                                        color: isDark
                                            ? IOSTheme.darkSecondaryLabel
                                            : IOSTheme.secondaryLabel,
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
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      IOSTheme.radius8,
                                    ),
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
                            borderRadius: BorderRadius.circular(
                              IOSTheme.radius4,
                            ),
                            child: LinearProgressIndicator(
                              value:
                                  provider.remainingAds / provider.dailyAdLimit,
                              backgroundColor: isDark
                                  ? IOSTheme.darkTertiarySystemBackground
                                  : IOSTheme.systemGray5,
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
                          color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
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
                      Icons.play_circle_outline_rounded,
                      IOSTheme.systemGreen,
                    ).animate().fadeIn(delay: 100.ms).slideX(),
                    const SizedBox(height: 12),
                    _buildIOSLevelCard(
                      context,
                      AdLevel.orta,
                      "O'rta darajali reklamalar",
                      'Ko\'proq pul ishlang',
                      Icons.star_rounded,
                      IOSTheme.systemOrange,
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                    const SizedBox(height: 12),
                    _buildIOSLevelCard(
                      context,
                      AdLevel.jiddiy,
                      'Jiddiy reklamalar',
                      'Eng ko\'p pul ishlang',
                      Icons.workspace_premium_rounded,
                      IOSTheme.systemPurple,
                    ).animate().fadeIn(delay: 300.ms).slideX(),
                    const SizedBox(height: 24),
                    // iOS Style Stats Card
                    Container(
                      decoration: isDark
                          ? IOSTheme.iosGroupedCard
                          : IOSTheme.iosCard,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildIOSStatItem(
                            'Reklamalar',
                            '${user?.totalAdsWatched ?? 0}',
                            Icons.visibility_rounded,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: isDark
                                ? IOSTheme.darkSeparator
                                : IOSTheme.separator,
                          ),
                          _buildIOSStatItem(
                            'Jami',
                            '${user?.totalEarned.toStringAsFixed(0) ?? "0"} so\'m',
                            Icons.attach_money_rounded,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reward = provider.isPremium ? level.reward * 1.5 : level.reward;
    final isDisabled = !provider.canWatchAd;

    return Container(
      decoration: BoxDecoration(
        color: isDisabled
            ? (isDark
                  ? IOSTheme.darkTertiarySystemBackground
                  : IOSTheme.systemGray6)
            : (isDark
                  ? IOSTheme.darkSecondarySystemGroupedBackground
                  : IOSTheme.systemBackground),
        borderRadius: BorderRadius.circular(IOSTheme.radius16),
        boxShadow: isDisabled ? [] : IOSTheme.smallShadow,
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          if (isDisabled) {
            _showLevelSnackBar(
              context,
              'Bugunlik reklama limiti tugagan!',
              IOSTheme.systemOrange,
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WatchAdScreen(level: level)),
            );
          }
        },
        borderRadius: BorderRadius.circular(IOSTheme.radius16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? (isDark
                            ? IOSTheme.darkTertiarySystemBackground
                            : IOSTheme.systemGray5)
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(IOSTheme.radius12),
                ),
                child: Icon(
                  icon,
                  color: isDisabled
                      ? (isDark
                            ? IOSTheme.darkSecondaryLabel
                            : IOSTheme.systemGray)
                      : color,
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
                            ? (isDark
                                  ? IOSTheme.darkSecondaryLabel
                                  : IOSTheme.secondaryLabel)
                            : (isDark ? IOSTheme.darkLabel : IOSTheme.label),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: IOSTheme.footnote.copyWith(
                        color: isDark
                            ? IOSTheme.darkSecondaryLabel
                            : IOSTheme.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money_rounded,
                          color: isDisabled
                              ? (isDark
                                    ? IOSTheme.darkSecondaryLabel
                                    : IOSTheme.systemGray)
                              : color,
                          size: 16,
                        ),
                        Text(
                          '+${reward.toStringAsFixed(0)}',
                          style: IOSTheme.subhead.copyWith(
                            color: isDisabled
                                ? (isDark
                                      ? IOSTheme.darkSecondaryLabel
                                      : IOSTheme.systemGray)
                                : color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (provider.isPremium) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: isDisabled
                                ? (isDark
                                      ? IOSTheme.darkTertiaryLabel
                                      : IOSTheme.systemGray3)
                                : IOSTheme.systemOrange,
                            size: 14,
                          ),
                          Text(
                            '1.5x',
                            style: IOSTheme.caption1.copyWith(
                              color: isDisabled
                                  ? (isDark
                                        ? IOSTheme.darkTertiaryLabel
                                        : IOSTheme.systemGray3)
                                  : IOSTheme.systemOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDisabled
                    ? (isDark
                          ? IOSTheme.darkTertiaryLabel
                          : IOSTheme.systemGray4)
                    : (isDark
                          ? IOSTheme.darkSecondaryLabel
                          : IOSTheme.systemGray3),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(
          icon,
          color: isDark ? IOSTheme.systemTeal : IOSTheme.systemBlue,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: IOSTheme.title3.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
          ),
        ),
        Text(
          label,
          style: IOSTheme.footnote.copyWith(
            color: isDark
                ? IOSTheme.darkSecondaryLabel
                : IOSTheme.secondaryLabel,
          ),
        ),
      ],
    );
  }
}
