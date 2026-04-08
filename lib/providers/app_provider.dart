import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/ad_model.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../services/ad_service.dart';
import '../utils/validators.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final WalletService _walletService = WalletService();
  final AdService _adService = AdService();

  UserModel? _currentUser;
  WalletModel? _wallet;
  List<AdModel> _todayAds = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  WalletModel? get wallet => _wallet;
  List<AdModel> get todayAds => _todayAds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isPremium => _currentUser?.isPremium ?? false;

  Future<void> init() async {
    _isLoading = true;
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      await _loadWallet();
    }
    _todayAds = _adService.generateDailyAds();
    _isLoading = false;
    Future.microtask(() => notifyListeners());
  }

  Future<void> login(String emailOrPhone, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authService.login(emailOrPhone, password);
      if (_currentUser != null) {
        await _loadWallet();
      } else {
        _error = 'Login yoki parol noto\'g\'ri';
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String password, {
    String? referralCode,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final success = await _authService.register(
        name,
        email,
        phone,
        password,
        referralCode: referralCode,
      );
      if (!success) {
        _error = 'Bu email yoki telefon allaqachon ro\'yxatdan o\'tgan';
      } else {
        // Give referral bonus if referral code was valid
        if (referralCode != null && referralCode.isNotEmpty) {
          final referrer = await _authService.getUserByReferralCode(
            referralCode,
          );
          if (referrer != null && referrer.id.isNotEmpty) {
            await _walletService.addBonus(
              _currentUser!.id,
              1.0,
              'Referral bonus - $referralCode',
            );
            // Also give bonus to referrer
            await _walletService.addBonus(
              referrer.id,
              0.5,
              'Referral bonus - ${referrer.name} ro\'yxatdan o\'tdi',
            );
          }
        }
        await _loadWallet();
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _wallet = null;
    notifyListeners();
  }

  Future<void> _loadWallet() async {
    if (_currentUser != null) {
      _wallet = await _walletService.getWallet(_currentUser!.id);
    }
  }

  int get dailyAdLimit =>
      isPremium ? AppConstants.dailyAdLimitPremium : AppConstants.dailyAdLimit;
  int get remainingAds =>
      _currentUser != null ? dailyAdLimit - _currentUser!.dailyAdsWatched : 0;
  bool get canWatchAd => remainingAds > 0;

  Future<void> watchAd(AdLevel level) async {
    if (_currentUser == null || _wallet == null) return;

    // Check daily limit
    if (!canWatchAd) {
      _error = 'Siz bugun maksimal reklama ko\'rdingiz. Ertaga qaytib keling!';
      notifyListeners();
      return;
    }

    _setLoading(true);

    await Future.delayed(
      Duration(
        seconds: level == AdLevel.oddiy
            ? 2
            : level == AdLevel.orta
            ? 3
            : 5,
      ),
    );

    final reward = _adService.calculateReward(level, isPremium: isPremium);

    await _walletService.addEarning(
      _currentUser!.id,
      reward,
      '${level.label} reklama ko\'rilgan',
      adLevel: level.label,
    );

    _wallet = await _walletService.getWallet(_currentUser!.id);

    _currentUser = _currentUser!.copyWith(
      totalAdsWatched: _currentUser!.totalAdsWatched + 1,
      dailyAdsWatched: _currentUser!.dailyAdsWatched + 1,
      lastAdWatchDate: DateTime.now(),
      totalEarned: _currentUser!.totalEarned + reward,
    );
    await _authService.updateUser(_currentUser!);

    _setLoading(false);
    notifyListeners();
  }

  Future<bool> withdraw(double amount, String method) async {
    if (_currentUser == null || _wallet == null) return false;

    _setLoading(true);
    final success = await _walletService.withdraw(
      _currentUser!.id,
      amount,
      '$method orqali yechib olish',
    );

    if (success) {
      _wallet = await _walletService.getWallet(_currentUser!.id);
    }

    _setLoading(false);
    notifyListeners();
    return success;
  }

  Future<void> upgradeToPremium() async {
    if (_currentUser == null) return;

    _setLoading(true);

    _currentUser = _currentUser!.copyWith(
      isPremium: true,
      premiumExpiry: DateTime.now().add(Duration(days: 30)),
    );
    await _authService.updateUser(_currentUser!);

    await _walletService.addEarning(
      _currentUser!.id,
      0,
      'Premium obuna faollashtirildi',
    );

    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    // Defer notifyListeners to avoid build phase issues
    Future.microtask(() => notifyListeners());
  }

  void clearError() {
    _error = null;
    Future.microtask(() => notifyListeners());
  }
}
