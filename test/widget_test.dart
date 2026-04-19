import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tirikchilik/main.dart';
import 'package:tirikchilik/providers/app_provider.dart';
import 'package:tirikchilik/services/shared_preferences_service.dart';

// Test-specific AppNotifier that skips async init
class TestAppNotifier extends AppNotifier {
  TestAppNotifier() : super();

  @override
  Future<void> init() async {
    // Skip initialization in tests to avoid platform-specific services
  }
}

void main() {
  testWidgets('App smoke test - builds without errors', (
    WidgetTester tester,
  ) async {
    // Setup mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesService.instance.initialize();

    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appProviderProvider.overrideWith((ref) => TestAppNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    // Initial build
    await tester.pump();

    // Verify that the app built successfully by finding MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);

    // Let splash screen timer complete to avoid pending timer exception
    await tester.pump(const Duration(seconds: 3));
  });
}
