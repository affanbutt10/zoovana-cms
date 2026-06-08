import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/core/utils/validators.dart';

void main() {
  // ---------------------------------------------------------------------------
  // 19.10 Unit tests for Validators with specific examples
  // ---------------------------------------------------------------------------

  group('Validators — unit tests', () {
    group('required', () {
      test('returns error for empty string', () {
        expect(Validators.required(''), isNotNull);
      });

      test('returns error for null', () {
        expect(Validators.required(null), isNotNull);
      });

      test('returns error for whitespace-only string', () {
        expect(Validators.required('   '), isNotNull);
      });

      test('returns error for tab-only string', () {
        expect(Validators.required('\t'), isNotNull);
      });

      test('returns null for non-empty string', () {
        expect(Validators.required('hello'), isNull);
      });

      test('returns null for string with leading/trailing spaces but content',
          () {
        expect(Validators.required('  hello  '), isNull);
      });
    });

    group('email', () {
      test('returns null for valid email: user@example.com', () {
        expect(Validators.email('user@example.com'), isNull);
      });

      test('returns null for valid email with subdomain', () {
        expect(Validators.email('user@mail.example.com'), isNull);
      });

      test('returns null for valid email with plus sign', () {
        expect(Validators.email('user+tag@example.org'), isNull);
      });

      test('returns null for valid email with dots in local part', () {
        expect(Validators.email('first.last@example.co.uk'), isNull);
      });

      test('returns error for email without @', () {
        expect(Validators.email('userexample.com'), isNotNull);
      });

      test('returns error for email without domain', () {
        expect(Validators.email('user@'), isNotNull);
      });

      test('returns error for email without TLD', () {
        expect(Validators.email('user@example'), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.email(''), isNotNull);
      });

      test('returns error for null', () {
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for plain text', () {
        expect(Validators.email('notanemail'), isNotNull);
      });
    });

    group('phone', () {
      test('returns null for valid phone: +1 (555) 123-4567', () {
        expect(Validators.phone('+1 (555) 123-4567'), isNull);
      });

      test('returns null for valid phone: 0712345678', () {
        expect(Validators.phone('0712345678'), isNull);
      });

      test('returns null for valid international phone: +447911123456', () {
        expect(Validators.phone('+447911123456'), isNull);
      });

      test('returns error for empty string', () {
        expect(Validators.phone(''), isNotNull);
      });

      test('returns error for null', () {
        expect(Validators.phone(null), isNotNull);
      });

      test('returns error for too-short number: 123', () {
        expect(Validators.phone('123'), isNotNull);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // 19.6 Property 5: Validator rejects blank inputs
  // Feature: zoovana-cms-architecture, Property 5: whitespace-only strings →
  // required returns non-null
  // ---------------------------------------------------------------------------

  group('Property 5 — Validator rejects blank inputs', () {
    test(
      'required returns non-null for any whitespace-only string (100 iterations)',
      () {
        // Feature: zoovana-cms-architecture, Property 5: for any string
        // composed entirely of whitespace characters (including the empty
        // string), Validators.required must return a non-null error string.
        final random = Random(42);
        const whitespaceChars = [' ', '\t', '\n', '\r'];

        for (var i = 0; i < 100; i++) {
          // Generate a whitespace-only string of length 0–20.
          final length = random.nextInt(21); // 0 to 20 inclusive
          final buffer = StringBuffer();
          for (var j = 0; j < length; j++) {
            buffer.write(
              whitespaceChars[random.nextInt(whitespaceChars.length)],
            );
          }
          final input = buffer.toString();

          final result = Validators.required(input);
          expect(
            result,
            isNotNull,
            reason:
                'Iteration $i: expected non-null for whitespace-only '
                'string "${input.replaceAll('\n', '\\n').replaceAll('\t', '\\t')}"',
          );
        }
      },
    );
  });

  // ---------------------------------------------------------------------------
  // 19.7 Property 6: Validator email
  // Feature: zoovana-cms-architecture, Property 6: valid emails → null;
  // invalid emails → non-null
  // ---------------------------------------------------------------------------

  group('Property 6 — Validator email', () {
    test(
      'email returns null for valid email addresses (100 iterations)',
      () {
        // Feature: zoovana-cms-architecture, Property 6: for any string
        // matching the standard email format local@domain.tld,
        // Validators.email must return null.
        final random = Random(42);

        // Pool of valid local parts, domains, and TLDs.
        const localParts = [
          'user',
          'first.last',
          'user+tag',
          'admin',
          'test123',
          'a.b.c',
          'hello_world',
        ];
        const domains = [
          'example',
          'mail',
          'test',
          'mysite',
          'company',
          'zoovana',
        ];
        const tlds = ['com', 'org', 'net', 'io', 'co.uk', 'dev', 'app'];

        for (var i = 0; i < 100; i++) {
          final local = localParts[random.nextInt(localParts.length)];
          final domain = domains[random.nextInt(domains.length)];
          final tld = tlds[random.nextInt(tlds.length)];
          final email = '$local@$domain.$tld';

          final result = Validators.email(email);
          expect(
            result,
            isNull,
            reason: 'Iteration $i: expected null for valid email "$email"',
          );
        }
      },
    );

    test(
      'email returns non-null for invalid email addresses (100 iterations)',
      () {
        // Feature: zoovana-cms-architecture, Property 6: for any string that
        // does not match the standard email format, Validators.email must
        // return a non-null error string.
        final random = Random(99);

        // Pool of clearly invalid email patterns.
        const invalidEmails = [
          'notanemail',
          'missing@tld',
          '@nodomain.com',
          'no-at-sign',
          'double@@example.com',
          'spaces in@email.com',
          'user@',
          '',
          'user@.com',
          'user@domain.',
          'plaintext',
          '12345',
          '@',
        ];

        for (var i = 0; i < 100; i++) {
          final email = invalidEmails[random.nextInt(invalidEmails.length)];

          final result = Validators.email(email);
          expect(
            result,
            isNotNull,
            reason:
                'Iteration $i: expected non-null for invalid email "$email"',
          );
        }
      },
    );
  });
}
