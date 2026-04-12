import 'dart:convert';
import '../models/promo_code_model.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';
import 'shared_preferences_service.dart';
import 'wallet_service.dart';

class PromoCodeService {
  static final PromoCodeService _instance = PromoCodeService._internal();
  factory PromoCodeService() => _instance;
  PromoCodeService._internal();

  final _walletService = WalletService();

  // Default promo codes
  static final List<PromoCode> _defaultPromoCodes = [
    PromoCode(
      code: 'WELCOME2024',
      description: 'Yangi foydalanuvchilar uchun 5 so\'m bonus',
      type: PromoCodeType.bonus,
      value: 5.0,
      validFrom: DateTime(2024, 1, 1),
      validUntil: DateTime(2024, 12, 31),
      maxUses: 1000,
    ),
    PromoCode(
      code: 'REFERRAL50',
      description: 'Referral bonus - 10 so\'m',
      type: PromoCodeType.bonus,
      value: 10.0,
      validFrom: DateTime(2024, 1, 1),
      validUntil: DateTime(2024, 12, 31),
      maxUses: 500,
    ),
    PromoCode(
      code: 'PREMIUM30',
      description: 'Premium obunaga 30% chegirma',
      type: PromoCodeType.premiumDiscount,
      value: 30.0,
      validFrom: DateTime(2024, 1, 1),
      validUntil: DateTime(2024, 12, 31),
      maxUses: 100,
    ),
    PromoCode(
      code: 'VIP50',
      description: 'VIP foydalanuvchilar uchun 50 so\'m',
      type: PromoCodeType.bonus,
      value: 50.0,
      validFrom: DateTime(2024, 1, 1),
      validUntil: DateTime(2024, 12, 31),
      maxUses: 50,
      minEarningsRequired: 100.0,
    ),
    PromoCode(
      code: 'ACTIVE100',
      description: '100 ta reklama ko\'rganlar uchun 20 so\'m',
      type: PromoCodeType.bonus,
      value: 20.0,
      validFrom: DateTime(2024, 1, 1),
      validUntil: DateTime(2024, 12, 31),
      maxUses: 200,
      minAdsRequired: 100,
    ),
  ];

  Future<void> initializeDefaultCodes() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'promo_codes_initialized';

    if (prefs.getBool(key) ?? false) return;

    final codes = await _getAllPromoCodes();
    if (codes.isEmpty) {
      await _saveAllPromoCodes(_defaultPromoCodes);
      AppLogger.info('Default promo codes initialized');
    }

