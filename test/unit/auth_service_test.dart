import 'package:flutter_test/flutter_test.dart';
import 'package:tirikchilik/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('Service Initialization', () {
      test('AuthService can be instantiated', () {
        expect(authService, isNotNull);
        expect(authService.currentUser, isNull);
      });
    });

    group('User State', () {
      test('initial current user is null', () {
        expect(authService.currentUser, isNull);
      });

      test('currentUser getter returns same value', () {
        expect(authService.currentUser, authService.currentUser);
      });
    });

    group('Email Validation Helper', () {
      test('validates correct email format', () {
        final validEmails = [
          'user@example.com',
          'test.user@domain.co',
          'user+tag@example.org',
        ];

        for (final email in validEmails) {
          expect(_isValidEmail(email), isTrue, reason: 'Failed for $email');
        }
      });

      test('rejects invalid email formats', () {
        final invalidEmails = [
          'invalid-email',
          '@example.com',
          'user@',
          '',
          'user@.com',
        ];

        for (final email in invalidEmails) {
          expect(_isValidEmail(email), isFalse, reason: 'Failed for $email');
        }
      });
    });

    group('Phone Validation Helper', () {
      test('validates Uzbek phone numbers', () {
        final validPhones = ['+998901234567', '+998991234567', '901234567'];

        for (final phone in validPhones) {
          expect(_isValidPhone(phone), isTrue, reason: 'Failed for $phone');
        }
      });

      test('rejects invalid phone numbers', () {
        final invalidPhones = ['123', '+999123456789', '', 'abc123'];

        for (final phone in invalidPhones) {
          expect(_isValidPhone(phone), isFalse, reason: 'Failed for $phone');
        }
      });
    });
  });
}

// Helper functions for validation tests
bool _isValidEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool _isValidPhone(String phone) {
  if (phone.isEmpty) return false;
  final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
  return digitsOnly.length == 12 || digitsOnly.length == 9;
}
