import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _topEarners = [];
  List<Map<String, dynamic>> _topWatchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    final authService = AuthService();
    final users = await authService.getAllUsers();

    // Top earners by total earned
    _topEarners = users
        .where((u) => !u.isAdmin)
        .map(
          (u) => {
            'name': u.name,
            'earned': u.totalEarned,
            'avatar': u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
          },
        )
        .toList();
    _topEarners.sort(
      (a, b) => (b['earned'] as double).compareTo(a['earned'] as double),
    );
    _topEarners = _topEarners.take(20).toList();

    // Top watchers by ads watched
    _topWatchers = users
        .where((u) => !u.isAdmin)
        .map(
          (u) => {
            'name': u.name,
            'watched': u.totalAdsWatched,
            'avatar': u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
          },
        )
        .toList();
    _topWatchers.sort(
      (a, b) => (b['watched'] as int).compareTo(a['watched'] as int),
    );
    _topWatchers = _topWatchers.take(20).toList();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liderlar taxtasi'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: 'Eng ko\'p ishlangan'),
            Tab(icon: Icon(Icons.visibility), text: 'Eng ko\'p ko\'rilgan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildEarnersList(), _buildWatchersList()],
            ),
    );
  }

  Widget _buildEarnersList() {
    if (_topEarners.isEmpty) {
      return _buildEmptyState('Hali ma\'lumot yo\'q');
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _topEarners.length,
        itemBuilder: (context, index) {
          final user = _topEarners[index];
          return _buildLeaderboardItem(
            rank: index + 1,
            name: user['name'] as String,
            value: '\$${(user['earned'] as double).toStringAsFixed(2)}',
            avatar: user['avatar'] as String,
            isTop3: index < 3,
          );
        },
      ),
    );
  }

  Widget _buildWatchersList() {
    if (_topWatchers.isEmpty) {
      return _buildEmptyState('Hali ma\'lumot yo\'q');
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _topWatchers.length,
        itemBuilder: (context, index) {
          final user = _topWatchers[index];
          return _buildLeaderboardItem(
            rank: index + 1,
            name: user['name'] as String,
            value: '${user['watched']} ta reklama',
            avatar: user['avatar'] as String,
            isTop3: index < 3,
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required String value,
    required String avatar,
    required bool isTop3,
  }) {
    Color rankColor;
    IconData? rankIcon;

    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey.shade400;
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = Colors.orange.shade300;
        rankIcon = Icons.emoji_events;
        break;
      default:
        rankColor = Colors.blue.shade100;
        rankIcon = null;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isTop3 ? 4 : 1,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                avatar,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            if (rankIcon != null)
              Positioned(
                right: -4,
                bottom: -4,
                child: Icon(rankIcon, color: rankColor, size: 20),
              ),
          ],
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isTop3 ? rankColor.withOpacity(0.8) : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
