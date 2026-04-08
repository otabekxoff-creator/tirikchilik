import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../utils/validators.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();

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
    // Check if user already exists
    final existingByEmail = await _db.getUserByEmail(email);
    final existingByPhone = await _db.getUserByPhone(phone);
    if (existingByEmail != null || existingByPhone != null) {
      return false;
    }

    final userId = const Uuid().v4();
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);

    // Check referral code
    String? referredBy;
    if (referralCode != null && referralCode.isNotEmpty) {
      final referrer = await _db.getUserByReferralCode(referralCode);
      if (referrer != null) {
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

    // Save to database
    await _db.insertUser(newUser);
    await _db.saveSalt(userId, salt);

    // Create wallet for user
    await _db.createWallet(userId);

    // Save current user in SharedPreferences for session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
    _currentUser = newUser;
    return true;
  }

  Future<UserModel?> login(String emailOrPhone, String password) async {
    // Admin login
    final adminCreds = AppConstants.adminCredentials;
    if (emailOrPhone == adminCreds['login'] &&
        password == adminCreds['password']) {
      final adminUser = UserModel(
        id: 'admin',
        name: 'Admin',
        email: 'admin@tirikchilik.uz',
        phone: 'Admin777',
        isAdmin: true,
        createdAt: DateTime.now(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', 'admin');
      await prefs.setString('is_admin', 'true');
      _currentUser = adminUser;
      return adminUser;
    }

    // Find user by email or phone
    UserModel? foundUser = await _db.getUserByEmail(emailOrPhone);
    if (foundUser == null) {
      foundUser = await _db.getUserByPhone(emailOrPhone);
    }

    if (foundUser == null) return null;

    // Verify password (if user has passwordHash)
    if (foundUser.passwordHash != null) {
      final salt = await _db.getSalt(foundUser.id);
      final isPasswordValid = await _verifyPassword(
        password,
        foundUser.passwordHash,
        salt,
      );
      if (!isPasswordValid) return null;
    }

    // Reset daily ad count if it's a new day
    if (foundUser.isNewDay) {
      foundUser = foundUser.copyWith(dailyAdsWatched: 0, lastAdWatchDate: null);
      await _db.updateUser(foundUser);
    }

    // Save current user session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', foundUser.id);
    _currentUser = foundUser;
    return foundUser;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('is_admin');
    _currentUser = null;
  }

  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    if (userId == null) return null;

    // Check if admin
    final isAdmin = prefs.getString('is_admin') == 'true';
    if (isAdmin || userId == 'admin') {
      final adminUser = UserModel(
        id: 'admin',
        name: 'Admin',
        email: 'admin@tirikchilik.uz',
        phone: 'Admin777',
        isAdmin: true,
        createdAt: DateTime.now(),
      );
      _currentUser = adminUser;
      return adminUser;
    }

    final user = await _db.getUserById(userId);
    if (user == null) return null;

    // Reset daily ad count if it's a new day
    if (user.isNewDay) {
      final updatedUser = user.copyWith(
        dailyAdsWatched: 0,
        lastAdWatchDate: null,
      );
      await _db.updateUser(updatedUser);
      _currentUser = updatedUser;
      return updatedUser;
    }

    _currentUser = user;
    return _currentUser;
  }

  Future<void> updateUser(UserModel user) async {
    await _db.updateUser(user);
    _currentUser = user;
  }

  Future<List<UserModel>> getAllUsers() async {
    return await _db.getAllUsers();
  }

  Future<UserModel?> getUserByReferralCode(String code) async {
    return await _db.getUserByReferralCode(code);
  }

  Future<UserModel?> getUserById(String id) async {
    return await _db.getUserById(id);
  }
}
