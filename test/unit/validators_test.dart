import 'package:flutter_test/flutter_test.dart';
import 'package:tirikchilik/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Email Validation', () {
      test('validates correct email addresses', () {
        final validEmails = [
          'test@example.com',
          'user.name@domain.co',
          'user+tag@example.org',
          'firstname-lastname@company.net',
        ];

        for (final email in validEmails) {
          final result = Validators.validateEmail(email);
          expect(result, isNull, reason: 'Should accept: $email');
        }
      });

      test('rejects invalid email addresses', () {
        final invalidEmails = [
          '',
          'plainaddress',
          '@missingusername.com',
          'username@.com',
          'username@domain',
          'username@domain..com',
          'username@.domain.com',
        ];

        for (final email in invalidEmails) {
          final result = Validators.validateEmail(email);
          expect(result, isNotNull, reason: 'Should reject: $email');
        }
      });

      test('rejects null email', () {
        final result = Validators.validateEmail(null);
        expect(result, isNotNull);
      });
    });

    group('Phone Validation', () {
      test('validates Uzbek phone numbers', () {
        final validPhones = [
          '+998901234567',
          '+998991234567',
          '+998331234567',
          '901234567',
          '991234567',
        ];

        for (final phone in validPhones) {
          final result = Validators.validatePhone(phone);
          expect(result, isNull, reason: 'Should accept: $phone');
        }
      });

      test('rejects invalid phone numbers', () {
        final invalidPhones = [
          '',
          '123',
          'abcdefghij',
          '+999123456789',
          '+99812345',
          '998901234567',
        ];

        for (final phone in invalidPhones) {
          final result = Validators.validatePhone(phone);
          expect(result, isNotNull, reason: 'Should reject: $phone');
        }
      });

      test('rejects null phone', () {
        final result = Validators.validatePhone(null);
        expect(result, isNotNull);
      });
    });

    group('Password Validation', () {
      test('validates strong passwords', () {
        final validPasswords = ['StrongP@ss1', 'MyP@ssw0rd!', 'C0mplex@123'];

        for (final password in validPasswords) {
          final result = Validators.validatePassword(password);
          expect(result, isNull, reason: 'Should accept: $password');
        }
      });

      test('rejects weak passwords', () {
        final weakPasswords = [
          '',
          '123',
          'password',
          'PASSWORD',
          'Password',
          'Pass1',
        ];

        for (final password in weakPasswords) {
          final result = Validators.validatePassword(password);
          expect(result, isNotNull, reason: 'Should reject: $password');
        }
      });

      test('validates minimum password length of 6', () {
        final result = Validators.validatePassword('Short');
        expect(result, isNotNull);
        expect(result, contains('6'));
      });
    });

    group('Name Validation', () {
      test('validates correct names', () {
        final validNames = [
          'John',
          'Jane Doe',
          'Otabek',
          'Александр',
          'العربية',
        ];

        for (final name in validNames) {
          final result = Validators.validateName(name);
          expect(result, isNull, reason: 'Should accept: $name');
        }
      });

      test('rejects invalid names', () {
        final invalidNames = ['', '   ', 'A', '123', '@John'];

        for (final name in invalidNames) {
          final result = Validators.validateName(name);
          expect(result, isNotNull, reason: 'Should reject: $name');
        }
      });

      test('validates minimum name length of 2', () {
        final result = Validators.validateName('A');
        expect(result, isNotNull);
        expect(result, contains('2'));
      });
    });

    group('Amount Validation', () {
      test('validates positive amounts', () {
        final validAmounts = ['10', '10.5', '0.01', '1000'];

        for (final amount in validAmounts) {
          final result = Validators.validateAmount(amount, 10000);
          expect(result, isNull, reason: 'Should accept: $amount');
        }
      });

      test('rejects invalid amounts', () {
        final invalidAmounts = ['', '0', '-10', 'abc', '10.5.5'];

        for (final amount in invalidAmounts) {
          final result = Validators.validateAmount(amount, 10000);
          expect(result, isNotNull, reason: 'Should reject: $amount');
        }
      });

      test('validates maximum amount constraint', () {
        final result = Validators.validateAmount('15000', 10000);
        expect(result, isNotNull);
        expect(result, contains('10000'));
      });
    });
  });
}
