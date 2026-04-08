import 'dart:async';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart' as models;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static sql.Database? _database;

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async {
    final databasesPath = await sql.getDatabasesPath();
    final path = join(databasesPath, 'tirikchilik.db');

    return await sql.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(sql.Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL UNIQUE,
        passwordHash TEXT,
        isAdmin INTEGER NOT NULL DEFAULT 0,
        isPremium INTEGER NOT NULL DEFAULT 0,
        premiumExpiry TEXT,
        totalAdsWatched INTEGER NOT NULL DEFAULT 0,
        totalEarned REAL NOT NULL DEFAULT 0.0,
        dailyAdsWatched INTEGER NOT NULL DEFAULT 0,
        lastAdWatchDate TEXT,
        referralCode TEXT,
        referredBy TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Wallets table
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0.0,
        pendingBalance REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        status TEXT NOT NULL DEFAULT 'completed',
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Custom Ads table
    await db.execute('''
      CREATE TABLE custom_ads (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        level TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL DEFAULT 30,
        reward REAL NOT NULL DEFAULT 0.10,
        imageUrl TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Salt storage for password hashing
    await db.execute('''
      CREATE TABLE password_salts (
        userId TEXT PRIMARY KEY,
        salt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Migration logic
    }
  }

  // ==================== USER CRUD ====================

  Future<String> insertUser(UserModel user) async {
    final db = await database;
    await db.insert('users', _userToMap(user));
    return user.id;
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByPhone(String phone) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByReferralCode(String referralCode) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'referralCode = ?',
      whereArgs: [referralCode],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'createdAt DESC');
    return maps.map((map) => _mapToUser(map)).toList();
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      _userToMap(user),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== SALT CRUD ====================

  Future<void> saveSalt(String userId, String salt) async {
    final db = await database;
    await db.insert('password_salts', {
      'userId': userId,
      'salt': salt,
    }, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  Future<String?> getSalt(String userId) async {
    final db = await database;
    final maps = await db.query(
      'password_salts',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['salt'] as String?;
    }
    return null;
  }

  // ==================== CUSTOM ADS CRUD ====================

  Future<String> insertCustomAd(Map<String, dynamic> ad) async {
    final db = await database;
    await db.insert('custom_ads', ad);
    return ad['id'];
  }

  Future<int> updateCustomAd(Map<String, dynamic> ad) async {
    final db = await database;
    return await db.update(
      'custom_ads',
      ad,
      where: 'id = ?',
      whereArgs: [ad['id']],
    );
  }

  Future<int> deleteCustomAd(String id) async {
    final db = await database;
    return await db.delete('custom_ads', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllCustomAds() async {
    final db = await database;
    return await db.query('custom_ads', orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getActiveCustomAds() async {
    final db = await database;
    return await db.query(
      'custom_ads',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getCustomAdsByLevel(String level) async {
    final db = await database;
    return await db.query(
      'custom_ads',
      where: 'level = ? AND isActive = ?',
      whereArgs: [level, 1],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> toggleCustomAdStatus(String id, bool isActive) async {
    final db = await database;
    return await db.update(
      'custom_ads',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== WALLET CRUD ====================

  Future<void> createWallet(String userId) async {
    final db = await database;
    await db.insert('wallets', {
      'userId': userId,
      'balance': 0.0,
      'pendingBalance': 0.0,
    });
  }

  Future<WalletModel?> getWallet(String userId) async {
    final db = await database;
    final maps = await db.query(
      'wallets',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final map = maps.first;
      // Get transactions
      final transMaps = await db.query(
        'transactions',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
      final transactions = transMaps
          .map(
            (t) => Transaction(
              id: t['id'] as int,
              type: t['type'] as String,
              amount: t['amount'] as double,
              description: t['description'] as String?,
              date: DateTime.parse(t['createdAt'] as String),
              status: t['status'] as String,
            ),
          )
          .toList();

      return WalletModel(
        id: map['id'] as int,
        userId: map['userId'] as String,
        balance: map['balance'] as double,
        pendingBalance: map['pendingBalance'] as double,
        transactions: transactions,
      );
    }
    return null;
  }

  Future<int> updateWalletBalance(String userId, double balance) async {
    final db = await database;
    return await db.update(
      'wallets',
      {'balance': balance},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> addTransaction(String userId, Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', {
      'userId': userId,
      'type': transaction.type,
      'amount': transaction.amount,
      'description': transaction.description,
      'status': transaction.status,
      'createdAt': transaction.date.toIso8601String(),
    });
  }

  Future<List<WalletModel>> getAllWallets() async {
    final db = await database;
    final maps = await db.query('wallets');
    final wallets = <WalletModel>[];
    for (final map in maps) {
      final wallet = await getWallet(map['userId'] as String);
      if (wallet != null) {
        wallets.add(wallet);
      }
    }
    return wallets;
  }

  // ==================== HELPERS ====================

  Map<String, dynamic> _userToMap(UserModel user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'passwordHash': user.passwordHash,
      'isAdmin': user.isAdmin ? 1 : 0,
      'isPremium': user.isPremium ? 1 : 0,
      'premiumExpiry': user.premiumExpiry?.toIso8601String(),
      'totalAdsWatched': user.totalAdsWatched,
      'totalEarned': user.totalEarned,
      'dailyAdsWatched': user.dailyAdsWatched,
      'lastAdWatchDate': user.lastAdWatchDate?.toIso8601String(),
      'referralCode': user.referralCode,
      'referredBy': user.referredBy,
      'createdAt': user.createdAt.toIso8601String(),
    };
  }

  UserModel _mapToUser(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      passwordHash: map['passwordHash'] as String?,
      isAdmin: (map['isAdmin'] as int) == 1,
      isPremium: (map['isPremium'] as int) == 1,
      premiumExpiry: map['premiumExpiry'] != null
          ? DateTime.parse(map['premiumExpiry'] as String)
          : null,
      totalAdsWatched: map['totalAdsWatched'] as int,
      totalEarned: map['totalEarned'] as double,
      dailyAdsWatched: map['dailyAdsWatched'] as int,
      lastAdWatchDate: map['lastAdWatchDate'] != null
          ? DateTime.parse(map['lastAdWatchDate'] as String)
          : null,
      referralCode: map['referralCode'] as String?,
      referredBy: map['referredBy'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // ==================== MIGRATION FROM SHARED PREFS ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('wallets');
    await db.delete('password_salts');
    await db.delete('custom_ads');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
