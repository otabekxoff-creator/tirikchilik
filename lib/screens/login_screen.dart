import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../theme/ios_theme.dart';
import '../routing/app_router.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isAdminLogin = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isAdminLogin) {
      final authService = AuthService();
      final adminUser = await authService.adminLogin(email, password);
      if (adminUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin login yoki parol noto\'g\'ri'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    final notifier = ref.read(appProviderProvider.notifier);
    await notifier.login(email, password);

    final state = ref.read(appProviderProvider);
    if (state.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
      );
      notifier.clearError();
    } else if (state.isLoggedIn && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appProviderProvider);

    return Scaffold(
      backgroundColor: IOSTheme.systemGroupedBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // iOS Style App Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: IOSTheme.premiumGradient,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: IOSTheme.mediumShadow,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name - iOS Style Large Title
                  Text(
                    'Tirikchilik',
                    style: IOSTheme.largeTitle.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tagline - iOS Style Subhead
                  Text(
                    'Reklama ko\'rib pul ishlang',
                    style: IOSTheme.subhead.copyWith(
                      color: IOSTheme.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // iOS Style Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: IOSTheme.iosCard,
                    child: Column(
                      children: [
                        // iOS Style Segmented Control
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: IOSTheme.systemGray6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isAdminLogin = false),
                                  child: AnimatedContainer(
                                    duration: IOSTheme.quickAnimation,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_isAdminLogin
                                          ? IOSTheme.systemBackground
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: !_isAdminLogin
                                          ? IOSTheme.smallShadow
                                          : [],
                                    ),
                                    child: Text(
                                      'Foydalanuvchi',
                                      textAlign: TextAlign.center,
                                      style: IOSTheme.subhead.copyWith(
                                        color: !_isAdminLogin
                                            ? IOSTheme.label
                                            : IOSTheme.secondaryLabel,
                                        fontWeight: !_isAdminLogin
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isAdminLogin = true),
                                  child: AnimatedContainer(
                                    duration: IOSTheme.quickAnimation,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isAdminLogin
                                          ? IOSTheme.systemRed.withValues(
                                              alpha: 0.15,
                                            )
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Admin',
                                      textAlign: TextAlign.center,
                                      style: IOSTheme.subhead.copyWith(
                                        color: _isAdminLogin
                                            ? IOSTheme.systemRed
                                            : IOSTheme.secondaryLabel,
                                        fontWeight: _isAdminLogin
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // iOS Style TextFields
                        TextFormField(
                          controller: _emailController,
                          style: IOSTheme.body,
                          decoration: InputDecoration(
                            hintText: _isAdminLogin
                                ? 'Login'
                                : 'Email yoki Telefon',
                            hintStyle: IOSTheme.body.copyWith(
                              color: IOSTheme.placeholderText,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: IOSTheme.secondaryLabel,
                              size: 22,
                            ),
                            filled: true,
                            fillColor: IOSTheme.systemGray6,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Maydonni to\'ldiring';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: IOSTheme.body,
                          decoration: InputDecoration(
                            hintText: 'Parol',
                            hintStyle: IOSTheme.body.copyWith(
                              color: IOSTheme.placeholderText,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: IOSTheme.secondaryLabel,
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: IOSTheme.secondaryLabel,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: IOSTheme.systemGray6,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Parolni kiriting';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // iOS Style Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _isAdminLogin
                                  ? IOSTheme.systemRed
                                  : IOSTheme.systemBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Kirish',
                                    style: IOSTheme.headline.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // iOS Style Text Button
                  if (!_isAdminLogin)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: IOSTheme.systemBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Hisob yo\'qmi? Ro\'yxatdan o\'ting',
                        style: IOSTheme.body.copyWith(
                          color: IOSTheme.systemBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
