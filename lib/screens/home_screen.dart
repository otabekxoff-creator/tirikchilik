import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../providers/app_provider.dart';
import '../models/ad_model.dart';
import '../models/user_model.dart';
import '../theme/ios_theme.dart';
import '../routing/app_router.dart';
import 'watch_ad_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appProviderProvider);
    final user = provider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Tablar ro'yxati
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
      body: widget.child,
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
            currentIndex: _getCurrentTabIndex(),
            onTap: (index) => _onTabTap(context, index),
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

  int _getCurrentTabIndex() {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains(AppRoutes.wallet)) return 1;
    if (location.contains(AppRoutes.profile)) return 2;
    if (location.contains(AppRoutes.admin)) return 3;
    return 0; // home
  }

  void _onTabTap(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.wallet);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
      case 3:
        context.go(AppRoutes.admin);
        break;
    }
  }
}

// Home tab asosiy kontenti - routing uchun ishlatiladi
class HomeTabContent extends ConsumerStatefulWidget {
  const HomeTabContent({super.key});

  @override
  ConsumerState<HomeTabContent> createState() => _HomeTabContentState();
}

// Achievement modeli
class _Achievement {
  final IconData icon;
  final String label;
  final String description;
  bool unlocked;
  final Color color;

  _Achievement({
    required this.icon,
    required this.label,
    required this.description,
    this.unlocked = false,
    required this.color,
  });
}

