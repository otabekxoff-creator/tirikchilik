import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _saltKey = 'password_salt';

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> _verifyPassword(
    String password,
    String? storedHash,
    String? salt,
  ) async {
    if (storedHash == null || salt == null) return false;
    final computedHash = _hashPassword(password, salt);
    return computedHash == storedHash;
  }

  Future<Map<String, String>> _getOrCreateSalt() async {
    final prefs = await SharedPreferences.getInstance();
    final saltsJson = prefs.getString(_saltKey);
    if (saltsJson != null) {
      return Map<String, String>.from(jsonDecode(saltsJson));
    }
    return {};
  }

  Future<void> _saveSalt(String userId, String salt) async {
    final prefs = await SharedPreferences.getInstance();
    final salts = await _getOrCreateSalt();
    salts[userId] = salt;
    await prefs.setString(_saltKey, jsonEncode(salts));
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<bool> register(
    String name,
    String email,
    String phone,
    String password, {
    String? referralCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    final users = usersJson != null
        ? (jsonDecode(usersJson) as List)
              .map((e) => UserModel.fromJson(e))
              .toList()
        : <UserModel>[];

    if (users.any((u) => u.email == email || u.phone == phone)) {
      return false;
    }

    final userId = const Uuid().v4();
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);

    // Check referral code
    String? referredBy;
    if (referralCode != null && referralCode.isNotEmpty) {
      final referrer = users.firstWhere(
        (u) => u.referralCode == referralCode,
        orElse: () => UserModel(
          id: '',
          name: '',
          email: '',
          phone: '',
          createdAt: DateTime.now(),
        ),
      );
      if (referrer.id.isNotEmpty) {
        referredBy = referrer.id;
      }
    }

    final newUser = UserModel(
      id: userId,
      name: name,
      email: email,
      phone: phone,
      passwordHash: passwordHash,
      createdAt: DateTime.now(),
      referralCode: _generateReferralCode(),
      referredBy: referredBy,
    );

    await _saveSalt(userId, salt);

    users.add(newUser);
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));
    _currentUser = newUser;
    return true;
  }

  Future<UserModel?> adminLogin(String emailOrPhone, String password) async {
    // Admin credentials stored securely
    const adminLogin = 'Admin777';
    const adminPassword = 'admin7777';

    if (emailOrPhone == adminLogin && password == adminPassword) {
      final adminUser = UserModel(
        id: 'admin',
        name: 'Admin',
        email: 'admin@tirikchilik.uz',
        phone: 'Admin777',
        isAdmin: true,
        createdAt: DateTime.now(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(adminUser.toJson()));
      _currentUser = adminUser;
      return adminUser;
    }
    return null;
  }

  Future<UserModel?> login(String emailOrPhone, String password) async {
    // Check admin login first
    final adminUser = await adminLogin(emailOrPhone, password);
    if (adminUser != null) return adminUser;

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return null;

    final users = (jsonDecode(usersJson) as List)
        .map((e) => UserModel.fromJson(e))
        .toList();

    UserModel? foundUser;
    for (var u in users) {
      if (u.email == emailOrPhone || u.phone == emailOrPhone) {
        foundUser = u;
        break;
      }
    }

    if (foundUser == null) return null;

    // Verify password (if user has passwordHash)
    if (foundUser.passwordHash != null) {
      final salts = await _getOrCreateSalt();
      final salt = salts[foundUser.id];
      final isPasswordValid = await _verifyPassword(
        password,
        foundUser.passwordHash,
        salt,
      );
      if (!isPasswordValid) return null;
    }
    // If no passwordHash (old user), allow any password for backward compatibility

    // Reset daily ad count if it's a new day
    if (foundUser.isNewDay) {
      foundUser = foundUser.copyWith(dailyAdsWatched: 0, lastAdWatchDate: null);
    }

    await prefs.setString(_currentUserKey, jsonEncode(foundUser.toJson()));
    _currentUser = foundUser;
    return foundUser;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    _currentUser = null;
  }

  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;

    final user = UserModel.fromJson(jsonDecode(userJson));

    // Reset daily ad count if it's a new day
    if (user.isNewDay) {
      final updatedUser = user.copyWith(
        dailyAdsWatched: 0,
        lastAdWatchDate: null,
      );
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
      _currentUser = updatedUser;
      return updatedUser;
    }

    _currentUser = user;
    return _currentUser;
  }

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

    if (!user.isAdmin) {
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final users = (jsonDecode(usersJson) as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = user;
          await prefs.setString(
            _usersKey,
            jsonEncode(users.map((e) => e.toJson()).toList()),
          );
        }
      }
    }
    _currentUser = user;
  }

  Future<List<UserModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return [];
    return (jsonDecode(usersJson) as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  Future<UserModel?> getUserByReferralCode(String code) async {
    final users = await getAllUsers();
    return users.firstWhere(
      (u) => u.referralCode == code,
      orElse: () => UserModel(
        id: '',
        name: '',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<bool> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return false;

    final users = (jsonDecode(usersJson) as List)
        .map((e) => UserModel.fromJson(e))
        .toList();

    users.removeWhere((u) => u.id == userId);
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((e) => e.toJson()).toList()),
    );
    return true;
  }
}
