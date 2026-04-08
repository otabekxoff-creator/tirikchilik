import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../services/ad_storage_service.dart';
import '../models/ad_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final WalletService _walletService = WalletService();
  final AdStorageService _adStorageService = AdStorageService();
  late TabController _tabController;

  List<dynamic> _users = [];
  List<dynamic> _wallets = [];
  List<Map<String, dynamic>> _ads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final users = await _authService.getAllUsers();
    final wallets = await _walletService.getAllWallets();
    final ads = await _adStorageService.getAllAds();
    setState(() {
      _users = users;
      _wallets = wallets;
      _ads = ads;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalUsers = _users.length;
    final totalBalance = _wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final totalEarned = _users.fold<double>(0, (sum, u) => sum + u.totalEarned);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Foydalanuvchilar'),
            Tab(icon: Icon(Icons.videocam), text: 'Reklamalar'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Users Tab
                _buildUsersTab(totalUsers, totalBalance, totalEarned),
                // Ads Tab
                _buildAdsTab(),
              ],
            ),
    );
  }

  Widget _buildUsersTab(
    int totalUsers,
    double totalBalance,
    double totalEarned,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade900],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Foydalanuvchilar',
                      '$totalUsers',
                      Icons.people,
                    ),
                    _buildStatCard(
                      'Jami balans',
                      '\$${totalBalance.toStringAsFixed(2)}',
                      Icons.account_balance_wallet,
                    ),
                    _buildStatCard(
                      'Jami ishlangan',
                      '\$${totalEarned.toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Foydalanuvchilar ro\'yxati',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              final wallet = _wallets.firstWhere(
                (w) => w.userId == user.id,
                orElse: () => null,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isPremium
                        ? Colors.amber
                        : Colors.blue,
                    child: Icon(
                      user.isPremium ? Icons.workspace_premium : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      Text(
                        'Tel: ${user.phone}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\${wallet?.balance.toStringAsFixed(2) ?? "0.00"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${user.totalAdsWatched} reklama',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showUserDetails(context, user, wallet),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reklamalar ro\'yxati (${_ads.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddAdDialog,
                icon: const Icon(Icons.add),
                label: const Text('Yangi reklama'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _ads.isEmpty
              ? _buildEmptyAdsState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ads.length,
                  itemBuilder: (context, index) {
                    final ad = _ads[index];
                    return _buildAdCard(ad);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyAdsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Hali reklamalar yo\'q',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Yangi reklama qo\'shish uchun tugmani bosing',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    final level = AdLevel.values.firstWhere(
      (e) => e.toString() == 'AdLevel.${ad['level']}',
      orElse: () => AdLevel.oddiy,
    );
    final isActive = ad['isActive'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: level.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(level.icon, color: level.color),
        ),
        title: Text(
          ad['title'] ?? 'Nomsiz reklama',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(ad['description'] ?? 'Tavsif yo\'q'),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: level.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    level.label,
                    style: TextStyle(
                      color: level.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${ad['durationSeconds'] ?? 30}s',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(Icons.attach_money, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '\$${ad['reward']?.toStringAsFixed(2) ?? level.reward.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: isActive,
              onChanged: (value) => _toggleAdStatus(ad['id']),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditAdDialog(ad),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _deleteAd(ad['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAdStatus(String adId) async {
    await _adStorageService.toggleAdStatus(adId);
    _loadData();
  }

  Future<void> _deleteAd(String adId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reklamani o\'chirish'),
        content: const Text('Bu reklamani o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'O\'chirish',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _adStorageService.deleteAd(adId);
      _loadData();
    }
  }

  void _showAddAdDialog() {
    _showAdDialog();
  }

  void _showEditAdDialog(Map<String, dynamic> ad) {
    _showAdDialog(ad: ad);
  }

  void _showAdDialog({Map<String, dynamic>? ad}) {
    final isEditing = ad != null;
    final titleController = TextEditingController(text: ad?['title'] ?? '');
    final descriptionController = TextEditingController(
      text: ad?['description'] ?? '',
    );
    final durationController = TextEditingController(
      text: (ad?['durationSeconds'] ?? 30).toString(),
    );
    final rewardController = TextEditingController(
      text: (ad?['reward'] ?? 0.10).toString(),
    );
    final imageUrlController = TextEditingController(
      text: ad?['imageUrl'] ?? '',
    );

    AdLevel selectedLevel = AdLevel.values.firstWhere(
      (e) => e.toString() == 'AdLevel.${ad?['level']}',
      orElse: () => AdLevel.oddiy,
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Reklamani tahrirlash' : 'Yangi reklama'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Sarlavha *',
                      hintText: 'Masalan: Samsung Galaxy S24',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Tavsif',
                      hintText: 'Reklama haqida qisqacha ma\'lumot',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AdLevel>(
                    initialValue: selectedLevel,
                    decoration: const InputDecoration(labelText: 'Daraja'),
                    items: AdLevel.values.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Row(
                          children: [
                            Icon(level.icon, color: level.color, size: 20),
                            const SizedBox(width: 8),
                            Text(level.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedLevel = value;
                          rewardController.text = value.reward.toStringAsFixed(
                            2,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Davomiyligi (sekund)',
                      suffixText: 's',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: rewardController,
                    decoration: const InputDecoration(
                      labelText: 'Mukofot (\$)',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Rasm URL (ixtiyoriy)',
                      hintText: 'https://example.com/image.jpg',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Bekor qilish'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sarlavha kiritilishi shart!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final adData = {
                    'id':
                        ad?['id'] ??
                        'ad_${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'level': selectedLevel.toString().split('.').last,
                    'durationSeconds':
                        int.tryParse(durationController.text) ?? 30,
                    'reward':
                        double.tryParse(rewardController.text) ??
                        selectedLevel.reward,
                    'imageUrl': imageUrlController.text.trim().isEmpty
                        ? null
                        : imageUrlController.text.trim(),
                    'isActive': ad?['isActive'] ?? true,
                    'createdAt':
                        ad?['createdAt'] ?? DateTime.now().toIso8601String(),
                  };

                  await _adStorageService.saveAd(adData);
                  Navigator.pop(context);
                  _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Reklama yangilandi!'
                            : 'Reklama qo\'shildi!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text(isEditing ? 'Saqlash' : 'Qo\'shish'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, dynamic user, dynamic wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email:', user.email),
            _buildDetailRow('Telefon:', user.phone),
            _buildDetailRow(
              'Balans:',
              '\${wallet?.balance.toStringAsFixed(2) ?? "0.00"}',
            ),
            _buildDetailRow('Reklamalar:', '${user.totalAdsWatched} ta'),
            _buildDetailRow(
              'Jami ishlangan:',
              '\${user.totalEarned.toStringAsFixed(2)}',
            ),
            _buildDetailRow('Premium:', user.isPremium ? 'Ha' : 'Yo\'q'),
            if (user.isPremium)
              _buildDetailRow(
                'Muddati:',
                DateFormat('dd.MM.yyyy').format(user.premiumExpiry),
              ),
            _buildDetailRow(
              'Ro\'yxatdan o\'tgan:',
              DateFormat('dd.MM.yyyy').format(user.createdAt),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
