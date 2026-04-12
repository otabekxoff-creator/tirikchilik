import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tirikchilik/main.dart';
import 'package:tirikchilik/screens/login_screen.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));

      // Wait for initialization
      await tester.pumpAndSettle();

      // App should render without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login screen has required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Check for email/phone field
      expect(find.byType(TextField), findsWidgets);

      // Check for login button
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Validators work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: TextField(
                    decoration: InputDecoration(
                      errorText: _validateEmail('invalid-email'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Noto\'g\'ri email format'), findsOneWidget);
    });
  });
}

String? _validateEmail(String value) {
  if (value.isEmpty) {
    return 'Email kiriting';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Noto\'g\'ri email format';
  }
  return null;
}
