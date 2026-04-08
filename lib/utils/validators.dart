class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email kiriting';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Noto\'g\'ri email format';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqam kiriting';
    }
    // Uzbek phone number validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 12 && digitsOnly.length != 9) {
      return 'Telefon raqam 998XXXXXXXXX formatida bo\'lishi kerak';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parol kiriting';
    }
    if (value.length < 6) {
      return 'Parol kamida 6 ta belgi bo\'lishi kerak';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ism kiriting';
    }
    if (value.length < 2) {
      return 'Ism kamida 2 ta belgi bo\'lishi kerak';
    }
    return null;
  }

  static String? validateAmount(String? value, double maxAmount) {
    if (value == null || value.isEmpty) {
      return 'Summani kiriting';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Noto\'g\'ri summa';
    }
    if (amount > maxAmount) {
      return 'Maksimal summa: \$${maxAmount.toStringAsFixed(2)}';
    }
    return null;
  }
}

class AppConstants {
  static const int dailyAdLimit = 50;
  static const int dailyAdLimitPremium = 100;
  static const int minWithdrawAmount = 10;
  static const int premiumPrice = 999; // $9.99 cents

  static const Map<String, String> adminCredentials = {
    'login': 'Admin777',
    'password': 'admin7777',
  };
}
