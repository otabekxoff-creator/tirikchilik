import 'package:flutter_test/flutter_test.dart';
import 'package:tirikchilik/services/wallet_service.dart';
import 'package:tirikchilik/models/wallet_model.dart';

void main() {
  group('WalletService Tests', () {
    late WalletService walletService;
    const testUserId = 'test-user-123';

    setUp(() {
      walletService = WalletService();
    });

    group('Wallet Creation', () {
      test('should create new wallet with zero balance', () async {
        final wallet = await walletService.getWallet(testUserId);

        expect(wallet, isNotNull);
        expect(wallet.balance, equals(0.0));
        expect(wallet.pendingBalance, equals(0.0));
        expect(wallet.transactions, isEmpty);
      });

      test('should return existing wallet if already created', () async {
        final wallet1 = await walletService.getWallet(testUserId);
        final wallet2 = await walletService.getWallet(testUserId);

        expect(wallet1.userId, equals(wallet2.userId));
      });
    });

    group('Add Earnings', () {
      test('should add earnings to balance', () async {
        await walletService.addEarning(testUserId, 10.0, 'Test earning');
        final wallet = await walletService.getWallet(testUserId);

        expect(wallet.balance, equals(10.0));
        expect(wallet.transactions.length, equals(1));
      });

      test('should accumulate multiple earnings', () async {
        await walletService.addEarning(testUserId, 5.0, 'First earning');
        await walletService.addEarning(testUserId, 7.0, 'Second earning');
        final wallet = await walletService.getWallet(testUserId);

        expect(wallet.balance, equals(12.0));
        expect(wallet.transactions.length, equals(2));
      });

      test('should record transaction details correctly', () async {
        const amount = 15.0;
        const description = 'Ad view reward';

        await walletService.addEarning(testUserId, amount, description);
        final wallet = await walletService.getWallet(testUserId);
        final transaction = wallet.transactions.first;

        expect(transaction.amount, equals(amount));
        expect(transaction.description, equals(description));
        expect(transaction.type, equals(TransactionType.earned));
        expect(transaction.date, isNotNull);
      });
    });

    group('Withdrawals', () {
      test('should process valid withdrawal', () async {
        await walletService.addEarning(testUserId, 100.0, 'Initial balance');
        final success = await walletService.withdraw(
          testUserId,
          50.0,
          'Card withdrawal',
        );
        final wallet = await walletService.getWallet(testUserId);

        expect(success, isTrue);
        expect(wallet.balance, equals(50.0));
        expect(wallet.transactions.length, equals(2));
      });

      test('should reject withdrawal exceeding balance', () async {
        await walletService.addEarning(testUserId, 10.0, 'Low balance');
        final success = await walletService.withdraw(
          testUserId,
          50.0,
          'Too much',
        );
        final wallet = await walletService.getWallet(testUserId);

        expect(success, isFalse);
        expect(wallet.balance, equals(10.0));
      });

      test('should create withdrawal transaction', () async {
        await walletService.addEarning(testUserId, 100.0, 'Balance');
        await walletService.withdraw(testUserId, 50.0, 'Withdrawal');
        final wallet = await walletService.getWallet(testUserId);
        final withdrawal = wallet.transactions.firstWhere(
          (t) => t.type == TransactionType.withdrawal,
        );

        expect(withdrawal.amount, equals(50.0));
        expect(withdrawal.description, equals('Withdrawal'));
      });
    });

    group('Bonus System', () {
      test('should add bonus correctly', () async {
        await walletService.addBonus(testUserId, 5.0, 'Referral bonus');
        final wallet = await walletService.getWallet(testUserId);

        expect(wallet.balance, equals(5.0));
        expect(wallet.transactions.first.type, equals(TransactionType.bonus));
      });

      test('should add premium bonus using addBonus', () async {
        await walletService.addBonus(
          testUserId,
          10.0,
          'Premium subscription bonus',
        );
        final wallet = await walletService.getWallet(testUserId);

        expect(wallet.balance, equals(10.0));
        expect(wallet.transactions.first.description, contains('Premium'));
      });
    });

    group('Transaction Types', () {
      test('should have correct transaction types', () {
        expect(TransactionType.values, contains(TransactionType.earned));
        expect(TransactionType.values, contains(TransactionType.withdrawal));
        expect(TransactionType.values, contains(TransactionType.bonus));
        expect(TransactionType.values, contains(TransactionType.premium));
      });
    });

    group('All Wallets', () {
      test('getAllWallets should return list', () async {
        final wallets = await walletService.getAllWallets();
        expect(wallets, isA<List<WalletModel>>());
      });
    });
  });
}
