import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/wallet_model.dart';
import '../theme/ios_theme.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appProviderProvider);
    final wallet = provider.wallet;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? IOSTheme.darkSystemGroupedBackground
          : IOSTheme.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          // iOS Large Navigation Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            backgroundColor: isDark
                ? IOSTheme.darkSystemGroupedBackground
                : IOSTheme.systemGroupedBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? IOSTheme.darkLabel : IOSTheme.systemBlue,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Hamyon',
              style: IOSTheme.headline.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
              ),
            ),
            centerTitle: true,
          ),
          // Balance Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: IOSTheme.blueGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: IOSTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'Jami balans',
                      style: IOSTheme.subhead.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${wallet?.balance.toStringAsFixed(0) ?? "0"} so\'m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIOSActionButton(
                          icon: Icons.add,
                          label: 'To\'ldirish',
                          color: IOSTheme.systemGreen,
                          onTap: () => _showDepositDialog(context),
                        ),
                        _buildIOSActionButton(
                          icon: Icons.arrow_downward,
                          label: 'Yechish',
                          color: IOSTheme.systemOrange,
                          onTap: () => _showWithdrawDialog(context, ref),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Transactions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tranzaksiyalar',
                    style: IOSTheme.headline.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: IOSTheme.systemBlue,
                    ),
                    child: Text(
                      'Barchasi',
                      style: IOSTheme.body.copyWith(
                        color: isDark
                            ? IOSTheme.systemCyan
                            : IOSTheme.systemBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Transaction List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (wallet?.transactions.isEmpty ?? true) {
                  return _buildEmptyState(isDark);
                }
                final tx = wallet!.transactions[index];
                return _buildIOSTransactionItem(tx, isDark);
              },
              childCount: wallet?.transactions.isEmpty ?? true
                  ? 1
                  : wallet!.transactions.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildIOSActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: IOSTheme.subhead.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? IOSTheme.darkSecondarySystemBackground
            : IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? IOSTheme.darkTertiarySystemBackground
                  : IOSTheme.systemGray6,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hali tranzaksiyalar yo\'q',
            style: IOSTheme.subhead.copyWith(
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSTransactionItem(Transaction tx, bool isDark) {
    final isPositive =
        tx.type == TransactionType.earned || tx.type == TransactionType.bonus;
    final color = isPositive ? IOSTheme.systemGreen : IOSTheme.systemRed;
    final icon = _getTransactionIcon(tx.type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? IOSTheme.darkSecondarySystemBackground
            : IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          tx.description,
          style: IOSTheme.body.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
          ),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy HH:mm').format(tx.date),
          style: IOSTheme.footnote.copyWith(
            color: isDark
                ? IOSTheme.darkSecondaryLabel
                : IOSTheme.secondaryLabel,
          ),
        ),
        trailing: Text(
          '${isPositive ? '+' : '-'}${tx.amount.toStringAsFixed(0)}',
          style: IOSTheme.body.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.earned:
        return Icons.play_circle_outline;
      case TransactionType.bonus:
        return Icons.card_giftcard;
      case TransactionType.withdrawal:
        return Icons.arrow_downward;
      case TransactionType.premium:
        return Icons.workspace_premium;
    }
  }

  void _showDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Balansni to\'ldirish',
          style: IOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bu funksiya tez orada qo\'shiladi.',
          style: IOSTheme.body.copyWith(color: IOSTheme.secondaryLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: IOSTheme.systemBlue),
            child: Text(
              'OK',
              style: IOSTheme.body.copyWith(
                color: IOSTheme.systemBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    String selectedMethod = 'Payme';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Pul yechish',
            style: IOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: IOSTheme.body,
                  decoration: InputDecoration(
                    labelText: 'Summa',
                    labelStyle: IOSTheme.subhead.copyWith(
                      color: IOSTheme.secondaryLabel,
                    ),
                    prefixText: 'so\'m ',
                    prefixStyle: IOSTheme.body.copyWith(
                      color: IOSTheme.systemBlue,
                    ),
                    filled: true,
                    fillColor: IOSTheme.systemBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: IOSTheme.systemBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: IOSTheme.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    decoration: InputDecoration(
                      labelText: 'To\'lov turi',
                      labelStyle: IOSTheme.subhead.copyWith(
                        color: IOSTheme.secondaryLabel,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: IOSTheme.body,
                    items: ['Payme', 'Click', 'UzCard', 'Humo']
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(method, style: IOSTheme.body),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedMethod = value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: IOSTheme.systemRed),
              child: Text(
                'Bekor',
                style: IOSTheme.body.copyWith(color: IOSTheme.systemRed),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Noto\'g\'ri summa',
                        style: IOSTheme.subhead.copyWith(color: Colors.white),
                      ),
                      backgroundColor: IOSTheme.systemRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }
                final success = await ref
                    .read(appProviderProvider.notifier)
                    .withdraw(amount, selectedMethod);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Pul muvaffaqiyatli yechildi'
                          : 'Balans yetarli emas',
                      style: IOSTheme.subhead.copyWith(color: Colors.white),
                    ),
                    backgroundColor: success
                        ? IOSTheme.systemGreen
                        : IOSTheme.systemRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: IOSTheme.systemBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Yechish',
                style: IOSTheme.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