class _HomeTabContentState extends ConsumerState<HomeTabContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _balanceAnimation;
  double _displayedBalance = 0;
  final ScrollController _scrollController = ScrollController();
  final double _expandedHeight = 260;
  bool _isAppBarCollapsed = false;

  // Countdown timer (currently not used in UI)
  // ignore: unused_field
  Timer? _countdownTimer;
  // ignore: unused_field
  Duration _timeUntilMidnight = Duration.zero;

  // Achievement badges
  final List<_Achievement> _achievements = [];

  // Weekly earnings data (currently not used in UI)
  List<FlSpot> _weeklyEarnings = [];
  // ignore: unused_field
  double _weeklyTotal = 0;
  // ignore: unused_field
  bool _isTrendingUp = false;

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
    _initCountdown();
    _initAchievements();
    _initWeeklyEarnings();
  }

  void _initCountdown() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _timeUntilMidnight = midnight.difference(now);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day + 1);
      setState(() {
        _timeUntilMidnight = midnight.difference(now);
      });
    });
  }

  void _initAchievements() {
    _achievements.addAll([
      _Achievement(
        icon: Icons.play_arrow_rounded,
        label: 'Boshlandi',
        description: 'Birinchi qadam',
        unlocked: true,
        color: IOSTheme.systemGreen,
      ),
      _Achievement(
        icon: Icons.visibility_rounded,
        label: '10 reklama',
        description: '10 ta reklama ko\'rish',
        unlocked: false,
        color: IOSTheme.systemBlue,
      ),
      _Achievement(
        icon: Icons.local_fire_department_rounded,
        label: '5 kun',
        description: '5 kun streak',
        unlocked: false,
        color: IOSTheme.systemOrange,
      ),
      _Achievement(
        icon: Icons.attach_money_rounded,
        label: '1000 so\'m',
        description: '1000 so\'m ishlash',
        unlocked: false,
        color: IOSTheme.systemPurple,
      ),
    ]);
  }

  void _initWeeklyEarnings() {
    // Generate sample data for last 7 days
    _weeklyEarnings = [];
    _weeklyTotal = 0;
    double previousTotal = 0;

    for (int i = 6; i >= 0; i--) {
      // Simulated daily earnings (would come from actual data)
      final dailyEarned =
          (i == 0 ? _calculateTodayEarnings(null) : 50.0 + (i * 10)).toDouble();
      _weeklyTotal += dailyEarned;
      _weeklyEarnings.add(FlSpot(i.toDouble(), dailyEarned));

      if (i == 1) previousTotal = dailyEarned;
    }

    _isTrendingUp = _weeklyEarnings.last.y >= previousTotal;
  }

  void _onScroll() {
    final collapsed = _scrollController.offset > _expandedHeight * 0.6;
    if (collapsed != _isAppBarCollapsed) {
      setState(() => _isAppBarCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = ref.read(appProviderProvider);
    final wallet = provider.wallet;
    if (wallet != null && _displayedBalance != wallet.balance) {
      _displayedBalance = wallet.balance;
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.mediumImpact();
    final provider = ref.read(appProviderProvider.notifier);
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

  double _calculateTodayEarnings(UserModel? user) {
    if (user == null) return 0.0;
    // Bugungi reklamalardan earnings
    final todayAds = user.dailyAdsWatched;
    // Simple calculation - har bir ad uchun ~0.10
    return todayAds * 0.10;
  }

  int _getStreakDays(UserModel? user) {
    if (user == null) return 0;
    // Simple streak calculation - would need actual streak field in model
    // For now, using total days since lastAdWatchDate
    if (user.lastAdWatchDate == null) return 0;
    final daysDiff = DateTime.now().difference(user.lastAdWatchDate!).inDays;
    // If user watched today or yesterday, streak continues
    if (daysDiff <= 1) {
      // This is simplified - real implementation would track streak
      return user.dailyAdsWatched > 0 ? (user.totalAdsWatched ~/ 10) + 1 : 0;
    }
    return 0;
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
    bool isStreak = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? IOSTheme.darkSecondarySystemGroupedBackground
            : IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(IOSTheme.radius12),
        boxShadow: IOSTheme.smallShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: isStreak ? IOSTheme.systemOrange : color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: IOSTheme.title3.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: IOSTheme.caption1.copyWith(
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  IOSTheme.darkPremiumGradient[0],
                  IOSTheme.darkPremiumGradient[1],
                ]
              : [IOSTheme.systemPurple, IOSTheme.systemPink],
        ),
        borderRadius: BorderRadius.circular(IOSTheme.radius16),
        boxShadow: IOSTheme.mediumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(IOSTheme.radius10),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
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
                      'Do\'stingizni taklif qiling!',
                      style: IOSTheme.headline.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '500 so\'m bonus oling',
                      style: IOSTheme.footnote.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // Navigate to profile to copy referral code
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Profil bo\'limida referral kodingizni oling',
                      style: IOSTheme.subhead.copyWith(color: Colors.white),
                    ),
                    backgroundColor: IOSTheme.systemPurple,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(IOSTheme.radius12),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(
                'Referal kodim',
                style: IOSTheme.footnote.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(IOSTheme.radius10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? IOSTheme.darkSecondarySystemGroupedBackground
            : IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(IOSTheme.radius20),
        boxShadow: IOSTheme.mediumShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              ),
            ),
            child: const Icon(
              Icons.play_circle_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Xush kelibsiz!',
            style: IOSTheme.title2.copyWith(
              color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reklama ko\'rib pul ishlashni boshlang!\nHar bir reklama uchun darhol hisobga olinadi.',
            style: IOSTheme.subhead.copyWith(
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // Scroll to ad sections
                _scrollController.animateTo(
                  400,
                  duration: IOSTheme.slowAnimation,
                  curve: IOSTheme.iosSpring,
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Boshlash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: IOSTheme.systemBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(IOSTheme.radius12),
                ),
                textStyle: IOSTheme.headline.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appProviderProvider);
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
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // iOS Style Large Navigation Bar with Collapsed Title
            SliverAppBar(
              expandedHeight: _expandedHeight,
              floating: true,
              pinned: true,
              elevation: 0,
              centerTitle: true,
              title: AnimatedOpacity(
                duration: IOSTheme.standardAnimation,
                opacity: _isAppBarCollapsed ? 1.0 : 0.0,
                child: Text(
                  'Asosiy',
                  style: IOSTheme.headline.copyWith(
                    color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                  ),
                ),
              ),
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
                          const SizedBox(height: 20),
                          // iOS Style Balance Card with Glassmorphism
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context.go(AppRoutes.wallet);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? IOSTheme.darkPremiumGradient
                                      : IOSTheme.premiumGradient,
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
                          const SizedBox(height: 16),
                          // Quick Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickStatCard(
                                  icon: Icons.visibility_rounded,
                                  value: '${user?.dailyAdsWatched ?? 0}',
                                  label: 'Bugun ko\'rildi',
                                  color: IOSTheme.systemBlue,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickStatCard(
                                  icon: Icons.attach_money_rounded,
                                  value: '+${_calculateTodayEarnings(user)}',
                                  label: 'Bugungi daromad',
                                  color: IOSTheme.systemGreen,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickStatCard(
                                  icon: Icons.local_fire_department_rounded,
                                  value: '${_getStreakDays(user)}',
                                  label: 'Kun streak',
                                  color: IOSTheme.systemOrange,
                                  isDark: isDark,
                                  isStreak: true,
                                ),
                              ),
                            ],
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
                    // Greeting Text
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Assalomu alaykum, ${user?.name ?? "Foydalanuvchi"}!',
                        style: IOSTheme.title2.copyWith(
                          color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
                    // Referral Banner (if not referred)
                    if (user?.referredBy == null || user!.referredBy!.isEmpty)
                      _buildReferralBanner(isDark).animate().fadeIn().slideY(),
                    if (user?.referredBy == null || user!.referredBy!.isEmpty)
                      const SizedBox(height: 12),
                    // Empty State for New Users
                    if (user?.totalAdsWatched == 0)
                      _buildEmptyState(isDark).animate().fadeIn().slideY(),
                    if (user?.totalAdsWatched == 0) const SizedBox(height: 16),
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
    final provider = ref.read(appProviderProvider);
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
