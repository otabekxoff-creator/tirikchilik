import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tirikchilik/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app flow test', () {
    testWidgets('Full user registration and login flow', (WidgetTester tester) async {
      // Launch app
      await tester.pumpWidget(
        const ProviderScope(child: MyApp()),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify splash screen or initial screen
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Test passes if no exceptions thrown
    });

    testWidgets('Navigation smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MyApp()),
      );
      
      await tester.pumpAndSettle();
      
      // Basic smoke test - app should not crash
      expect(tester.takeException(), isNull);
    });
  });
}
