import 'dart:convert';
import '../models/wallet_model.dart';
import 'shared_preferences_service.dart';
import '../constants/app_constants.dart';

class WalletService {
  static const String _walletsKey = AppConstants.walletsKey;

  Future<WalletModel> getWallet(String userId) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final walletsJson = prefs.getString(_walletsKey);
    if (walletsJson == null) {
      final newWallet = WalletModel(userId: userId);
      await _saveWallet(newWallet);
      return newWallet;
    }

    final wallets = (jsonDecode(walletsJson) as List)
        .map((e) => WalletModel.fromJson(e))
        .toList();
    final wallet = wallets.firstWhere(
      (w) => w.userId == userId,
      orElse: () => WalletModel(userId: userId),
    );
    return wallet;
  }

  Future<void> _saveWallet(WalletModel wallet) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final walletsJson = prefs.getString(_walletsKey);
    final wallets = walletsJson != null
        ? (jsonDecode(walletsJson) as List)
              .map((e) => WalletModel.fromJson(e))
              .toList()
        : <WalletModel>[];

    final index = wallets.indexWhere((w) => w.userId == wallet.userId);
    if (index != -1) {
      wallets[index] = wallet;
    } else {
      wallets.add(wallet);
    }

    await prefs.setString(
      _walletsKey,
      jsonEncode(wallets.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addEarning(
    String userId,
    double amount,
    String description, {
    String? adLevel,
  }) async {
    final wallet = await getWallet(userId);
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: TransactionType.earned,
      description: description,
      date: DateTime.now(),
      adLevel: adLevel,
    );
    wallet.addTransaction(transaction);
    await _saveWallet(wallet);
  }

  Future<void> addBonus(
    String userId,
    double amount,
    String description,
  ) async {
    final wallet = await getWallet(userId);
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: TransactionType.bonus,
      description: description,
      date: DateTime.now(),
    );
    wallet.addTransaction(transaction);
    await _saveWallet(wallet);
  }

  Future<bool> withdraw(
    String userId,
    double amount,
    String description,
  ) async {
    final wallet = await getWallet(userId);
    if (wallet.balance < amount) return false;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: TransactionType.withdrawal,
      description: description,
      date: DateTime.now(),
    );
    wallet.addTransaction(transaction);
    await _saveWallet(wallet);
    return true;
  }

  Future<List<WalletModel>> getAllWallets() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final walletsJson = prefs.getString(_walletsKey);
    if (walletsJson == null) return [];
    return (jsonDecode(walletsJson) as List)
        .map((e) => WalletModel.fromJson(e))
        .toList();
  }
}
