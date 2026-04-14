import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/language_provider.dart';
import 'providers/app_provider.dart';
import 'core/app_initializer.dart';
import 'theme/ios_theme.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize app
    await AppInitializer.initialize();

    runApp(
      ProviderScope(
        overrides: [appProviderProvider.overrideWith((ref) => AppNotifier())],
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    // Show error if initialization fails
    runApp(ErrorApp(error: e.toString(), stackTrace: stack.toString()));
  }
}

// Error display widget for startup failures
class ErrorApp extends StatelessWidget {
  final String error;
  final String stackTrace;

  const ErrorApp({super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Ishga tushirishda xatolik:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(error, style: const TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Stack Trace:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Text(
                      stackTrace,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageProvider = ref.watch(languageProviderProvider);
    final themeProvider = ref.watch(themeProviderProvider);

    return MaterialApp.router(
      title: 'Tirikchilik',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
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
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
      appBarTheme: IOSTheme.iosAppBar,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
        ),
        color: IOSTheme.systemBackground,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: IOSTheme.filledButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: IOSTheme.outlinedButtonStyle,
      ),
      textButtonTheme: TextButtonThemeData(style: IOSTheme.textButtonStyle),
      inputDecorationTheme: IOSTheme.iosInputTheme,
      bottomNavigationBarTheme: IOSTheme.iosNavBar,
      dividerTheme: const DividerThemeData(
        color: IOSTheme.separator,
        thickness: 0.5,
        space: 0.5,
      ),
      scaffoldBackgroundColor: IOSTheme.systemGroupedBackground,
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius20),
        ),
        backgroundColor: IOSTheme.systemBackground,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(IOSTheme.radius20),
            topRight: Radius.circular(IOSTheme.radius20),
          ),
        ),
        backgroundColor: IOSTheme.systemBackground,
      ),
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
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: IOSTheme.darkSystemBackground,
        foregroundColor: IOSTheme.systemCyan,
        titleTextStyle: IOSTheme.headline.copyWith(color: IOSTheme.darkLabel),
        toolbarHeight: 44,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius16),
        ),
        color: IOSTheme.darkSecondarySystemBackground,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: IOSTheme.darkSystemBackground,
        selectedItemColor: IOSTheme.systemCyan,
        unselectedItemColor: IOSTheme.systemGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: IOSTheme.caption2,
        unselectedLabelStyle: IOSTheme.caption2,
      ),
      dividerTheme: const DividerThemeData(
        color: IOSTheme.darkSeparator,
        thickness: 0.5,
        space: 0.5,
      ),
      scaffoldBackgroundColor: IOSTheme.darkSystemGroupedBackground,
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IOSTheme.radius20),
        ),
        backgroundColor: IOSTheme.darkSecondarySystemBackground,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(IOSTheme.radius20),
            topRight: Radius.circular(IOSTheme.radius20),
          ),
        ),
        backgroundColor: IOSTheme.darkSecondarySystemBackground,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: IOSTheme.darkTertiarySystemBackground,
        selectedColor: IOSTheme.systemCyan.withValues(alpha: 0.15),
        labelStyle: IOSTheme.subhead.copyWith(color: IOSTheme.darkLabel),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
