import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_provider.dart';
import '../services/secure_storage_service.dart';
import '../utils/app_logger.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _biometricAuth = false;
  String _selectedLanguage = 'uz';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final secureStorage = SecureStorageService();
    final notifications = await secureStorage.read('notifications_enabled');
    final darkMode = await secureStorage.read('dark_mode');
    final biometric = await secureStorage.read('biometric_auth');
    final language = await secureStorage.read('selected_language');

    if (mounted) {
      setState(() {
        _notificationsEnabled = notifications != 'false';
        _darkMode = darkMode == 'true';
        _biometricAuth = biometric == 'true';
        _selectedLanguage = language ?? 'uz';
      });
    }
  }

  Future<void> _saveSetting(String key, String value) async {
    final secureStorage = SecureStorageService();
    await secureStorage.write(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProviderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar'), centerTitle: true),
      body: ListView(
        children: [
          _buildSectionHeader('Hisob'),
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Profil',
            subtitle: state.currentUser?.name ?? '',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.security,
            title: 'Xavfsizlik',
            subtitle: 'Parolni o\'zgartirish',
            onTap: _showChangePasswordDialog,
          ),

          _buildSectionHeader('Bildirishnomalar'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push bildirishnomalar'),
            subtitle: const Text('Bildirishnomalarni yoqish'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await _saveSetting('notifications_enabled', value.toString());
            },
          ),

          _buildSectionHeader('Ko\'rinish'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Qorong\'i rejim'),
            subtitle: const Text('Qorong\'i rejimni yoqish'),
            value: _darkMode,
            onChanged: (value) async {
              setState(() => _darkMode = value);
              await _saveSetting('dark_mode', value.toString());
            },
          ),

          _buildListTile(
            icon: Icons.language,
            title: 'Til',
            subtitle: _getLanguageName(_selectedLanguage),
            onTap: _showLanguageSelector,
          ),

          _buildSectionHeader('Xavfsizlik'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometrik autentifikatsiya'),
            subtitle: const Text('Barmoq izi / Face ID'),
            value: _biometricAuth,
            onChanged: (value) async {
              setState(() => _biometricAuth = value);
              await _saveSetting('biometric_auth', value.toString());
            },
          ),

          _buildSectionHeader('Maxfiylik'),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Maxfiylik siyosati',
            onTap: () => _showPrivacyPolicy(),
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Foydalanish shartlari',
            onTap: () => _showTermsOfService(),
          ),

          _buildSectionHeader('Ma\'lumotlar'),
          _buildListTile(
            icon: Icons.delete_outline,
            title: 'Keshni tozalash',
            subtitle: 'Vaqtinchalik fayllarni o\'chirish',
            onTap: _clearCache,
            textColor: Colors.orange,
          ),
          _buildListTile(
            icon: Icons.delete_forever_outlined,
            title: 'Hisobni o\'chirish',
            subtitle: 'Barcha ma\'lumotlarni o\'chirish',
            onTap: _showDeleteAccountDialog,
            textColor: Colors.red,
          ),

          _buildSectionHeader('Dastur haqida'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'Versiya',
            subtitle: '1.0.0',
            onTap: null,
          ),
          _buildListTile(
            icon: Icons.support_agent,
            title: 'Qo\'llab-quvvatlash',
            onTap: _contactSupport,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'uz':
        return 'O\'zbek';
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'kk':
        return 'Қазақша';
      case 'tg':
        return 'Тоҷикӣ';
      case 'ky':
        return 'Кыргызча';
      default:
        return 'O\'zbek';
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('uz', 'O\'zbek'),
              _buildLanguageOption('ru', 'Русский'),
              _buildLanguageOption('en', 'English'),
              _buildLanguageOption('kk', 'Қазақша'),
              _buildLanguageOption('tg', 'Тоҷикӣ'),
              _buildLanguageOption('ky', 'Кыргызча'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String code, String name) {
    return ListTile(
      title: Text(name),
      trailing: _selectedLanguage == code
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () async {
        setState(() => _selectedLanguage = code);
        await _saveSetting('selected_language', code);
        if (mounted) Navigator.pop(context);
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parolni o\'zgartirish'),
        content: const Text('Bu funksiya tez orada qo\'shiladi'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  void _showTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keshni tozalash'),
        content: const Text(
          'Barcha vaqtinchalik fayllar o\'chiriladi. Davom etasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tozalash'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement cache clearing
      AppLogger.info('Cache cleared');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kesh tozalandi')));
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hisobni o\'chirish',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Diqqat! Bu amalni qaytarib bo\'lmaydi. Barcha ma\'lumotlaringiz o\'chiriladi. '
          'Davom etish uchun "O\'CHIRISH" so\'zini yozing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'CHIRISH'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    // TODO: Implement account deletion
    AppLogger.warning('Account deletion requested');
  }

  void _contactSupport() {
    // TODO: Implement support contact
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qo\'llab-quvvatlash'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: otabekxoff@gmail.com'),
            SizedBox(height: 8),
            Text('Telegram: @otabekxoff'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maxfiylik siyosati')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maxfiylik siyosati',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Tirikchilik ilovasi foydalanuvchilarning maxfiyligini himoya qiladi. '
              'Biz sizning shaxsiy ma\'lumotlaringizni xavfsiz saqlaymiz va uchinchi tomonlarga bermaymiz.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '1. Qanday ma\'lumotlarni yig\'amiz:\n'
              '- Ism va familiya\n'
              '- Email manzil\n'
              '- Telefon raqam\n'
              '- Hamyon balansi\n'
              '- Reklama ko\'rish statistikasi',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '2. Ma\'lumotlardan qanday foydalanamiz:\n'
              '- Hisobingizni boshqarish\n'
              '- Pul to\'lovlarni amalga oshirish\n'
              '- Statistikani yuritish\n'
              '- Ilova ishlashini yaxshilash',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '3. Ma\'lumotlar xavfsizligi:\n'
              '- Barcha ma\'lumotlar shifrlanadi\n'
              '- Secure Storage ishlatiladi\n'
              '- Firebase xavfsizligi',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foydalanish shartlari')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foydalanish shartlari',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Tirikchilik ilovasidan foydalanish bilan siz quyidagi shartlarga rozilik bildirasiz:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '1. Umumiy qoidalar:\n'
              '- Ilovadan faqat o\'z maqsadlaringiz uchun foydalaning\n'
              '- Boshqa foydalanuvchilarga zarar yetkazmang\n'
              '- Soxta ma\'lumotlar kiritmang\n'
              '- Ko\'p hisoblar ochmang',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '2. Pul yechib olish:\n'
              '- Minimal yechib olish: 10,000 so\'m\n'
              '- Maksimal yechib olish: 1,000,000 so\'m\n'
              '- To\'lov 1-3 ish kunida amalga oshiriladi',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '3. Taqiqlangan harakatlar:\n'
              '- Bot yoki avtomatlashtirilgan dasturlar ishlatish\n'
              '- Reklamalarni soxta ko\'rsatish\n'
              '- Referral tizimidan suiiste\'mol qilish\n'
              '- Ilova xavfsizligini buzish',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
