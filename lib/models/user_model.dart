class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? passwordHash;
  final bool isAdmin;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final DateTime createdAt;
  final int totalAdsWatched;
  final double totalEarned;
  final int dailyAdsWatched;
  final DateTime? lastAdWatchDate;
  final String? referralCode;
  final String? referredBy;
  final int currentStreak;
  final int totalReferrals;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.passwordHash,
    this.isAdmin = false,
    this.isPremium = false,
    this.premiumExpiry,
    required this.createdAt,
    this.totalAdsWatched = 0,
    this.totalEarned = 0.0,
    this.dailyAdsWatched = 0,
    this.lastAdWatchDate,
    this.referralCode,
    this.referredBy,
    this.currentStreak = 0,
    this.totalReferrals = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      passwordHash: json['passwordHash'],
      isAdmin: json['isAdmin'] ?? false,
      isPremium: json['isPremium'] ?? false,
      premiumExpiry: json['premiumExpiry'] != null
          ? DateTime.parse(json['premiumExpiry'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      totalAdsWatched: json['totalAdsWatched'] ?? 0,
      totalEarned: (json['totalEarned'] ?? 0.0).toDouble(),
      dailyAdsWatched: json['dailyAdsWatched'] ?? 0,
      lastAdWatchDate: json['lastAdWatchDate'] != null
          ? DateTime.parse(json['lastAdWatchDate'])
          : null,
      referralCode: json['referralCode'],
      referredBy: json['referredBy'],
      currentStreak: json['currentStreak'] ?? 0,
      totalReferrals: json['totalReferrals'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
      'isAdmin': isAdmin,
      'isPremium': isPremium,
      'premiumExpiry': premiumExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'totalAdsWatched': totalAdsWatched,
      'totalEarned': totalEarned,
      'dailyAdsWatched': dailyAdsWatched,
      'lastAdWatchDate': lastAdWatchDate?.toIso8601String(),
      'referralCode': referralCode,
      'referredBy': referredBy,
      'currentStreak': currentStreak,
      'totalReferrals': totalReferrals,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? passwordHash,
    bool? isAdmin,
    bool? isPremium,
    DateTime? premiumExpiry,
    DateTime? createdAt,
    int? totalAdsWatched,
    double? totalEarned,
    int? dailyAdsWatched,
    DateTime? lastAdWatchDate,
    String? referralCode,
    String? referredBy,
    int? currentStreak,
    int? totalReferrals,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      isAdmin: isAdmin ?? this.isAdmin,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      createdAt: createdAt ?? this.createdAt,
      totalAdsWatched: totalAdsWatched ?? this.totalAdsWatched,
      totalEarned: totalEarned ?? this.totalEarned,
      dailyAdsWatched: dailyAdsWatched ?? this.dailyAdsWatched,
      lastAdWatchDate: lastAdWatchDate ?? this.lastAdWatchDate,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      currentStreak: currentStreak ?? this.currentStreak,
      totalReferrals: totalReferrals ?? this.totalReferrals,
    );
  }

  bool get isNewDay {
    final lastAdWatchDate = this.lastAdWatchDate;
    if (lastAdWatchDate == null) return true;
    final now = DateTime.now();
    return lastAdWatchDate.year != now.year ||
        lastAdWatchDate.month != now.month ||
        lastAdWatchDate.day != now.day;
  }
}
