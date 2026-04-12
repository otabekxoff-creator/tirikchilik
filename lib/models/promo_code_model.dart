class PromoCode {
  final String code;
  final String description;
  final PromoCodeType type;
  final double value;
  final DateTime validFrom;
  final DateTime validUntil;
  final int maxUses;
  final int currentUses;
  final bool isActive;
  final List<String>? allowedUsers; // null = all users
  final double? minEarningsRequired;
  final int? minAdsRequired;

  PromoCode({
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.validFrom,
    required this.validUntil,
    this.maxUses = 100,
    this.currentUses = 0,
    this.isActive = true,
    this.allowedUsers,
    this.minEarningsRequired,
    this.minAdsRequired,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      type: PromoCodeType.values.firstWhere(
        (e) => e.toString() == 'PromoCodeType.${json['type']}',
        orElse: () => PromoCodeType.bonus,
      ),
      value: (json['value'] ?? 0.0).toDouble(),
      validFrom: DateTime.parse(
        json['validFrom'] ?? DateTime.now().toIso8601String(),
      ),
      validUntil: DateTime.parse(
        json['validUntil'] ?? DateTime.now().toIso8601String(),
      ),
      maxUses: json['maxUses'] ?? 100,
      currentUses: json['currentUses'] ?? 0,
      isActive: json['isActive'] ?? true,
      allowedUsers: json['allowedUsers']?.cast<String>(),
      minEarningsRequired: json['minEarningsRequired']?.toDouble(),
      minAdsRequired: json['minAdsRequired'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'maxUses': maxUses,
      'currentUses': currentUses,
      'isActive': isActive,
      'allowedUsers': allowedUsers,
      'minEarningsRequired': minEarningsRequired,
      'minAdsRequired': minAdsRequired,
    };
  }

  bool isValidForUser(String userId, double userEarnings, int userAds) {
    if (!isActive) {
      return false;
    }
    if (currentUses >= maxUses) {
      return false;
    }

    final now = DateTime.now();
    if (now.isBefore(validFrom) || now.isAfter(validUntil)) {
      return false;
    }

    if (allowedUsers != null && !allowedUsers!.contains(userId)) {
      return false;
    }

    if (minEarningsRequired != null && userEarnings < minEarningsRequired!) {
      return false;
    }
    if (minAdsRequired != null && userAds < minAdsRequired!) {
      return false;
    }

    return true;
  }

  String get formattedValue {
    switch (type) {
      case PromoCodeType.bonus:
        return '+${value.toStringAsFixed(0)} so\'m';
      case PromoCodeType.multiplier:
        return '${value}x ko\'paytirgich';
      case PromoCodeType.premiumDiscount:
        return '-${value.toStringAsFixed(0)}%';
      case PromoCodeType.freePremiumDays:
        return '${value.toStringAsFixed(0)} kun premium';
    }
  }
}

enum PromoCodeType {
  bonus, // Direct so'm bonus
  multiplier, // Earnings multiplier for X hours
  premiumDiscount, // Premium subscription discount %
  freePremiumDays, // Free premium days
}

class UserPromoCode {
  final String userId;
  final String promoCode;
  final DateTime usedAt;
  final double rewardReceived;

  UserPromoCode({
    required this.userId,
    required this.promoCode,
    required this.usedAt,
    required this.rewardReceived,
  });

  factory UserPromoCode.fromJson(Map<String, dynamic> json) {
    return UserPromoCode(
      userId: json['userId'] ?? '',
      promoCode: json['promoCode'] ?? '',
      usedAt: DateTime.parse(
        json['usedAt'] ?? DateTime.now().toIso8601String(),
      ),
      rewardReceived: (json['rewardReceived'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'promoCode': promoCode,
      'usedAt': usedAt.toIso8601String(),
      'rewardReceived': rewardReceived,
    };
  }
}
