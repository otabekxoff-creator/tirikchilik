import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/ad_model.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../services/ad_service.dart';
import '../constants/app_constants.dart';

// App state class
class AppState {
  final UserModel? currentUser;
  final WalletModel? wallet;
  final List<AdModel> todayAds;
  final bool isLoading;
  final String? error;

  const AppState({
    this.currentUser,
    this.wallet,
    this.todayAds = const [],
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    UserModel? currentUser,
    WalletModel? wallet,
    List<AdModel>? todayAds,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      currentUser: currentUser ?? this.currentUser,
      wallet: wallet ?? this.wallet,
      todayAds: todayAds ?? this.todayAds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => currentUser?.isAdmin ?? false;
  bool get isPremium => currentUser?.isPremium ?? false;
  int get dailyAdLimit =>
      isPremium ? AppConstants.dailyAdLimitPremium : AppConstants.dailyAdLimit;
  int get remainingAds =>
      currentUser != null ? dailyAdLimit - currentUser!.dailyAdsWatched : 0;
  bool get canWatchAd => remainingAds > 0;
}

// AppProvider - StateNotifier
class AppNotifier extends StateNotifier<AppState> {
  final AuthService _authService = AuthService();
  final WalletService _walletService = WalletService();
  final AdService _adService = AdService();

  AppNotifier() : super(const AppState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final user = await _authService.getCurrentUser();
    WalletModel? wallet;
    if (user != null) {
      wallet = await _walletService.getWallet(user.id);
    }
    state = state.copyWith(
      currentUser: user,
      wallet: wallet,
      todayAds: _adService.generateDailyAds(),
      isLoading: false,
    );
  }

  Future<void> login(String emailOrPhone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(emailOrPhone, password);
      if (user != null) {
        final wallet = await _walletService.getWallet(user.id);
        state = state.copyWith(currentUser: user, wallet: wallet);
      } else {
        state = state.copyWith(error: 'Login yoki parol noto\'g\'ri');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String password, {
    String? referralCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _authService.register(
        name,
        email,
        phone,
        password,
        referralCode: referralCode,
      );
      if (!success) {
        state = state.copyWith(
          error: 'Bu email yoki telefon allaqachon ro\'yxatdan o\'tgan',
        );
      } else {
        final user = await _authService.getCurrentUser();
        if (referralCode != null && referralCode.isNotEmpty && user != null) {
          final referrer = await _authService.getUserByReferralCode(
            referralCode,
          );
          if (referrer != null && referrer.id.isNotEmpty) {
            await _walletService.addBonus(
              user.id,
              1.0,
              'Referral bonus - $referralCode',
            );
            await _walletService.addBonus(
              referrer.id,
              0.5,
              'Referral bonus - ${referrer.name} ro\'yxatdan o\'tdi',
            );
          }
        }
        if (user != null) {
          final wallet = await _walletService.getWallet(user.id);
          state = state.copyWith(currentUser: user, wallet: wallet);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AppState(todayAds: []);
    // Re-init to generate new daily ads
    init();
  }

  Future<void> watchAd(AdLevel level) async {
    final currentUser = state.currentUser;
    final wallet = state.wallet;
    if (currentUser == null || wallet == null) return;

    if (!state.canWatchAd) {
      state = state.copyWith(
        error: 'Siz bugun maksimal reklama ko\'rdingiz. Ertaga qaytib keling!',
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    await Future.delayed(
      Duration(
        seconds: level == AdLevel.oddiy
            ? 2
            : level == AdLevel.orta
            ? 3
            : 5,
      ),
    );

    final reward = _adService.calculateReward(
      level,
      isPremium: state.isPremium,
    );

    await _walletService.addEarning(
      currentUser.id,
      reward,
      '${level.label} reklama ko\'rilgan',
      adLevel: level.label,
    );

    final updatedWallet = await _walletService.getWallet(currentUser.id);

    final updatedUser = currentUser.copyWith(
      totalAdsWatched: currentUser.totalAdsWatched + 1,
      dailyAdsWatched: currentUser.dailyAdsWatched + 1,
      lastAdWatchDate: DateTime.now(),
      totalEarned: currentUser.totalEarned + reward,
    );
    await _authService.updateUser(updatedUser);

    state = state.copyWith(
      currentUser: updatedUser,
      wallet: updatedWallet,
      isLoading: false,
    );
  }

  Future<bool> withdraw(double amount, String method) async {
    final currentUser = state.currentUser;
    final wallet = state.wallet;
    if (currentUser == null || wallet == null) return false;

    state = state.copyWith(isLoading: true);
    final success = await _walletService.withdraw(
      currentUser.id,
      amount,
      '$method orqali yechib olish',
    );

    if (success) {
      final updatedWallet = await _walletService.getWallet(currentUser.id);
      state = state.copyWith(wallet: updatedWallet, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
    return success;
  }

  Future<void> upgradeToPremium() async {
    final currentUser = state.currentUser;
    if (currentUser == null) return;

    state = state.copyWith(isLoading: true);

    final updatedUser = currentUser.copyWith(
      isPremium: true,
      premiumExpiry: DateTime.now().add(Duration(days: 30)),
    );
    await _authService.updateUser(updatedUser);

    await _walletService.addEarning(
      updatedUser.id,
      0,
      'Premium obuna faollashtirildi',
    );

    state = state.copyWith(currentUser: updatedUser, isLoading: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final appProviderProvider = StateNotifierProvider<AppNotifier, AppState>(
  (ref) => AppNotifier(),
);