    await prefs.setBool(key, true);
  }

  Future<List<PromoCode>> _getAllPromoCodes() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'promo_codes';
    final json = prefs.getString(key);

    if (json == null) return [];

    try {
      final List<dynamic> list = jsonDecode(json);
      return list.map((e) => PromoCode.fromJson(e)).toList();
    } catch (e) {
      AppLogger.error('Error loading promo codes', e);
      return [];
    }
  }

  Future<void> _saveAllPromoCodes(List<PromoCode> codes) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'promo_codes';
    final json = jsonEncode(codes.map((e) => e.toJson()).toList());
    await prefs.setString(key, json);
  }

  Future<PromoCode?> getPromoCode(String code) async {
    final codes = await _getAllPromoCodes();
    try {
      return codes.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<PromoCode>> getAllActiveCodes() async {
    final codes = await _getAllPromoCodes();
    final now = DateTime.now();

    return codes.where((c) {
      return c.isActive &&
          c.currentUses < c.maxUses &&
          now.isAfter(c.validFrom) &&
          now.isBefore(c.validUntil);
    }).toList();
  }

  Future<bool> hasUserUsedCode(String userId, String code) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'user_promo_codes_$userId';
    final json = prefs.getString(key);

    if (json == null) return false;

    try {
      final List<dynamic> list = jsonDecode(json);
      final userCodes = list.map((e) => UserPromoCode.fromJson(e)).toList();
      return userCodes.any(
        (uc) => uc.promoCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return false;
    }
  }

  Future<List<UserPromoCode>> getUserPromoCodeHistory(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'user_promo_codes_$userId';
    final json = prefs.getString(key);

    if (json == null) return [];

    try {
      final List<dynamic> list = jsonDecode(json);
      return list.map((e) => UserPromoCode.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _recordPromoCodeUse(
    String userId,
    String code,
    double reward,
  ) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final key = 'user_promo_codes_$userId';

    final history = await getUserPromoCodeHistory(userId);
    history.add(
      UserPromoCode(
        userId: userId,
        promoCode: code,
        usedAt: DateTime.now(),
        rewardReceived: reward,
      ),
    );

    await prefs.setString(
      key,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  Future<Map<String, dynamic>> applyPromoCode(
    String userId,
    String code,
    UserModel user,
  ) async {
    final promoCode = await getPromoCode(code);

    if (promoCode == null) {
      return {'success': false, 'message': 'Promo kod topilmadi'};
    }

    if (!promoCode.isValidForUser(
      userId,
      user.totalEarned,
      user.totalAdsWatched,
    )) {
      if (!promoCode.isActive) {
        return {'success': false, 'message': 'Promo kod faol emas'};
      }
      if (promoCode.currentUses >= promoCode.maxUses) {
        return {'success': false, 'message': 'Promo kod limiti tugadi'};
      }
      final now = DateTime.now();
      if (now.isBefore(promoCode.validFrom)) {
        return {'success': false, 'message': 'Promo kod hali faol emas'};
      }
      if (now.isAfter(promoCode.validUntil)) {
        return {'success': false, 'message': 'Promo kod muddati tugagan'};
      }
      if (promoCode.minEarningsRequired != null &&
          user.totalEarned < promoCode.minEarningsRequired!) {
        return {
          'success': false,
          'message':
              'Minimal ${promoCode.minEarningsRequired} so\'m ishlash kerak',
        };
      }
      if (promoCode.minAdsRequired != null &&
          user.totalAdsWatched < promoCode.minAdsRequired!) {
        return {
          'success': false,
          'message':
              'Minimal ${promoCode.minAdsRequired} ta reklama ko\'rish kerak',
        };
      }
      return {'success': false, 'message': 'Promo kodni ishlatib bo\'lmaydi'};
    }

    if (await hasUserUsedCode(userId, code)) {
      return {
        'success': false,
        'message': 'Siz bu kodni allaqachon ishlatgansiz',
      };
    }

    // Apply the promo code
    double reward = 0.0;
    String message = '';

    switch (promoCode.type) {
      case PromoCodeType.bonus:
        await _walletService.addBonus(
          userId,
          promoCode.value,
          'Promo kod: ${promoCode.code}',
        );
        reward = promoCode.value;
        message =
            '${promoCode.value.toStringAsFixed(0)} so\'m bonus qo\'shildi';
        break;
      case PromoCodeType.multiplier:
        // Store multiplier in preferences for later use
        final prefs = SharedPreferencesService.instance.prefs;
        await prefs.setDouble('earnings_multiplier_$userId', promoCode.value);
        await prefs.setString(
          'multiplier_expires_$userId',
          DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        );
        message = '${promoCode.value}x daromad ko\'paytirgichi 24 soat faol';
        break;
      case PromoCodeType.premiumDiscount:
        // Store discount for premium purchase
        final prefs = SharedPreferencesService.instance.prefs;
        await prefs.setDouble('premium_discount_$userId', promoCode.value);
        message =
            'Premium obunaga ${promoCode.value.toStringAsFixed(0)}% chegirma';
        break;
      case PromoCodeType.freePremiumDays:
        // Give free premium days
        final days = promoCode.value.toInt();
        // Logic to add free premium days
        message = '$days kun bepul premium obuna';
        break;
    }

    // Update promo code usage
    final allCodes = await _getAllPromoCodes();
    final index = allCodes.indexWhere((c) => c.code == promoCode.code);
    if (index != -1) {
      allCodes[index] = PromoCode(
        code: allCodes[index].code,
        description: allCodes[index].description,
        type: allCodes[index].type,
        value: allCodes[index].value,
        validFrom: allCodes[index].validFrom,
        validUntil: allCodes[index].validUntil,
        maxUses: allCodes[index].maxUses,
        currentUses: allCodes[index].currentUses + 1,
        isActive: allCodes[index].isActive,
        allowedUsers: allCodes[index].allowedUsers,
        minEarningsRequired: allCodes[index].minEarningsRequired,
        minAdsRequired: allCodes[index].minAdsRequired,
      );
      await _saveAllPromoCodes(allCodes);
    }

    // Record usage
    await _recordPromoCodeUse(userId, code, reward);

    AppLogger.info('Promo code ${promoCode.code} applied for user $userId');

    return {
      'success': true,
      'message': message,
      'type': promoCode.type.toString(),
      'value': promoCode.value,
    };
  }

  Future<double?> getActiveMultiplier(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final expiresStr = prefs.getString('multiplier_expires_$userId');

    if (expiresStr == null) return null;

    final expires = DateTime.parse(expiresStr);
    if (DateTime.now().isAfter(expires)) {
      await prefs.remove('earnings_multiplier_$userId');
      await prefs.remove('multiplier_expires_$userId');
      return null;
    }

    return prefs.getDouble('earnings_multiplier_$userId');
  }

  Future<double?> getPremiumDiscount(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    return prefs.getDouble('premium_discount_$userId');
  }

  Future<void> clearPremiumDiscount(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    await prefs.remove('premium_discount_$userId');
  }

  Future<void> createPromoCode(PromoCode code) async {
    final codes = await _getAllPromoCodes();
    codes.add(code);
    await _saveAllPromoCodes(codes);
    AppLogger.info('New promo code created: ${code.code}');
  }

  Future<void> deactivatePromoCode(String code) async {
    final codes = await _getAllPromoCodes();
    final index = codes.indexWhere((c) => c.code == code);
    if (index != -1) {
      codes[index] = PromoCode(
        code: codes[index].code,
        description: codes[index].description,
        type: codes[index].type,
        value: codes[index].value,
        validFrom: codes[index].validFrom,
        validUntil: codes[index].validUntil,
        maxUses: codes[index].maxUses,
        currentUses: codes[index].currentUses,
        isActive: false,
        allowedUsers: codes[index].allowedUsers,
        minEarningsRequired: codes[index].minEarningsRequired,
        minAdsRequired: codes[index].minAdsRequired,
      );
      await _saveAllPromoCodes(codes);
    }
  }
}
