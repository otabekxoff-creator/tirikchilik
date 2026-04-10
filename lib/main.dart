import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/admob_service.dart';
import 'utils/app_logger.dart';
import 'package:logging/logging.dart' as logging;
import 'theme/ios_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize App Logger
  AppLogger.init(level: logging.Level.INFO);

  // Initialize AdMob
  final adMob = AdMobService();
  await adMob.initialize();
  // Only load ads on mobile platforms
  if (adMob.isInitialized) {
    await adMob.loadInterstitialAd();
    await adMob.loadRewardedAd();
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style (iOS style)
  SystemChrome.setSystemUIOverlayStyle(IOSTheme.lightOverlay);

  runApp(const MyApp());
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tirikchilik',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // iOS 26 System Colors
      colorScheme: const ColorScheme.light(
        primary: IOSTheme.systemBlue,
        onPrimary: IOSTheme.systemBackground,
        secondary: IOSTheme.systemIndigo,
        onSecondary: IOSTheme.systemBackground,
        surface: IOSTheme.systemBackground,
        onSurface: IOSTheme.label,
        surfaceContainerHighest: IOSTheme.secondarySystemBackground,
        error: IOSTheme.systemRed,
        onError: IOSTheme.systemBackground,
      ),
      // iOS Typography
      fontFamily: IOSTheme.fontFamily,
      textTheme: TextTheme(
        displayLarge: IOSTheme.largeTitle,
        displayMedium: IOSTheme.title1,
        headlineLarge: IOSTheme.title2,
        headlineMedium: IOSTheme.title3,
        titleLarge: IOSTheme.headline,
        titleMedium: IOSTheme.body.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: IOSTheme.body,
        bodyMedium: IOSTheme.callout,
        bodySmall: IOSTheme.subhead,
        labelLarge: IOSTheme.headline.copyWith(color: IOSTheme.systemBlue),
        labelSmall: IOSTheme.caption1,
      ),
      // iOS AppBar
      appBarTheme: IOSTheme.iosAppBar,
      // iOS Cards
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
        ),
        color: IOSTheme.systemBackground,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // iOS Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: IOSTheme.filledButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: IOSTheme.outlinedButtonStyle,
      ),
      textButtonTheme: TextButtonThemeData(style: IOSTheme.textButtonStyle),
      // iOS Input
      inputDecorationTheme: IOSTheme.iosInputTheme,
      // iOS Navigation
      bottomNavigationBarTheme: IOSTheme.iosNavBar,
      // iOS Dividers
      dividerTheme: const DividerThemeData(
        color: IOSTheme.separator,
        thickness: 0.5,
        space: 0.5,
      ),
      // iOS Background
      scaffoldBackgroundColor: IOSTheme.systemGroupedBackground,
      // iOS Dialog
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius20),
        ),
        backgroundColor: IOSTheme.systemBackground,
      ),
      // iOS Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(IOSTheme.radius20),
            topRight: Radius.circular(IOSTheme.radius20),
          ),
        ),
        backgroundColor: IOSTheme.systemBackground,
      ),
      // iOS Chip
      chipTheme: ChipThemeData(
        backgroundColor: IOSTheme.systemGray6,
        selectedColor: IOSTheme.systemBlue.withValues(alpha: 0.15),
        labelStyle: IOSTheme.subhead,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radiusFull),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // iOS Dark System Colors
      colorScheme: const ColorScheme.dark(
        primary: IOSTheme.systemCyan,
        onPrimary: IOSTheme.darkSystemBackground,
        secondary: IOSTheme.systemIndigo,
        onSecondary: IOSTheme.darkSystemBackground,
        surface: IOSTheme.darkSystemBackground,
        onSurface: IOSTheme.darkLabel,
        surfaceContainerHighest: IOSTheme.darkSecondarySystemBackground,
        error: IOSTheme.systemRed,
        onError: IOSTheme.darkSystemBackground,
      ),
      // iOS Typography (Dark)
      fontFamily: IOSTheme.fontFamily,
      textTheme: TextTheme(
        displayLarge: IOSTheme.largeTitle.copyWith(color: IOSTheme.darkLabel),
        displayMedium: IOSTheme.title1.copyWith(color: IOSTheme.darkLabel),
        headlineLarge: IOSTheme.title2.copyWith(color: IOSTheme.darkLabel),
        headlineMedium: IOSTheme.title3.copyWith(color: IOSTheme.darkLabel),
        titleLarge: IOSTheme.headline.copyWith(color: IOSTheme.darkLabel),
        titleMedium: IOSTheme.body.copyWith(
          fontWeight: FontWeight.w600,
          color: IOSTheme.darkLabel,
        ),
        bodyLarge: IOSTheme.body.copyWith(color: IOSTheme.darkLabel),
        bodyMedium: IOSTheme.callout.copyWith(color: IOSTheme.darkLabel),
        bodySmall: IOSTheme.subhead.copyWith(color: IOSTheme.darkLabel),
        labelLarge: IOSTheme.headline.copyWith(color: IOSTheme.systemCyan),
        labelSmall: IOSTheme.caption1.copyWith(
          color: IOSTheme.darkSecondaryLabel,
        ),
      ),
      // iOS AppBar (Dark)
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: IOSTheme.darkSystemBackground,
        foregroundColor: IOSTheme.systemCyan,
        titleTextStyle: IOSTheme.headline.copyWith(color: IOSTheme.darkLabel),
        toolbarHeight: 44,
      ),
      // iOS Cards (Dark)
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
        ),
        color: IOSTheme.darkSecondarySystemBackground,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // iOS Buttons (Dark)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: IOSTheme.systemCyan,
          foregroundColor: IOSTheme.darkSystemBackground,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IOSTheme.radius12),
          ),
          textStyle: IOSTheme.headline.copyWith(
            color: IOSTheme.darkSystemBackground,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: IOSTheme.systemCyan,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IOSTheme.radius12),
          ),
          side: const BorderSide(color: IOSTheme.systemCyan, width: 1),
          textStyle: IOSTheme.headline.copyWith(color: IOSTheme.systemCyan),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: IOSTheme.systemCyan,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: IOSTheme.headline.copyWith(color: IOSTheme.systemCyan),
        ),
      ),
      // iOS Input (Dark)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: IOSTheme.darkSecondarySystemBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius12),
          borderSide: const BorderSide(color: IOSTheme.systemCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius12),
          borderSide: const BorderSide(color: IOSTheme.systemRed, width: 1.5),
        ),
        hintStyle: IOSTheme.body.copyWith(color: IOSTheme.darkPlaceholderText),
      ),
      // iOS Navigation (Dark)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: IOSTheme.darkSystemBackground,
        selectedItemColor: IOSTheme.systemCyan,
        unselectedItemColor: IOSTheme.systemGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: IOSTheme.caption2,
        unselectedLabelStyle: IOSTheme.caption2,
      ),
      // iOS Dividers (Dark)
      dividerTheme: const DividerThemeData(
        color: IOSTheme.darkSeparator,
        thickness: 0.5,
        space: 0.5,
      ),
      // iOS Background (Dark)
      scaffoldBackgroundColor: IOSTheme.darkSystemGroupedBackground,
      // iOS Dialog (Dark)
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius20),
        ),
        backgroundColor: IOSTheme.darkSecondarySystemBackground,
      ),
      // iOS Bottom Sheet (Dark)
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(IOSTheme.radius20),
            topRight: Radius.circular(IOSTheme.radius20),
          ),
        ),
        backgroundColor: IOSTheme.darkSecondarySystemBackground,
      ),
      // iOS Chip (Dark)
      chipTheme: ChipThemeData(
        backgroundColor: IOSTheme.darkTertiarySystemBackground,
        selectedColor: IOSTheme.systemCyan.withValues(alpha: 0.15),
        labelStyle: IOSTheme.subhead.copyWith(color: IOSTheme.darkLabel),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radiusFull),
        ),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final provider = context.read<AppProvider>();
    await provider.init();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              provider.isLoggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
