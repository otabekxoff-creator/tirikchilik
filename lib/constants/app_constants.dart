class AppConstants {
  // Pagination
  static const int usersPerPage = 20;
  static const int adsPerPage = 10;

  // Ad rewards
  static const double baseReward = 0.10;
  static const double bronzeReward = 0.10;
  static const double silverReward = 0.20;
  static const double goldReward = 0.30;

  // Premium
  static const double premiumPrice = 50000.0;

  // Withdrawal
  static const double minimumWithdrawal = 10000.0;
  static const double maximumWithdrawal = 1000000.0;

  // Daily limits
  static const int maxDailyAds = 20;

  // Storage keys
  static const String usersKey = 'users';
  static const String currentUserKey = 'current_user';
  static const String walletsKey = 'wallets';
  static const String adsKey = 'custom_ads';
  static const String saltKey = 'password_salt';
  static const String languageCodeKey = 'language_code';
  static const String darkModeKey = 'dark_mode';

  // App info
  static const String appName = 'Tirikchilik';
  static const String appVersion = '1.0.0';
}
