import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';
import 'login_screen.dart';
import '../theme/ios_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appProviderProvider);
    final user = provider.currentUser;
    final themeState = ref.watch(themeProviderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark
            ? IOSTheme.darkSystemGroupedBackground
            : IOSTheme.systemGroupedBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? IOSTheme.darkSystemGroupedBackground
          : IOSTheme.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          // iOS Large Navigation Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            backgroundColor: isDark
                ? IOSTheme.darkSystemGroupedBackground
                : IOSTheme.systemGroupedBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? IOSTheme.darkLabel : IOSTheme.systemBlue,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: IOSTheme.systemRed),
                onPressed: () async {
                  await ref.read(appProviderProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
            title: Text(
              'Profil',
              style: IOSTheme.headline.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
              ),
            ),
            centerTitle: true,
          ),
          // Profile Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: user.isPremium
                        ? IOSTheme.premiumGradient
                        : IOSTheme.blueGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: IOSTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: IOSTheme.smallShadow,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          user.isAdmin
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          size: 50,
                          color: user.isPremium
                              ? IOSTheme.systemOrange
                              : IOSTheme.systemBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    if (user.isPremium) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: IOSTheme.smallShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: IOSTheme.systemOrange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: IOSTheme.systemOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Info Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Ma\'lumotlar',
                style: IOSTheme.headline.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                ),
              ),
            ),
          ),
          // Info Cards
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? IOSTheme.darkSecondarySystemBackground
                    : IOSTheme.systemBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildIOSInfoTile(
                    icon: Icons.phone_outlined,
                    iconColor: IOSTheme.systemBlue,
                    label: 'Telefon',
                    value: user.phone,
                    isFirst: true,
                    isDark: isDark,
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? IOSTheme.darkSeparator : IOSTheme.separator,
                    indent: 56,
                  ),
                  _buildIOSInfoTile(
                    icon: Icons.calendar_today_outlined,
                    iconColor: IOSTheme.systemIndigo,
                    label: 'Ro\'yxatdan o\'tgan',
                    value: DateFormat('dd.MM.yyyy').format(user.createdAt),
                    isDark: isDark,
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? IOSTheme.darkSeparator : IOSTheme.separator,
                    indent: 56,
                  ),
                  _buildIOSInfoTile(
                    icon: Icons.visibility_outlined,
                    iconColor: IOSTheme.systemGreen,
                    label: 'Ko\'rgan reklamalar',
                    value: '${user.totalAdsWatched} ta',
                    isDark: isDark,
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? IOSTheme.darkSeparator : IOSTheme.separator,
                    indent: 56,
                  ),
                  _buildIOSInfoTile(
                    icon: Icons.attach_money_outlined,
                    iconColor: IOSTheme.systemOrange,
                    label: 'Jami ishlangan',
                    value: '${user.totalEarned.toStringAsFixed(0)} so\'m',
                    isLast: true,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          // Referral Code
          if (user.referralCode != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? IOSTheme.darkSecondarySystemBackground
                      : IOSTheme.systemBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: IOSTheme.systemIndigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.share_outlined,
                        color: IOSTheme.systemIndigo,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Referral kodingiz',
                            style: IOSTheme.subhead.copyWith(
                              color: IOSTheme.secondaryLabel,
                            ),
                          ),
                          Text(
                            user.referralCode!,
                            style: IOSTheme.headline.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.copy_outlined,
                        color: IOSTheme.systemBlue,
                        size: 22,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Referral kod nusxalandi!',
                              style: IOSTheme.subhead.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: IOSTheme.systemGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          // Theme Toggle
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? IOSTheme.darkSecondarySystemBackground
                    : IOSTheme.systemBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: IOSTheme.systemPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      themeState.isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: IOSTheme.systemPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Tungi rejim',
                      style: IOSTheme.body.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                      ),
                    ),
                  ),
                  Switch(
                    value: themeState.isDarkMode,
                    onChanged: (_) {
                      ref.read(themeProviderProvider.notifier).toggleTheme();
                    },
                    activeThumbColor: IOSTheme.systemBlue,
                  ),
                ],
              ),
            ),
          ),
          // Premium Card
          if (!user.isPremium && !user.isAdmin)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: IOSTheme.goldGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: IOSTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: IOSTheme.smallShadow,
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: IOSTheme.systemOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Premium obuna',
                          style: IOSTheme.headline.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Premium obuna bilan 1.5 baravar ko\'proq pul ishlang!',
                      style: IOSTheme.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showPremiumDialog(context, ref),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          foregroundColor: IOSTheme.systemOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Premium olish',
                          style: IOSTheme.headline.copyWith(
                            color: IOSTheme.systemOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildIOSInfoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
    bool isDark = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        label,
        style: IOSTheme.subhead.copyWith(
          color: isDark ? IOSTheme.darkSecondaryLabel : IOSTheme.secondaryLabel,
        ),
      ),
      trailing: Text(
        value,
        style: IOSTheme.body.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: IOSTheme.goldGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Premium obuna',
              style: IOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Premium obuna imkoniyatlari:',
              style: IOSTheme.subhead.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildIOSFeatureItem('1.5 baravar ko\'proq pul'),
            _buildIOSFeatureItem('Reklamasiz tajriba'),
            _buildIOSFeatureItem('Tezkor yechib olish'),
            _buildIOSFeatureItem('Maxsus support'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: IOSTheme.systemGray6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.attach_money,
                    color: IOSTheme.systemOrange,
                    size: 24,
                  ),
                  Text(
                    '14 900 so\'m/oy',
                    style: IOSTheme.headline.copyWith(
                      fontWeight: FontWeight.bold,
                      color: IOSTheme.systemOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: IOSTheme.systemRed),
            child: Text(
              'Bekor',
              style: IOSTheme.body.copyWith(color: IOSTheme.systemRed),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(appProviderProvider.notifier).upgradeToPremium();
              if (!context.mounted) return;
              Navigator.pop(context);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Premium obuna faollashtirildi!',
                    style: IOSTheme.subhead.copyWith(color: Colors.white),
                  ),
                  backgroundColor: IOSTheme.systemGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: IOSTheme.systemOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Sotib olish',
              style: IOSTheme.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: IOSTheme.systemGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.check, color: IOSTheme.systemGreen, size: 16),
          ),
          const SizedBox(width: 10),
          Text(text, style: IOSTheme.body),
        ],
      ),
    );
  }
}
