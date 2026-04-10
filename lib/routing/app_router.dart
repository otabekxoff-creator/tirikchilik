import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/watch_ad_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/admin_screen.dart';
import '../models/ad_model.dart';

// Router uchun route nomlari (constant)
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String watchAd = '/watch-ad';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';
  static const String admin = '/admin';
}

// Global router key
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

// Shell navigator for bottom navigation
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

// GoRouter konfiguratsiyasi
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash screen
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Login screen
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Register screen
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Home screen with shell navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        // Home tab
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeTabWrapper()),
        ),

        // Wallet tab
        GoRoute(
          path: AppRoutes.wallet,
          name: 'wallet',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WalletScreen()),
        ),

        // Profile tab
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),

        // Admin tab
        GoRoute(
          path: AppRoutes.admin,
          name: 'admin',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AdminScreen()),
        ),
      ],
    ),

    // Watch Ad screen (dialog)
    GoRoute(
      path: AppRoutes.watchAd,
      name: 'watch-ad',
      pageBuilder: (context, state) {
        AdLevel level = AdLevel.oddiy;
        if (state.extra != null && state.extra is Map<String, dynamic>) {
          level =
              (state.extra as Map<String, dynamic>)['level'] as AdLevel? ??
              AdLevel.oddiy;
        }
        return MaterialPage(
          fullscreenDialog: true,
          child: WatchAdScreen(level: level),
        );
      },
    ),

    // Leaderboard screen
    GoRoute(
      path: AppRoutes.leaderboard,
      name: 'leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
  ],
  // Error handling - 404 sahifa
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Sahifa topilmadi: ${state.uri.path}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Bosh sahifaga qaytish'),
          ),
        ],
      ),
    ),
  ),
  // Redirect logic - agar login qilmagan bo'lsa login ga yo'naltirish
  redirect: (context, state) {
    final uri = state.uri.path;

    // Splash dan keyin login yoki home ga yo'naltirish
    if (uri == AppRoutes.splash) {
      // Auth status tekshirish kerak
      // Hozircha null qaytaramiz - splash screen o'zi redirect qiladi
      return null;
    }

    return null;
  },
);

// Home tab wrapper - _HomeTab ni home_screen dan ko'rsatadi
class HomeTabWrapper extends StatelessWidget {
  const HomeTabWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabContent();
  }
}
