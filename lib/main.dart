import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/language_provider.dart';
import 'services/admob_service.dart';
import 'utils/app_logger.dart';
import 'package:logging/logging.dart' as logging;
import 'theme/ios_theme.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          final languageProvider = ref.watch(languageProviderProvider);
          final themeProvider = ref.watch(themeProviderProvider);

          return MaterialApp.router(
            title: 'Tirikchilik',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: appRouter,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('uz'), // O'zbek
              Locale('ru'), // Русский
              Locale('en'), // English
            ],
            locale: languageProvider,
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
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
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
        ),
        color: IOSTheme.systemBackground,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      dialogTheme: DialogThemeData(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
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
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
        ),
        color: IOSTheme.darkSecondarySystemBackground,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        hintStyle: IOSTheme.body.copyWith(color: IOSTheme.darkTertiaryLabel),
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
      dialogTheme: DialogThemeData(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
