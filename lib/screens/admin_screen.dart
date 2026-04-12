import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../services/ad_storage_service.dart';
import '../models/ad_model.dart';
import '../models/enums.dart';
import '../theme/ios_theme.dart';
import '../utils/admin_stats_helper.dart';
import '../utils/pagination_helper.dart';
import '../constants/app_constants.dart';

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
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  List<dynamic> _wallets = [];
  List<Map<String, dynamic>> _ads = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  UserSortOption _sortOption = UserSortOption.newest;

  // Pagination
  final int _usersPerPage = AppConstants.usersPerPage;
  int _currentPage = 0;
  late List<dynamic> _paginatedUsers;
  bool _hasMoreUsers = false;

  // Selection for bulk actions
  final Set<String> _selectedUserIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      HapticFeedback.mediumImpact();
      final users = await _authService.getAllUsers();
      final wallets = await _walletService.getAllWallets();
      final ads = await _adStorageService.getAllAds();

      setState(() {
        _allUsers = users;
        _wallets = wallets;
        _ads = ads;
        _isLoading = false;
        _applyFiltersAndSort();
      });
    } catch (e) {
      setState(() {
        _error = 'Ma\'lumotlarni yuklashda xatolik: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    var users = [..._allUsers];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      users = users.where((user) {
        final name = (user.name ?? '').toLowerCase();
        final email = (user.email ?? '').toLowerCase();
        final phone = (user.phone ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query);
      }).toList();
    }

    // Apply sort
    switch (_sortOption) {
      case UserSortOption.newest:
        users.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;
      case UserSortOption.name:
        users.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case UserSortOption.earned:
        users.sort((a, b) {
          final earnedA = a.totalEarned ?? 0;
          final earnedB = b.totalEarned ?? 0;
          return earnedB.compareTo(earnedA);
        });
        break;
      case UserSortOption.adsWatched:
        users.sort((a, b) {
          final adsA = a.totalAdsWatched ?? 0;
          final adsB = b.totalAdsWatched ?? 0;
          return adsB.compareTo(adsA);
        });
        break;
    }

    // Apply pagination
    _currentPage = 0;
    _filteredUsers = users;
    _updatePaginatedUsers(users);
  }

  void _updatePaginatedUsers(List<dynamic> users) {
    _paginatedUsers = PaginationHelper.getPaginatedItems(
      users,
      _currentPage,
      _usersPerPage,
    );
    _hasMoreUsers = PaginationHelper.hasMoreItems(
      users,
      _currentPage,
      _usersPerPage,
    );
  }

  void _loadMoreUsers() {
    _currentPage++;
    _updatePaginatedUsers(_filteredUsers);
    setState(() {});
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
      if (_selectedUserIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedUserIds.clear();
      }
    });
  }

  // MARK: - Build UI

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = AdminStatsHelper.calculateStats(_allUsers, _wallets);
    final totalUsers = stats['totalUsers'];
    final totalBalance = stats['totalBalance'];
    final totalEarned = stats['totalEarned'];
    final premiumUsers = stats['premiumUsers'];
    final activeUsers = stats['activeUsers'];

    return Scaffold(
      backgroundColor: isDark
          ? IOSTheme.darkSystemGroupedBackground
          : IOSTheme.systemGroupedBackground,
      appBar: AppBar(
        title: Text(
          'Admin Panel',
          style: IOSTheme.headline.copyWith(
            color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
          ),
        ),
        backgroundColor: isDark
            ? IOSTheme.darkTertiarySystemBackground
            : IOSTheme.systemBackground,
        foregroundColor: isDark ? IOSTheme.darkLabel : IOSTheme.label,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSelectionMode
                  ? Icons.checklist_rounded
                  : Icons.select_all_rounded,
            ),
            onPressed: _toggleSelectionMode,
            tooltip: _isSelectionMode
                ? 'Tanlashni bekor qilish'
                : 'Ko\'p tanlash',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Yangilash',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? IOSTheme.darkSecondarySystemGroupedBackground
                  : IOSTheme.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(IOSTheme.radius12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(IOSTheme.radius10),
                boxShadow: IOSTheme.smallShadow,
                gradient: const LinearGradient(
                  colors: [IOSTheme.systemRed, IOSTheme.systemPink],
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              labelStyle: IOSTheme.headline,
              unselectedLabelColor: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
              unselectedLabelStyle: IOSTheme.footnote,
              tabs: const [
                Tab(icon: Icon(Icons.people_rounded), text: 'Foydalanuvchilar'),
                Tab(icon: Icon(Icons.videocam_rounded), text: 'Reklamalar'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Ma\'lumotlar yuklanmoqda...',
                    style: IOSTheme.subhead.copyWith(
                      color: isDark
                          ? IOSTheme.darkSecondaryLabel
                          : IOSTheme.secondaryLabel,
                    ),
                  ),
                ],
              ),
            )
          : _error.isNotEmpty
          ? _buildErrorState(isDark)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(
                  isDark,
                  totalUsers,
                  totalBalance,
                  totalEarned,
                  premiumUsers,
                  activeUsers,
                ),
                _buildAdsTab(isDark),
              ],
            ),
      floatingActionButton: _isSelectionMode && _selectedUserIds.isNotEmpty
          ? _buildBulkActionsButton(isDark)
          : null,
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: IOSTheme.systemRed.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: IOSTheme.systemRed,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Xatolik yuz berdi',
            style: IOSTheme.title2.copyWith(
              color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error,
              style: IOSTheme.subhead.copyWith(
                color: isDark
                    ? IOSTheme.darkSecondaryLabel
                    : IOSTheme.secondaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Qayta urinish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: IOSTheme.systemBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(IOSTheme.radius12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(
    bool isDark,
    int totalUsers,
    double totalBalance,
    double totalEarned,
    int premiumUsers,
    int activeUsers,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Stats Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      icon: Icons.people_rounded,
                      value: '$totalUsers',
                      label: 'Jami foyd.',
                      color: IOSTheme.systemBlue,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      icon: Icons.check_circle_rounded,
                      value: '$activeUsers',
                      label: 'Faol',
                      color: IOSTheme.systemGreen,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      icon: Icons.workspace_premium_rounded,
                      value: '$premiumUsers',
                      label: 'Premium',
                      color: IOSTheme.systemYellow,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      icon: Icons.attach_money_rounded,
                      value: totalEarned.toStringAsFixed(0),
                      label: 'Jami ishlangan',
                      color: IOSTheme.systemPurple,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? IOSTheme.darkSecondarySystemGroupedBackground
                        : IOSTheme.systemBackground,
                    borderRadius: BorderRadius.circular(IOSTheme.radius12),
                    boxShadow: IOSTheme.smallShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Foydalanuvchi qidirish...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark
                            ? IOSTheme.darkSecondaryLabel
                            : IOSTheme.secondaryLabel,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _applyFiltersAndSort();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _applyFiltersAndSort();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Sort & Filter Bar
                Row(
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      color: isDark
                          ? IOSTheme.darkSecondaryLabel
                          : IOSTheme.secondaryLabel,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saralash:',
                      style: IOSTheme.footnote.copyWith(
                        color: isDark
                            ? IOSTheme.darkSecondaryLabel
                            : IOSTheme.secondaryLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: UserSortOption.values.map((option) {
                            final isSelected = _sortOption == option;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(
                                  option.label,
                                  style: IOSTheme.caption1.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                              ? IOSTheme.darkSecondaryLabel
                                              : IOSTheme.secondaryLabel),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                backgroundColor: isSelected
                                    ? IOSTheme.systemBlue
                                    : (isDark
                                          ? IOSTheme
                                                .darkTertiarySystemBackground
                                          : IOSTheme.systemGray6),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _sortOption = option);
                                  _applyFiltersAndSort();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Foydalanuvchilar (${_filteredUsers.length})',
                      style: IOSTheme.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                      ),
                    ),
                    if (_hasMoreUsers)
                      TextButton.icon(
                        onPressed: _loadMoreUsers,
                        icon: const Icon(Icons.expand_more_rounded),
                        label: Text(
                          'Ko\'proq',
                          style: IOSTheme.footnote.copyWith(
                            color: IOSTheme.systemBlue,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        // Users List
        _paginatedUsers.isEmpty
            ? SliverFillRemaining(child: _buildEmptyUsersState(isDark))
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final user = _paginatedUsers[index];
                  final wallet = _wallets.firstWhere(
                    (w) => w.userId == user.id,
                    orElse: () => null,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildUserCard(user, wallet, isDark),
                  );
                }, childCount: _paginatedUsers.length),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? IOSTheme.darkSecondarySystemGroupedBackground
            : IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(IOSTheme.radius16),
        boxShadow: IOSTheme.smallShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(IOSTheme.radius10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: IOSTheme.title3.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
            ),
          ),
          Text(
            label,
            style: IOSTheme.caption1.copyWith(
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user, dynamic wallet, bool isDark) {
    final isSelected = _selectedUserIds.contains(user.id);

    return Dismissible(
      key: Key(user.id.toString()),
      direction: _isSelectionMode
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          return await _confirmDeleteUser(user);
        } else if (direction == DismissDirection.endToStart) {
          _editUser(user, wallet);
          return false;
        }
        return false;
      },
      background: _buildSwipeBackground(
        icon: Icons.delete_rounded,
        color: IOSTheme.systemRed,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
      ),
      secondaryBackground: _buildSwipeBackground(
        icon: Icons.edit_rounded,
        color: IOSTheme.systemBlue,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? IOSTheme.systemBlue.withValues(alpha: 0.2)
                    : IOSTheme.systemBlue.withValues(alpha: 0.1))
              : (isDark
                    ? IOSTheme.darkSecondarySystemGroupedBackground
                    : IOSTheme.systemBackground),
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
          border: _isSelectionMode
              ? Border.all(
                  color: isSelected
                      ? IOSTheme.systemBlue
                      : (isDark ? IOSTheme.darkSeparator : IOSTheme.separator),
                  width: isSelected ? 2 : 1,
                )
              : null,
          boxShadow: IOSTheme.smallShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(IOSTheme.radius16),
            onTap: () {
              HapticFeedback.selectionClick();
              if (_isSelectionMode) {
                _toggleUserSelection(user.id.toString());
              } else {
                _showUserDetails(context, user, wallet, isDark);
              }
            },
            onLongPress: () => _toggleUserSelection(user.id.toString()),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected
                            ? IOSTheme.systemBlue
                            : (isDark
                                  ? IOSTheme.darkSecondaryLabel
                                  : IOSTheme.systemGray),
                        size: 24,
                      ),
                    ),
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: user.isPremium == true
                          ? const LinearGradient(colors: IOSTheme.goldGradient)
                          : LinearGradient(
                              colors: [
                                IOSTheme.systemBlue,
                                IOSTheme.systemPurple,
                              ],
                            ),
                    ),
                    child: Center(
                      child: Text(
                        (user.name ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name ?? 'Noma\'lum',
                                style: IOSTheme.headline.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? IOSTheme.darkLabel
                                      : IOSTheme.label,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user.isPremium == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: IOSTheme.systemYellow.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    IOSTheme.radius4,
                                  ),
                                ),
                                child: Icon(
                                  Icons.workspace_premium_rounded,
                                  color: IOSTheme.systemYellow,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'Email yo\'q',
                          style: IOSTheme.caption1.copyWith(
                            color: isDark
                                ? IOSTheme.darkSecondaryLabel
                                : IOSTheme.secondaryLabel,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Stats
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(wallet?.balance ?? 0).toStringAsFixed(0)} so\'m',
                        style: IOSTheme.footnote.copyWith(
                          fontWeight: FontWeight.w700,
                          color: IOSTheme.systemGreen,
                        ),
                      ),
                      Text(
                        '${user.totalAdsWatched ?? 0} ta',
                        style: IOSTheme.caption1.copyWith(
                          color: isDark
                              ? IOSTheme.darkTertiaryLabel
                              : IOSTheme.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required IconData icon,
    required Color color,
    required Alignment alignment,
    required EdgeInsetsGeometry padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(IOSTheme.radius16),
      ),
      alignment: alignment,
      padding: padding,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildEmptyUsersState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? IOSTheme.darkTertiarySystemBackground
                  : IOSTheme.systemGray6,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 56,
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Foydalanuvchilar topilmadi',
            style: IOSTheme.title3.copyWith(
              color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Qidiruv so\'zini o\'zgartiring'
                : 'Hali foydalanuvchilar yo\'q',
            style: IOSTheme.subhead.copyWith(
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdsTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reklamalar (${_ads.length})',
                style: IOSTheme.title3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddAdDialog,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Yangi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: IOSTheme.systemRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(IOSTheme.radius10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _ads.isEmpty
              ? _buildEmptyAdsState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ads.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ad = _ads[index];
                    return _buildAdCard(ad, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyAdsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: IOSTheme.systemRed.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.videocam_off_rounded,
              size: 56,
              color: IOSTheme.systemRed,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hali reklamalar yo\'q',
            style: IOSTheme.title3.copyWith(
              color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yangi reklama qo\'shish uchun tugmani bosing',
            style: IOSTheme.subhead.copyWith(
              color: isDark
                  ? IOSTheme.darkSecondaryLabel
                  : IOSTheme.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad, bool isDark) {
    final level = AdLevel.values.firstWhere(
      (e) => e.toString() == 'AdLevel.${ad['level']}',
      orElse: () => AdLevel.oddiy,
    );
    final isActive = ad['isActive'] ?? true;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? IOSTheme.darkSecondarySystemGroupedBackground
            : IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(IOSTheme.radius16),
        boxShadow: IOSTheme.smallShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
          onTap: () => _showAdDetails(ad, isDark),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: level.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(IOSTheme.radius12),
                  ),
                  child: Icon(level.icon, color: level.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad['title'] ?? 'Nomsiz reklama',
                        style: IOSTheme.headline.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ad['description'] ?? 'Tavsif yo\'q',
                        style: IOSTheme.caption1.copyWith(
                          color: isDark
                              ? IOSTheme.darkSecondaryLabel
                              : IOSTheme.secondaryLabel,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: level.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                IOSTheme.radius4,
                              ),
                            ),
                            child: Text(
                              level.label,
                              style: IOSTheme.caption2.copyWith(
                                color: level.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.timer_rounded,
                            size: 14,
                            color: isDark
                                ? IOSTheme.darkTertiaryLabel
                                : IOSTheme.systemGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ad['durationSeconds'] ?? 30}s',
                            style: IOSTheme.caption2.copyWith(
                              color: isDark
                                  ? IOSTheme.darkTertiaryLabel
                                  : IOSTheme.secondaryLabel,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.attach_money_rounded,
                            size: 14,
                            color: isDark
                                ? IOSTheme.darkTertiaryLabel
                                : IOSTheme.systemGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(ad['reward'] ?? level.reward).toStringAsFixed(0)}',
                            style: IOSTheme.caption2.copyWith(
                              color: isDark
                                  ? IOSTheme.darkTertiaryLabel
                                  : IOSTheme.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Switch(
                      value: isActive,
                      onChanged: (value) => _toggleAdStatus(ad['id']),
                      activeTrackColor: IOSTheme.systemGreen.withValues(
                        alpha: 0.5,
                      ),
                      activeThumbColor: IOSTheme.systemGreen,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _showEditAdDialog(ad),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: IOSTheme.systemBlue,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _deleteAd(ad['id']),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.delete_rounded,
                              size: 18,
                              color: IOSTheme.systemRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Ad Details

  void _showAdDetails(Map<String, dynamic> ad, bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          ad['title'] ?? 'Nomsiz reklama',
          style: IOSTheme.title3.copyWith(
            color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tavsif:', ad['description'] ?? 'N/A', isDark),
            _buildDetailRow(
              'Davomiyligi:',
              '${ad['durationSeconds'] ?? 30} sekund',
              isDark,
            ),
            _buildDetailRow(
              'Mukofot:',
              '${(ad['reward'] ?? 0).toStringAsFixed(0)} so\'m',
              isDark,
            ),
            _buildDetailRow(
              'Holati:',
              (ad['isActive'] ?? true) ? 'Faol ✅' : 'Nofaol ❌',
              isDark,
            ),
            if (ad['imageUrl'] != null)
              _buildDetailRow('Rasm:', ad['imageUrl'], isDark),
            if (ad['createdAt'] != null)
              _buildDetailRow(
                'Yaratilgan:',
                DateFormat(
                  'dd.MM.yyyy HH:mm',
                ).format(DateTime.parse(ad['createdAt'])),
                isDark,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showEditAdDialog(ad);
              Navigator.pop(context);
            },
            child: Text(
              'Tahrirlash',
              style: IOSTheme.footnote.copyWith(color: IOSTheme.systemBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Yopish',
              style: IOSTheme.footnote.copyWith(color: IOSTheme.systemBlue),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Actions

  Future<bool> _confirmDeleteUser(dynamic user) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Foydalanuvchini o\'chirish'),
            content: Text(
              '${user.name} foydalanuvchini o\'chirmoqchimisiz? Bu amalni qaytarib bo\'lmaydi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Bekor qilish',
                  style: IOSTheme.footnote.copyWith(color: IOSTheme.systemBlue),
                ),
              ),
              TextButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  // Delete user implementation
                  await _deleteUser(user.id);
                  if (!context.mounted) return;
                  Navigator.pop(context, true);
                },
                child: Text(
                  'O\'chirish',
                  style: IOSTheme.footnote.copyWith(color: IOSTheme.systemRed),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteUser(String userId) async {
    HapticFeedback.mediumImpact();
    await _authService.deleteUser(userId);
    _loadData();
  }

  Future<void> _toggleAdStatus(String adId) async {
    HapticFeedback.selectionClick();
    await _adStorageService.toggleAdStatus(adId);
    _loadData();
  }

  Future<void> _deleteAd(String adId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reklamani o\'chirish'),
        content: const Text('Bu reklamani o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Bekor qilish',
              style: IOSTheme.footnote.copyWith(color: IOSTheme.systemBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'O\'chirish',
              style: IOSTheme.footnote.copyWith(color: IOSTheme.systemRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      HapticFeedback.mediumImpact();
      await _adStorageService.deleteAd(adId);
      _loadData();
    }
  }

  void _showAddAdDialog() {
    HapticFeedback.mediumImpact();
    _showAdDialog();
  }

  void _showEditAdDialog(Map<String, dynamic> ad) {
    HapticFeedback.selectionClick();
    _showAdDialog(ad: ad);
  }

  Widget _buildBulkActionsButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? IOSTheme.darkSecondarySystemGroupedBackground
            : IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(IOSTheme.radius24),
        boxShadow: IOSTheme.mediumShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${_selectedUserIds.length} ta tanlangan',
              style: IOSTheme.headline,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: IOSTheme.systemRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_rounded),
              color: IOSTheme.systemRed,
              onPressed: () async {
                // Bulk delete implementation
                for (final userId in _selectedUserIds) {
                  await _authService.deleteUser(userId);
                }
                _selectedUserIds.clear();
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_selectedUserIds.length} ta foydalanuvchi o\'chirildi',
                      ),
                      backgroundColor: IOSTheme.systemGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(IOSTheme.radius12),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
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
      text: (ad?['reward'] ?? AppConstants.baseReward).toString(),
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
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            title: Text(
              isEditing ? 'Reklamani tahrirlash' : 'Yangi reklama',
              style: IOSTheme.title3.copyWith(
                color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
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
                      labelText: 'Mukofot (so\'m)',
                      prefixText: 'so\'m ',
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
                child: Text(
                  'Bekor qilish',
                  style: IOSTheme.footnote.copyWith(color: IOSTheme.systemBlue),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Sarlavha kiritilishi shart!'),
                        backgroundColor: IOSTheme.systemRed,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            IOSTheme.radius12,
                          ),
                        ),
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
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _loadData();

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Reklama yangilandi!'
                            : 'Reklama qo\'shildi!',
                      ),
                      backgroundColor: IOSTheme.systemGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(IOSTheme.radius12),
                      ),
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

  void _showUserDetails(
    BuildContext context,
    dynamic user,
    dynamic wallet,
    bool isDark,
  ) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          user.name ?? 'Noma\'lum',
          style: IOSTheme.title3.copyWith(
            color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email:', user.email ?? 'N/A', isDark),
            _buildDetailRow('Telefon:', user.phone ?? 'N/A', isDark),
            _buildDetailRow(
              'Balans:',
              '${(wallet?.balance ?? 0).toStringAsFixed(0)} so\'m',
              isDark,
            ),
            _buildDetailRow(
              'Reklamalar:',
              '${user.totalAdsWatched ?? 0} ta',
              isDark,
            ),
            _buildDetailRow(
              'Jami ishlangan:',
              '${(user.totalEarned ?? 0).toStringAsFixed(0)} so\'m',
              isDark,
            ),
            _buildDetailRow(
              'Premium:',
              user.isPremium == true ? 'Ha ✅' : 'Yo\'q',
              isDark,
            ),
            if (user.isPremium == true && user.premiumExpiry != null)
              _buildDetailRow(
                'Muddati:',
                DateFormat('dd.MM.yyyy').format(user.premiumExpiry),
                isDark,
              ),
            if (user.createdAt != null)
              _buildDetailRow(
                'Ro\'yxatdan o\'tgan:',
                DateFormat('dd.MM.yyyy').format(user.createdAt),
                isDark,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _editUser(user, wallet);
              Navigator.pop(context);
            },
            child: Text(
              'Tahrirlash',
              style: IOSTheme.footnote.copyWith(color: IOSTheme.systemBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Yopish',
              style: IOSTheme.footnote.copyWith(color: IOSTheme.systemBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _editUser(dynamic user, dynamic wallet) {
    HapticFeedback.mediumImpact();
    final nameController = TextEditingController(text: user.name ?? '');
    final emailController = TextEditingController(text: user.email ?? '');
    final phoneController = TextEditingController(text: user.phone ?? '');
    bool isPremium = user.isPremium ?? false;
    bool isAdmin = user.isAdmin ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            title: Text(
              'Foydalanuvchini tahrirlash',
              style: IOSTheme.title3.copyWith(
                color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Ism'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Telefon'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Premium'),
                    value: isPremium,
                    onChanged: (value) {
                      setDialogState(() => isPremium = value);
                    },
                    activeThumbColor: IOSTheme.systemYellow,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Bekor qilish',
                  style: IOSTheme.footnote.copyWith(color: IOSTheme.systemBlue),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Save user changes implementation
                  final updatedUser = user.copyWith(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    isPremium: isPremium,
                    isAdmin: isAdmin,
                  );
                  await _authService.updateUser(updatedUser);
                  HapticFeedback.mediumImpact();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Foydalanuvchi yangilandi!'),
                      backgroundColor: IOSTheme.systemGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(IOSTheme.radius12),
                      ),
                    ),
                  );
                },
                child: const Text('Saqlash'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: IOSTheme.subhead.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? IOSTheme.darkSecondaryLabel
                    : IOSTheme.secondaryLabel,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: IOSTheme.subhead.copyWith(
                color: isDark ? IOSTheme.darkLabel : IOSTheme.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
