class WalletModel {
  final String userId;
  double balance;
  double pendingBalance;
  List<Transaction> transactions;

  WalletModel({
    required this.userId,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
    this.transactions = const [],
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0.0).toDouble(),
      transactions:
          (json['transactions'] as List?)
              ?.map((e) => Transaction.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'pendingBalance': pendingBalance,
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  void addTransaction(Transaction transaction) {
    transactions = [transaction, ...transactions];
    if (transaction.type == TransactionType.earned) {
      balance += transaction.amount;
    } else if (transaction.type == TransactionType.withdrawal) {
      balance -= transaction.amount;
    }
  }
}

enum TransactionType { earned, withdrawal, bonus, premium }

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime date;
  final String? adLevel;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.adLevel,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.earned,
      ),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      adLevel: json['adLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
      'date': date.toIso8601String(),
      'adLevel': adLevel,
    };
  }
}
