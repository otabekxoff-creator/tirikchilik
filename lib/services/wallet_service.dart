import 'dart:async';
import 'dart:convert';

import '../models/wallet_model.dart';
import '../utils/app_logger.dart';
import 'secure_storage_service.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();

  Future<WalletModel> getWallet(String userId) async {
    try {
      final walletData = await _secureStorage.read('wallet_$userId');
      if (walletData != null) {
        return WalletModel.fromJson(jsonDecode(walletData));
      }

      final newWallet = WalletModel(userId: userId);
      await _saveWallet(newWallet);
      return newWallet;
    } catch (e, st) {
      AppLogger.error('Get wallet error', e, st);
      return WalletModel(userId: userId);
    }
  }

  Future<Transaction> addEarnings(
    String userId,
    double amount,
    String description, {
    String? adLevel,
  }) async {
    final wallet = await getWallet(userId);

    final transaction = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: TransactionType.earned,
      description: description,
      date: DateTime.now(),
      adLevel: adLevel,
    );

    wallet.addTransaction(transaction);
    await _saveWallet(wallet);

    return transaction;
  }

  Future<Transaction> addBonus(
    String userId,
    double amount,
    String description,
  ) async {
    final wallet = await getWallet(userId);

    final transaction = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: TransactionType.bonus,
      description: description,
      date: DateTime.now(),
    );

    wallet.addTransaction(transaction);
    await _saveWallet(wallet);

    return transaction;
  }

  Future<bool> withdraw(
    String userId,
    double amount,
    String description,
  ) async {
    final wallet = await getWallet(userId);

    if (wallet.balance < amount) {
      return false;
    }

    final transaction = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: TransactionType.withdrawal,
      description: description,
      date: DateTime.now(),
    );

    wallet.addTransaction(transaction);
    await _saveWallet(wallet);

    return true;
  }

  Future<void> _saveWallet(WalletModel wallet) async {
    await _secureStorage.write(
      'wallet_${wallet.userId}',
      jsonEncode(wallet.toJson()),
    );
  }

  Future<List<Transaction>> getTransactions(String userId) async {
    final wallet = await getWallet(userId);
    return wallet.transactions;
  }

  // Alias for addEarnings to match the naming in app_provider
  Future<Transaction> addEarning(
    String userId,
    double amount,
    String description, {
    String? adLevel,
  }) async {
    return addEarnings(userId, amount, description, adLevel: adLevel);
  }

  Future<List<WalletModel>> getAllWallets() async {
    // Stub implementation - would query backend in real app
    return [];
  }
}
