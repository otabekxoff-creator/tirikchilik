import 'package:flutter_test/flutter_test.dart';
import 'package:tirikchilik/services/currency_service.dart';

void main() {
  group('CurrencyService Tests', () {
    late CurrencyService service;

    setUp(() async {
      service = CurrencyService();
      await service.initialize();
    });

    group('Currency Selection', () {
      test('should default to UZS', () async {
        final currency = await service.getSelectedCurrency();

        expect(currency, equals(Currency.uzs));
      });

      test('should set and get selected currency', () async {
        await service.setSelectedCurrency(Currency.usd);

        final currency = await service.getSelectedCurrency();

        expect(currency, equals(Currency.usd));
      });

      test('should support all 6 currencies', () {
        final currencies = service.getAvailableCurrencies();

        expect(currencies.length, equals(6));
        expect(currencies, contains(Currency.uzs));
        expect(currencies, contains(Currency.usd));
        expect(currencies, contains(Currency.rub));
        expect(currencies, contains(Currency.kzt));
        expect(currencies, contains(Currency.tjs));
        expect(currencies, contains(Currency.kgs));
      });
    });

    group('Currency Properties', () {
      test('should have correct currency codes', () {
        expect(Currency.uzs.code, equals('UZS'));
        expect(Currency.usd.code, equals('USD'));
        expect(Currency.rub.code, equals('RUB'));
        expect(Currency.kzt.code, equals('KZT'));
        expect(Currency.tjs.code, equals('TJS'));
        expect(Currency.kgs.code, equals('KGS'));
      });

      test('should have correct currency symbols', () {
        expect(Currency.uzs.symbol, equals('so\'m'));
        expect(Currency.usd.symbol, equals('\$'));
        expect(Currency.rub.symbol, equals('₽'));
        expect(Currency.kzt.symbol, equals('₸'));
        expect(Currency.tjs.symbol, equals('SM'));
        expect(Currency.kgs.symbol, equals('с'));
      });

      test('should have correct currency names', () {
        expect(Currency.uzs.name, contains('O\'zbek'));
        expect(Currency.usd.name, contains('dollari'));
      });

      test('should have correct flags', () {
        expect(Currency.uzs.flag, equals('🇺🇿'));
        expect(Currency.usd.flag, equals('🇺🇸'));
        expect(Currency.rub.flag, equals('🇷🇺'));
      });
    });

    group('Currency Conversion', () {
      test('should convert UZS to USD', () async {
        final rates = await service.getExchangeRates();
        final converted = service.convert(10000, Currency.uzs, Currency.usd, rates);

        expect(converted, greaterThan(0));
        expect(converted, lessThan(1)); // 10000 UZS < 1 USD
      });

      test('should convert USD to UZS', () async {
        final rates = await service.getExchangeRates();
        final converted = service.convert(1, Currency.usd, Currency.uzs, rates);

        expect(converted, greaterThan(10000)); // 1 USD > 10000 UZS
      });

      test('should return same amount for same currency', () async {
        final rates = await service.getExchangeRates();
        final converted = service.convert(100, Currency.uzs, Currency.uzs, rates);

        expect(converted, equals(100));
      });

      test('should convert with async method', () async {
        final converted = await service.convertAmount(1000, Currency.uzs, Currency.usd);

        expect(converted, greaterThan(0));
      });
    });

    group('Amount Formatting', () {
      test('should format UZS amount', () {
        final formatted = service.formatAmount(1500.50, Currency.uzs);

        expect(formatted, contains('1.5K'));
        expect(formatted, contains('so\'m'));
      });

      test('should format USD amount', () {
        final formatted = service.formatAmount(99.99, Currency.usd);

        expect(formatted, contains('\$'));
        expect(formatted, contains('99.99'));
      });

      test('should format large amounts with K/M suffix', () {
        expect(service.formatAmount(1500, Currency.uzs), contains('1.5K'));
        expect(service.formatAmount(2500000, Currency.uzs), contains('2.5M'));
      });

      test('should format without symbol', () {
        final formatted = service.formatAmount(1000, Currency.uzs, showSymbol: false);

        expect(formatted, equals('1K'));
        expect(formatted, isNot(contains('so\'m')));
      });
    });

    group('Exchange Rates', () {
      test('should have exchange rates', () async {
        final rates = await service.getExchangeRates();

        expect(rates.isNotEmpty, isTrue);
        expect(rates.containsKey('UZS_USD'), isTrue);
        expect(rates.containsKey('USD_UZS'), isTrue);
      });

      test('should update exchange rates', () async {
        final newRates = {'UZS_USD': 0.000081, 'USD_UZS': 12345.0};

        await service.updateExchangeRates(newRates);
        final rates = await service.getExchangeRates();

        expect(rates['UZS_USD'], equals(0.000081));
      });

      test('should get rates from UZS', () async {
        final rates = await service.getRatesFromUzs();

        expect(rates.length, equals(6));
        expect(rates[Currency.uzs], equals(1.0));
      });

      test('should get rates to UZS', () async {
        final rates = await service.getRatesToUzs();

        expect(rates.length, equals(6));
        expect(rates[Currency.uzs], equals(1.0));
      });
    });

    group('Rate Update Check', () {
      test('should check if rates need update', () async {
        final needsUpdate = await service.needsUpdate();

        // Should need update initially or after 1 hour
        expect(needsUpdate, isA<bool>());
      });

      test('should get last updated time', () async {
        final lastUpdated = await service.getRatesLastUpdated();

        expect(lastUpdated, isNotNull);
      });
    });
  });
}
