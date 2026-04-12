import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS 26 Style Design System
/// Comprehensive iOS design language implementation
class IOSTheme {
  // MARK: - iOS System Colors
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemCyan = Color(0xFF64D2FF);

  // MARK: - iOS Gray Colors
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);

  // MARK: - Background Colors
  static const Color systemBackground = Color(0xFFFFFFFF);
  static const Color secondarySystemBackground = Color(0xFFF2F2F7);
  static const Color tertiarySystemBackground = Color(0xFFFFFFFF);
  static const Color systemGroupedBackground = Color(0xFFF2F2F7);
  static const Color secondarySystemGroupedBackground = Color(0xFFFFFFFF);
  static const Color tertiarySystemGroupedBackground = Color(0xFFF2F2F7);

  // MARK: - Label Colors
  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0xFF3C3C43);
  static const Color tertiaryLabel = Color(0xFF3C3C43);
  static const Color quaternaryLabel = Color(0xFF3C3C43);
  static const Color placeholderText = Color(0xFF3C3C43);
  static const Color link = Color(0xFF007AFF);
  static const Color separator = Color(0xFFC6C6C8);
  static const Color opaqueSeparator = Color(0xFFC6C6C8);

  // MARK: - Dark Mode Colors
  static const Color darkSystemBackground = Color(0xFF000000);
  static const Color darkSecondarySystemBackground = Color(0xFF1C1C1E);
  static const Color darkTertiarySystemBackground = Color(0xFF2C2C2E);
  static const Color darkSystemGroupedBackground = Color(0xFF000000);
  static const Color darkSecondarySystemGroupedBackground = Color(0xFF1C1C1E);
  static const Color darkTertiarySystemGroupedBackground = Color(0xFF2C2C2E);
  static const Color darkLabel = Color(0xFFFFFFFF);
  static const Color darkSecondaryLabel = Color(0xFFEBEBF5);
  static const Color darkTertiaryLabel = Color(0xFFEBEBF5);
  static const Color darkQuaternaryLabel = Color(0xFFEBEBF5);
  static const Color darkPlaceholderText = Color(0xFF8E8E93);
  static const Color darkSeparator = Color(0xFF38383A);

  // MARK: - Gradient Colors for Premium Feel
  static const List<Color> premiumGradient = [
    Color(0xFF007AFF),
    Color(0xFF5856D6),
  ];
  static const List<Color> darkPremiumGradient = [
    Color(0xFF5AC8FA),
    Color(0xFFAF52DE),
  ];
  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500),
  ];
  static const List<Color> darkGoldGradient = [
    Color(0xFFBF953F),
    Color(0xFFFCF6BA),
  ];
  static const List<Color> successGradient = [
    Color(0xFF34C759),
    Color(0xFF30D158),
  ];
  static const List<Color> darkSuccessGradient = [
    Color(0xFF30D158),
    Color(0xFF32D74B),
  ];
  static const List<Color> blueGradient = [
    Color(0xFF007AFF),
    Color(0xFF5856D6),
  ];
  static const List<Color> darkBlueGradient = [
    Color(0xFF5AC8FA),
    Color(0xFF64D2FF),
  ];

  // MARK: - Typography (iOS 17/18 Style)
  static const String fontFamily = '.SF Pro Display';
  static const String fontFamilyRounded = '.SF Pro Rounded';
  static const String fontFamilyText = '.SF Pro Text';

  // MARK: - Text Styles
  static const TextStyle largeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: label,
  );

  static const TextStyle title1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: label,
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: label,
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: label,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: label,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: label,
  );

  static const TextStyle callout = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: label,
  );

  static const TextStyle subhead = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: label,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: secondaryLabel,
  );

  static const TextStyle caption1 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: secondaryLabel,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: secondaryLabel,
  );

  // MARK: - Spacing (iOS Grid)
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;

  // MARK: - Corner Radius (iOS Style)
  static const double radius4 = 4;
  static const double radius8 = 8;
  static const double radius10 = 10;
  static const double radius12 = 12;
  static const double radius14 = 14;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;
  static const double radiusFull = 999;

  // MARK: - Shadows (iOS Style)
  static List<BoxShadow> get smallShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get largeShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // MARK: - Glassmorphism Effect
  static BoxDecoration get glassmorphism => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(radius16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
    boxShadow: smallShadow,
  );

  static BoxDecoration get darkGlassmorphism => BoxDecoration(
    color: Colors.black.withValues(alpha: 0.4),
    borderRadius: BorderRadius.circular(radius16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
    boxShadow: smallShadow,
  );

  // MARK: - iOS Button Styles
  static ButtonStyle get filledButtonStyle => ElevatedButton.styleFrom(
    elevation: 0,
    backgroundColor: systemBlue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius12),
    ),
    textStyle: headline.copyWith(color: Colors.white),
  );

  static ButtonStyle get tonalButtonStyle => ElevatedButton.styleFrom(
    elevation: 0,
    backgroundColor: systemGray6,
    foregroundColor: systemBlue,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius12),
    ),
    textStyle: headline.copyWith(color: systemBlue),
  );

  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: systemBlue,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius12),
    ),
    side: const BorderSide(color: systemBlue, width: 1),
    textStyle: headline.copyWith(color: systemBlue),
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: systemBlue,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: headline.copyWith(color: systemBlue),
  );

  // MARK: - iOS Card Style
  static BoxDecoration get iosCard => BoxDecoration(
    color: systemBackground,
    borderRadius: BorderRadius.circular(radius16),
    boxShadow: smallShadow,
  );

  static BoxDecoration get iosGroupedCard => BoxDecoration(
    color: secondarySystemGroupedBackground,
    borderRadius: BorderRadius.circular(radius12),
  );

  // MARK: - iOS Input Style
  static InputDecorationTheme get iosInputTheme => InputDecorationTheme(
    filled: true,
    fillColor: systemGray6,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius12),
      borderSide: const BorderSide(color: systemBlue, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius12),
      borderSide: const BorderSide(color: systemRed, width: 1.5),
    ),
    hintStyle: body.copyWith(color: placeholderText),
  );

  // MARK: - iOS AppBar Style
  static AppBarTheme get iosAppBar => const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: systemBackground,
    foregroundColor: systemBlue,
    titleTextStyle: headline,
    toolbarHeight: 44,
  );

  // MARK: - iOS NavigationBar Style
  static BottomNavigationBarThemeData get iosNavBar =>
      const BottomNavigationBarThemeData(
        backgroundColor: systemBackground,
        selectedItemColor: systemBlue,
        unselectedItemColor: systemGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: caption2,
        unselectedLabelStyle: caption2,
      );

  // MARK: - System UI Overlay Style
  static SystemUiOverlayStyle get lightOverlay => const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: systemBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static SystemUiOverlayStyle get darkOverlay => const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: darkSystemBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  // MARK: - Animation Durations (iOS Style)
  static const Duration quickAnimation = Duration(milliseconds: 150);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // MARK: - Curves (iOS Style)
  static const Curve iosCurve = Curves.easeInOut;
  static const Curve iosSpring = Curves.elasticOut;
  static const Curve iosDecelerate = Curves.decelerate;
}

/// iOS-style widgets extension
extension IOSWidgetExtension on Widget {
  /// Add iOS-style glassmorphism background
  Widget withIOSGlassmorphism({bool isDark = false}) {
    return Container(
      decoration: isDark ? IOSTheme.darkGlassmorphism : IOSTheme.glassmorphism,
      child: this,
    );
  }

  /// Add iOS-style padding
  Widget withIOSPadding({double horizontal = 16, double vertical = 12}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Add iOS-style animation
  Widget withIOSAnimation({
    Duration duration = IOSTheme.standardAnimation,
    Curve curve = IOSTheme.iosCurve,
  }) {
    return AnimatedContainer(duration: duration, curve: curve, child: this);
  }
}
