import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../utils/app_logger.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'flutter_secure_storage_service',
    ),
  );

  // Encryption key for additional layer of security
  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;

  Future<void> initialize() async {
    try {
      // Generate or retrieve encryption key
      String? keyString = await _storage.read(key: '_encryption_key');
      if (keyString == null) {
        final key = encrypt.Key.fromSecureRandom(32);
        keyString = key.base64;
        await _storage.write(key: '_encryption_key', value: keyString);
      }

      _key = encrypt.Key.fromBase64(keyString);
      _iv = encrypt.IV.fromLength(16);
      _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

      AppLogger.info('SecureStorage initialized');
    } catch (e, stack) {
      AppLogger.error('SecureStorage initialization failed', e, stack);
      rethrow;
    }
  }

  Future<void> write(String key, String value) async {
    try {
      // Encrypt value before storing
      final encrypted = _encrypter.encrypt(value, iv: _iv);
      await _storage.write(key: key, value: encrypted.base64);
    } catch (e, stack) {
      AppLogger.error('Error writing to secure storage', e, stack);
      rethrow;
    }
  }

  Future<String?> read(String key) async {
    try {
      final encrypted = await _storage.read(key: key);
      if (encrypted == null) return null;

      // Decrypt value
      final decrypted = _encrypter.decrypt64(encrypted, iv: _iv);
      return decrypted;
    } catch (e, stack) {
      AppLogger.error('Error reading from secure storage', e, stack);
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, stack) {
      AppLogger.error('Error deleting from secure storage', e, stack);
      rethrow;
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, stack) {
      AppLogger.error('Error clearing secure storage', e, stack);
      rethrow;
    }
  }

  Future<Map<String, String>> readAll() async {
    try {
      final all = await _storage.readAll();
      final decrypted = <String, String>{};

      for (final entry in all.entries) {
        if (entry.key == '_encryption_key') continue;
        try {
          decrypted[entry.key] = _encrypter.decrypt64(entry.value, iv: _iv);
        } catch (_) {
          decrypted[entry.key] = entry.value;
        }
      }
      return decrypted;
    } catch (e, stack) {
      AppLogger.error('Error reading all from secure storage', e, stack);
      return {};
    }
  }
}
