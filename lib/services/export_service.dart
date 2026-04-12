import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../utils/app_logger.dart';
import 'wallet_service.dart';

enum ExportFormat { csv, json, pdf }

class ExportData {
  final DateTime from;
  final DateTime to;
  final List<Transaction> transactions;
  final double totalEarnings;
  final double totalWithdrawals;
  final int totalAds;

  ExportData({
    required this.from,
    required this.to,
    required this.transactions,
    required this.totalEarnings,
    required this.totalWithdrawals,
    required this.totalAds,
  });
}

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final _walletService = WalletService();

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<String?> exportData(
    String userId,
    ExportFormat format,
    DateTime from,
    DateTime to,
  ) async {
    try {
      // Get data
      final data = await _getExportData(userId, from, to);

      // Generate file
      String? filePath;
      switch (format) {
        case ExportFormat.csv:
          filePath = await _exportToCsv(userId, data);
          break;
        case ExportFormat.json:
          filePath = await _exportToJson(userId, data);
          break;
        case ExportFormat.pdf:
          filePath = await _exportToPdf(userId, data);
          break;
      }

      if (filePath != null) {
        AppLogger.info('Data exported: $filePath');
      }

      return filePath;
    } catch (e, stack) {
      AppLogger.error('Export failed', e, stack);
      return null;
    }
  }

  Future<ExportData> _getExportData(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    final wallet = await _walletService.getWallet(userId);

    // Filter transactions by date
    final filteredTransactions = wallet.transactions.where((t) {
      return t.date.isAfter(from.subtract(const Duration(days: 1))) &&
          t.date.isBefore(to.add(const Duration(days: 1)));
    }).toList();

    final earnings = filteredTransactions
        .where(
          (t) =>
              t.type == TransactionType.earned ||
              t.type == TransactionType.bonus,
        )
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final withdrawals = filteredTransactions
        .where((t) => t.type == TransactionType.withdrawal)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final ads = filteredTransactions
        .where((t) => t.type == TransactionType.earned && t.adLevel != null)
        .length;

    return ExportData(
      from: from,
      to: to,
      transactions: filteredTransactions,
      totalEarnings: earnings,
      totalWithdrawals: withdrawals,
      totalAds: ads,
    );
  }

  Future<String?> _exportToCsv(String userId, ExportData data) async {
    await _requestStoragePermission();

    // Build CSV rows
    final rows = <List<String>>[];

    // Header
    rows.add(['Tirikchilik - Tranzaksiyalar hisoboti']);
    rows.add(['Davr:', '${_formatDate(data.from)} - ${_formatDate(data.to)}']);
    rows.add([]);
    rows.add(['Sana', 'Turi', 'Summa', 'Tavsif']);

    // Data rows
    for (final t in data.transactions) {
      rows.add([
        _formatDateTime(t.date),
        _transactionTypeToString(t.type),
        t.amount.toStringAsFixed(2),
        t.description,
      ]);
    }

    // Summary
    rows.add([]);
    rows.add(['Jami:', '', data.totalEarnings.toStringAsFixed(2), '']);

    // Convert to CSV
    final csv = const ListToCsvConverter().convert(rows);

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'tirikchilik_${userId}_${_formatDate(DateTime.now())}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);

    return file.path;
  }

  Future<String?> _exportToJson(String userId, ExportData data) async {
    final jsonData = {
      'exportDate': DateTime.now().toIso8601String(),
      'period': {
        'from': data.from.toIso8601String(),
        'to': data.to.toIso8601String(),
      },
      'summary': {
        'totalEarnings': data.totalEarnings,
        'totalWithdrawals': data.totalWithdrawals,
        'totalAds': data.totalAds,
        'transactionCount': data.transactions.length,
      },
      'transactions': data.transactions
          .map(
            (t) => {
              'id': t.id,
              'date': t.date.toIso8601String(),
              'type': t.type.toString(),
              'amount': t.amount,
              'description': t.description,
              'adLevel': t.adLevel,
            },
          )
          .toList(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'tirikchilik_${userId}_${_formatDate(DateTime.now())}.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonEncode(jsonData));

    return file.path;
  }

  Future<String?> _exportToPdf(String userId, ExportData data) async {
    // For PDF export, we would typically use a package like pdf: ^3.10.0
    // For now, we'll create a simple text file as a placeholder

    final buffer = StringBuffer();
    buffer.writeln('TIRIKCHILIK - TRANZAKSIYALAR HISOBOTI');
    buffer.writeln('=====================================');
    buffer.writeln();
    buffer.writeln('Davr: ${_formatDate(data.from)} - ${_formatDate(data.to)}');
    buffer.writeln('Eksport qilingan: ${_formatDateTime(DateTime.now())}');
    buffer.writeln();
    buffer.writeln('-------------------------------------');
    buffer.writeln();
    buffer.writeln('JAMI MA\'LUMOTLAR:');
    buffer.writeln('  Daromad: ${data.totalEarnings.toStringAsFixed(2)} so\'m');
    buffer.writeln(
      '  Yechib olish: ${data.totalWithdrawals.toStringAsFixed(2)} so\'m',
    );
    buffer.writeln('  Reklamalar: ${data.totalAds} ta');
    buffer.writeln();
    buffer.writeln('-------------------------------------');
    buffer.writeln();
    buffer.writeln('TRANZAKSIYALAR:');
    buffer.writeln();

    for (final t in data.transactions) {
      buffer.writeln('${_formatDateTime(t.date)}');
      buffer.writeln('  Turi: ${_transactionTypeToString(t.type)}');
      buffer.writeln('  Summa: ${t.amount.toStringAsFixed(2)} so\'m');
      buffer.writeln('  Tavsif: ${t.description}');
      buffer.writeln();
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'tirikchilik_${userId}_${_formatDate(DateTime.now())}.txt';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  Future<void> shareExportedFile(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Tirikchilik hisoboti',
      text: 'Tranzaksiyalar hisoboti',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.earned:
        return 'Daromad';
      case TransactionType.withdrawal:
        return 'Yechib olish';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.premium:
        return 'Premium';
    }
  }

  Future<List<ExportFormat>> getAvailableFormats() async {
    return [ExportFormat.csv, ExportFormat.json, ExportFormat.pdf];
  }

  Future<String> getExportSummary(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    final data = await _getExportData(userId, from, to);

    return '''
Hisobot davri: ${_formatDate(from)} - ${_formatDate(to)}

Jami tranzaksiyalar: ${data.transactions.length}
Jami daromad: ${data.totalEarnings.toStringAsFixed(2)} so'm
Jami yechib olish: ${data.totalWithdrawals.toStringAsFixed(2)} so'm
Ko'rilgan reklamalar: ${data.totalAds} ta
'''
        .trim();
  }
}
