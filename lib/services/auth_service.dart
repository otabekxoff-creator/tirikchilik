import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/user_model.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storage = StorageService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<bool> isLoggedIn() async {
    final token = await _storage.read('auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await _storage.read('auth_token');
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email va parol kiritilishi shart');
      }

      final user = UserModel(
        id: 'user_${email.hashCode}',
        name: email.split('@').first,
        email: email,
        phone: '+998901234567',
        isPremium: false,
        createdAt: DateTime.now(),
        totalAdsWatched: 0,
        totalEarned: 0.0,
        referralCode: _generateReferralCode(),
        isAdmin: false,
      );

      _currentUser = user;
      await _saveUserToStorage(user);
      await _storage.write('auth_token', _generateToken(user.id));

      return user;
    } catch (e) {
      AppLogger.error('Login error', e);
      return null;
    }
  }

  Future<UserModel?> adminLogin(String login, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (login == 'admin' && password == 'admin123') {
        final user = UserModel(
          id: 'admin_001',
          name: 'Admin',
          email: 'admin@tirikchilik.uz',
          phone: '+998901234567',
          isPremium: true,
          createdAt: DateTime.now(),
          totalAdsWatched: 0,
          totalEarned: 0.0,
          referralCode: null,
          isAdmin: true,
        );

        _currentUser = user;
        await _saveUserToStorage(user);
        await _storage.write('auth_token', _generateToken(user.id));

        return user;
      }

      return null;
    } catch (e) {
      AppLogger.error('Admin login error', e);
      return null;
    }
  }

  Future<UserModel?> register(
    String name,
    String email,
    String phone,
    String password, {
    String? referralCode,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        isPremium: false,
        createdAt: DateTime.now(),
        totalAdsWatched: 0,
        totalEarned: referralCode != null ? 10000.0 : 0.0,
        referralCode: _generateReferralCode(),
        isAdmin: false,
      );

      _currentUser = user;
      await _saveUserToStorage(user);
      await _storage.write('auth_token', _generateToken(user.id));

      return user;
    } catch (e) {
      AppLogger.error('Register error', e);
      return null;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.delete('auth_token');
    await _storage.delete('user_data');
  }

  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final userData = await _storage.read('user_data');
    if (userData != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userData));
        return _currentUser;
      } catch (e) {
        AppLogger.error('Error parsing user data', e);
      }
    }
    return null;
  }

  Future<void> _saveUserToStorage(UserModel user) async {
    await _storage.write('user_data', jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUserByReferralCode(String referralCode) async {
    // Stub implementation - would query backend in real app
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    await _saveUserToStorage(user);
  }

  Future<List<UserModel>> getAllUsers() async {
    // Stub implementation - would query backend in real app
    return [];
  }

  Future<void> deleteUser(String userId) async {
    // Stub implementation - would delete from backend in real app
    await _storage.delete('user_data');
    await _storage.delete('auth_token');
  }

  String _generateToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = utf8.encode('$userId:$timestamp:secret_key');
    final hash = sha256.convert(data);
    return hash.toString();
  }

  String _generateReferralCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
