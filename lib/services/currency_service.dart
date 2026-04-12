import 'dart:convert';
import '../utils/app_logger.dart';
import 'shared_preferences_service.dart';

enum Currency {
  uzs, // Uzbek so'm (default)
  usd, // US Dollar
  rub, // Russian ruble
  kzt, // Kazakh tenge
  tjs, // Tajik somoni
  kgs, // Kyrgyz som
}

extension CurrencyExtension on Currency {
  String get code {
    switch (this) {
      case Currency.uzs:
        return 'UZS';
      case Currency.usd:
        return 'USD';
      case Currency.rub:
        return 'RUB';
      case Currency.kzt:
        return 'KZT';
      case Currency.tjs:
        return 'TJS';
      case Currency.kgs:
        return 'KGS';
    }
  }

  String get symbol {
    switch (this) {
      case Currency.uzs:
        return 'so\'m';
      case Currency.usd:
        return '\$';
      case Currency.rub:
        return '₽';
      case Currency.kzt:
        return '₸';
      case Currency.tjs:
        return 'SM';
      case Currency.kgs:
        return 'с';
    }
  }

  String get name {
    switch (this) {
      case Currency.uzs:
        return 'O\'zbek so\'mi';
      case Currency.usd:
        return 'AQSH dollari';
      case Currency.rub:
        return 'Rossiya rubli';
      case Currency.kzt:
        return 'Qozog\'iston tengesi';
      case Currency.tjs:
        return 'Tojikiston somoni';
      case Currency.kgs:
        return 'Qirg\'iziston somi';
    }
  }

  String get flag {
    switch (this) {
      case Currency.uzs:
        return '🇺🇿';
      case Currency.usd:
        return '🇺🇸';
      case Currency.rub:
        return '🇷🇺';
      case Currency.kzt:
        return '🇰🇿';
      case Currency.tjs:
        return '🇹🇯';
      case Currency.kgs:
        return '🇰🇬';
    }
  }
}

class ExchangeRate {
  final Currency from;
  final Currency to;
  final double rate;
  final DateTime updatedAt;

  ExchangeRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.updatedAt,
  });
}

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  static const String _selectedCurrencyKey = 'selected_currency';
  static const String _ratesKey = 'exchange_rates';
  static const String _ratesUpdatedKey = 'rates_updated_at';

  // Default exchange rates (should be updated from API in production)
  final Map<String, double> _defaultRates = {
    'UZS_USD': 0.00008, // 1 UZS = 0.00008 USD
    'UZS_RUB': 0.0075, // 1 UZS = 0.0075 RUB
    'UZS_KZT': 0.038, // 1 UZS = 0.038 KZT
    'UZS_TJS': 0.00088, // 1 UZS = 0.00088 TJS
    'UZS_KGS': 0.0072, // 1 UZS = 0.0072 KGS
    'USD_UZS': 12500, // 1 USD = 12500 UZS
    'USD_RUB': 92.5, // 1 USD = 92.5 RUB
    'USD_KZT': 500, // 1 USD = 500 KZT
    'USD_TJS': 11, // 1 USD = 11 TJS
    'USD_KGS': 89, // 1 USD = 89 KGS
    'RUB_UZS': 133.33, // 1 RUB = 133.33 UZS
    'RUB_USD': 0.0108, // 1 RUB = 0.0108 USD
    'RUB_KZT': 5.41, // 1 RUB = 5.41 KZT
    'RUB_TJS': 0.119, // 1 RUB = 0.119 TJS
    'RUB_KGS': 0.963, // 1 RUB = 0.963 KGS
    'KZT_UZS': 26.32, // 1 KZT = 26.32 UZS
    'KZT_USD': 0.002, // 1 KZT = 0.002 USD
    'KZT_RUB': 0.185, // 1 KZT = 0.185 RUB
    'KZT_TJS': 0.022, // 1 KZT = 0.022 TJS
    'KZT_KGS': 0.178, // 1 KZT = 0.178 KGS
    'TJS_UZS': 1136.36, // 1 TJS = 1136.36 UZS
    'TJS_USD': 0.091, // 1 TJS = 0.091 USD
    'TJS_RUB': 8.41, // 1 TJS = 8.41 RUB
    'TJS_KZT': 45.45, // 1 TJS = 45.45 KZT
    'TJS_KGS': 8.09, // 1 TJS = 8.09 KGS
    'KGS_UZS': 138.89, // 1 KGS = 138.89 UZS
    'KGS_USD': 0.011, // 1 KGS = 0.011 USD
    'KGS_RUB': 1.04, // 1 KGS = 1.04 RUB
    'KGS_KZT': 5.62, // 1 KGS = 5.62 KZT
    'KGS_TJS': 0.124, // 1 KGS = 0.124 TJS
  };

  Future<void> initialize() async {
    await _initializeDefaultRates();
    AppLogger.info('CurrencyService initialized');
  }

  Future<void> _initializeDefaultRates() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final existing = prefs.getString(_ratesKey);

    if (existing == null) {
      await prefs.setString(_ratesKey, jsonEncode(_defaultRates));
      await prefs.setString(_ratesUpdatedKey, DateTime.now().toIso8601String());
    }
  }

  Future<Currency> getSelectedCurrency() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final code = prefs.getString(_selectedCurrencyKey) ?? 'uzs';

    return Currency.values.firstWhere(
      (c) => c.code == code.toUpperCase(),
      orElse: () => Currency.uzs,
    );
  }

  Future<void> setSelectedCurrency(Currency currency) async {
    final prefs = SharedPreferencesService.instance.prefs;
    await prefs.setString(_selectedCurrencyKey, currency.code.toLowerCase());
    AppLogger.info('Selected currency: ${currency.code}');
  }

  Future<Map<String, double>> getExchangeRates() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final json = prefs.getString(_ratesKey);

    if (json == null) {
      await _initializeDefaultRates();
      return _defaultRates;
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(json);
      return decoded.map((key, value) => MapEntry(key, value.toDouble()));
    } catch (e) {
      AppLogger.error('Error loading exchange rates', e);
      return _defaultRates;
    }
  }

  Future<void> updateExchangeRates(Map<String, double> newRates) async {
    final prefs = SharedPreferencesService.instance.prefs;
    await prefs.setString(_ratesKey, jsonEncode(newRates));
    await prefs.setString(_ratesUpdatedKey, DateTime.now().toIso8601String());
    AppLogger.info('Exchange rates updated');
  }

  Future<DateTime?> getRatesLastUpdated() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final str = prefs.getString(_ratesUpdatedKey);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  double convert(
    double amount,
    Currency from,
    Currency to,
    Map<String, double> rates,
  ) {
    if (from == to) return amount;

    final key = '${from.code}_${to.code}';
    final rate = rates[key];

    if (rate == null) {
      // Try reverse conversion
      final reverseKey = '${to.code}_${from.code}';
      final reverseRate = rates[reverseKey];
      if (reverseRate != null) {
        return amount / reverseRate;
      }
      // Return original amount if no rate found
      return amount;
    }

    return amount * rate;
  }

  Future<double> convertAmount(
    double amount,
    Currency from,
    Currency to,
  ) async {
    final rates = await getExchangeRates();
    return convert(amount, from, to, rates);
  }

  String formatAmount(
    double amount,
    Currency currency, {
    bool showSymbol = true,
  }) {
    final formatted = _formatNumber(amount);

    if (showSymbol) {
      if (currency == Currency.usd || currency == Currency.rub) {
        return '${currency.symbol}$formatted';
      }
      return '$formatted ${currency.symbol}';
    }

    return formatted;
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(2);
    }
  }

  Future<String> formatInSelectedCurrency(double amountInUzs) async {
    final currency = await getSelectedCurrency();

    if (currency == Currency.uzs) {
      return formatAmount(amountInUzs, currency);
    }

    final converted = await convertAmount(amountInUzs, Currency.uzs, currency);
    return formatAmount(converted, currency);
  }

  List<Currency> getAvailableCurrencies() {
    return Currency.values;
  }

  // Get all exchange rates from UZS
  Future<Map<Currency, double>> getRatesFromUzs() async {
    final rates = await getExchangeRates();
    final result = <Currency, double>{};

    for (final currency in Currency.values) {
      if (currency == Currency.uzs) {
        result[currency] = 1.0;
      } else {
        final key = 'UZS_${currency.code}';
        result[currency] = rates[key] ?? 0.0;
      }
    }

    return result;
  }

  // Get all exchange rates to UZS
  Future<Map<Currency, double>> getRatesToUzs() async {
    final rates = await getExchangeRates();
    final result = <Currency, double>{};

    for (final currency in Currency.values) {
      if (currency == Currency.uzs) {
        result[currency] = 1.0;
      } else {
        final key = '${currency.code}_UZS';
        result[currency] = rates[key] ?? 0.0;
      }
    }

    return result;
  }

  // Check if rates need update (older than 1 hour)
  Future<bool> needsUpdate() async {
    final lastUpdated = await getRatesLastUpdated();
    if (lastUpdated == null) return true;

    return DateTime.now().difference(lastUpdated).inHours >= 1;
  }
}
