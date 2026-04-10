import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';
import '../theme/ios_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _hasReferralCode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final referralCode = _hasReferralCode
        ? _referralController.text.trim().toUpperCase()
        : null;

    await provider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
      referralCode: referralCode,
    );

    if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error!,
            style: IOSTheme.subhead.copyWith(color: Colors.white),
          ),
          backgroundColor: IOSTheme.systemRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      provider.clearError();
    } else if (mounted) {
      final message = referralCode != null && referralCode.isNotEmpty
          ? 'Ro\'yxatdan o\'tish muvaffaqiyatli! Referral bonus: 10 000 so\'m'
          : 'Ro\'yxatdan o\'tish muvaffaqiyatli! Endi kirishingiz mumkin.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: IOSTheme.subhead.copyWith(color: Colors.white),
          ),
          backgroundColor: IOSTheme.systemGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: IOSTheme.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: IOSTheme.systemGroupedBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: IOSTheme.systemBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ro\'yxatdan o\'tish',
          style: IOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // iOS Style Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: IOSTheme.successGradient,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: IOSTheme.smallShadow,
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // iOS Style Section Title
                Text(
                  'Shaxsiy ma\'lumotlar',
                  style: IOSTheme.headline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hisobingizni yaratish uchun ma\'lumotlaringizni kiriting',
                  style: IOSTheme.subhead.copyWith(
                    color: IOSTheme.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 24),
                // iOS Style Input Fields
                _buildIOSTextField(
                  controller: _nameController,
                  hintText: 'Ism',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.validateName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                _buildIOSTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildIOSTextField(
                  controller: _phoneController,
                  hintText: 'Telefon',
                  prefixIcon: Icons.phone,
                  validator: Validators.validatePhone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                // Security Section
                Text(
                  'Xavfsizlik',
                  style: IOSTheme.headline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildIOSPasswordField(
                  controller: _passwordController,
                  hintText: 'Parol',
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 12),
                _buildIOSPasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Parolni tasdiqlang',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Parolni tasdiqlang';
                    }
                    if (value != _passwordController.text) {
                      return 'Parollar mos kelmadi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // iOS Style Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: IOSTheme.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: IOSTheme.systemIndigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          color: IOSTheme.systemIndigo,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Referral kodi bor?',
                              style: IOSTheme.body.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Bonus olish uchun',
                              style: IOSTheme.footnote.copyWith(
                                color: IOSTheme.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _hasReferralCode,
                        onChanged: (value) {
                          setState(() {
                            _hasReferralCode = value;
                          });
                        },
                        activeThumbColor: IOSTheme.systemBlue,
                      ),
                    ],
                  ),
                ),
                if (_hasReferralCode) ...[
                  const SizedBox(height: 12),
                  _buildIOSTextField(
                    controller: _referralController,
                    hintText: 'Referral kodi',
                    prefixIcon: Icons.card_giftcard,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: IOSTheme.systemGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: IOSTheme.systemGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: IOSTheme.systemGreen, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Referral kod bilan ro\'yxatdan o\'tsangiz, 10 000 so\'m bonus olasiz!',
                            style: IOSTheme.footnote.copyWith(
                              color: IOSTheme.systemGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // iOS Style Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: IOSTheme.systemBlue,
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
                            'Ro\'yxatdan o\'tish',
                            style: IOSTheme.headline.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // iOS Style Footer
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: IOSTheme.systemBlue,
                    ),
                    child: Text(
                      'Hisobingiz bormi? Kirish',
                      style: IOSTheme.body.copyWith(
                        color: IOSTheme.systemBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // iOS Style Text Field
  Widget _buildIOSTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: IOSTheme.body,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: IOSTheme.body.copyWith(color: IOSTheme.placeholderText),
        prefixIcon: Icon(prefixIcon, color: IOSTheme.secondaryLabel, size: 22),
        filled: true,
        fillColor: IOSTheme.systemBackground,
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
          borderSide: const BorderSide(color: IOSTheme.systemBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: IOSTheme.systemRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  // iOS Style Password Field
  Widget _buildIOSPasswordField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      style: IOSTheme.body,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: IOSTheme.body.copyWith(color: IOSTheme.placeholderText),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: IOSTheme.secondaryLabel,
          size: 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
        fillColor: IOSTheme.systemBackground,
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
          borderSide: const BorderSide(color: IOSTheme.systemBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: IOSTheme.systemRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}
