import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/utils/oauth_cancellation.dart';

void main() {
  group('isOAuthUserCancellation', () {
    group('positive cases - should detect cancellation', () {
      test('detects generic "cancel" keyword', () {
        expect(isOAuthUserCancellation('User did cancel the operation'), isTrue);
        expect(isOAuthUserCancellation('CANCEL'), isTrue);
        expect(isOAuthUserCancellation('Cancel'), isTrue);
      });

      test('detects "canceled" (US spelling)', () {
        expect(isOAuthUserCancellation('Operation was canceled'), isTrue);
        expect(isOAuthUserCancellation('CANCELED'), isTrue);
        expect(isOAuthUserCancellation('Canceled by user'), isTrue);
      });

      test('detects "cancelled" (UK spelling)', () {
        expect(isOAuthUserCancellation('Operation was cancelled'), isTrue);
        expect(isOAuthUserCancellation('CANCELLED'), isTrue);
        expect(isOAuthUserCancellation('Cancelled by user'), isTrue);
      });

      test('detects "aborted"', () {
        expect(isOAuthUserCancellation('User aborted the flow'), isTrue);
        expect(isOAuthUserCancellation('ABORTED'), isTrue);
        expect(isOAuthUserCancellation('Request aborted'), isTrue);
      });

      // PlatformException variants
      group('PlatformException patterns', () {
        test('detects PlatformException CANCELED', () {
          expect(
            isOAuthUserCancellation(
              'PlatformException(CANCELED, The user canceled the sign-in flow., null, null)',
            ),
            isTrue,
          );
        });

        test('detects PlatformException canceled (lowercase)', () {
          expect(
            isOAuthUserCancellation(
              'PlatformException(canceled, user canceled, null)',
            ),
            isTrue,
          );
        });
      });

      // google_sign_in patterns
      group('google_sign_in patterns', () {
        test('detects sign_in_canceled', () {
          expect(isOAuthUserCancellation('sign_in_canceled'), isTrue);
        });

        test('detects sign_in_canceled in error message', () {
          expect(
            isOAuthUserCancellation(
              'PlatformException(sign_in_canceled, The user canceled the sign-in flow.)',
            ),
            isTrue,
          );
        });

        test('detects sign in canceled (with spaces)', () {
          expect(isOAuthUserCancellation('sign in canceled'), isTrue);
        });
      });

      // flutter_web_auth patterns
      group('flutter_web_auth patterns', () {
        test('detects user cancelled', () {
          expect(isOAuthUserCancellation('user cancelled'), isTrue);
          expect(isOAuthUserCancellation('User cancelled the login'), isTrue);
        });

        test('detects user_cancelled (with underscore)', () {
          expect(isOAuthUserCancellation('user_cancelled'), isTrue);
        });

        test('detects user_canceled', () {
          expect(isOAuthUserCancellation('user_canceled'), isTrue);
        });
      });

      // oauth2_client patterns
      group('oauth2_client patterns', () {
        test('detects ERR_REQUEST_CANCELED', () {
          expect(isOAuthUserCancellation('ERR_REQUEST_CANCELED'), isTrue);
        });

        test('detects err_request_canceled (lowercase)', () {
          expect(isOAuthUserCancellation('err_request_canceled'), isTrue);
        });

        test('detects err request canceled (with spaces)', () {
          expect(isOAuthUserCancellation('err request canceled'), isTrue);
        });
      });

      // ASWebAuthSession (iOS) patterns
      group('ASWebAuthSession (iOS) patterns', () {
        test('detects ASWebAuthenticationSession cancelled', () {
          expect(
            isOAuthUserCancellation(
              'ASWebAuthenticationSessionError cancelled',
            ),
            isTrue,
          );
        });

        test('detects iOS user cancelled error', () {
          expect(
            isOAuthUserCancellation('The user cancelled the login flow'),
            isTrue,
          );
        });
      });

      // Chrome Custom Tabs (Android) patterns
      group('Chrome Custom Tabs (Android) patterns', () {
        test('detects Chrome Custom Tabs canceled', () {
          expect(
            isOAuthUserCancellation('Chrome Custom Tabs operation canceled'),
            isTrue,
          );
        });

        test('detects user aborted in Android', () {
          expect(isOAuthUserCancellation('User aborted authentication'), isTrue);
        });
      });

      // Case insensitivity tests
      group('case insensitivity', () {
        test('detects mixed case variations', () {
          expect(isOAuthUserCancellation('CANCELED'), isTrue);
          expect(isOAuthUserCancellation('Canceled'), isTrue);
          expect(isOAuthUserCancellation('canceled'), isTrue);
          expect(isOAuthUserCancellation('CaNcElEd'), isTrue);
        });

        test('detects CANCELLED in all caps', () {
          expect(isOAuthUserCancellation('CANCELLED'), isTrue);
          expect(isOAuthUserCancellation('Cancelled'), isTrue);
          expect(isOAuthUserCancellation('cancelled'), isTrue);
        });
      });

      // Underscore/space variants
      group('underscore and space variants', () {
        test('treats underscores as spaces', () {
          expect(isOAuthUserCancellation('user_canceled'), isTrue);
          expect(isOAuthUserCancellation('user canceled'), isTrue);
          expect(isOAuthUserCancellation('user_cancelled'), isTrue);
          expect(isOAuthUserCancellation('user cancelled'), isTrue);
        });

        test('handles mixed underscore/space patterns', () {
          expect(isOAuthUserCancellation('sign_in_canceled'), isTrue);
          expect(isOAuthUserCancellation('sign in canceled'), isTrue);
        });
      });
    });

    group('negative cases - should NOT detect cancellation', () {
      test('does not detect generic errors', () {
        expect(isOAuthUserCancellation('Network error'), isFalse);
        expect(isOAuthUserCancellation('Server error 500'), isFalse);
        expect(isOAuthUserCancellation('Invalid credentials'), isFalse);
      });

      test('does not detect authentication failures', () {
        expect(isOAuthUserCancellation('Invalid token'), isFalse);
        expect(isOAuthUserCancellation('Token expired'), isFalse);
        expect(isOAuthUserCancellation('Unauthorized'), isFalse);
        expect(isOAuthUserCancellation('Access denied'), isFalse);
      });

      test('does not detect timeout errors', () {
        expect(isOAuthUserCancellation('Request timeout'), isFalse);
        expect(isOAuthUserCancellation('Connection timed out'), isFalse);
      });

      test('does not detect similar but non-cancellation words', () {
        // Words that contain partial matches but aren't cancellations
        expect(isOAuthUserCancellation('scandal'), isFalse);
        expect(isOAuthUserCancellation('scant'), isFalse);
      });

      test('does not detect empty string', () {
        expect(isOAuthUserCancellation(''), isFalse);
      });

      test('does not detect whitespace only', () {
        expect(isOAuthUserCancellation('   '), isFalse);
      });

      test('does not detect rate limiting errors', () {
        expect(isOAuthUserCancellation('Rate limit exceeded'), isFalse);
        expect(isOAuthUserCancellation('Too many requests'), isFalse);
      });

      test('does not detect configuration errors', () {
        expect(isOAuthUserCancellation('Invalid client_id'), isFalse);
        expect(isOAuthUserCancellation('Redirect URI mismatch'), isFalse);
        expect(isOAuthUserCancellation('OAuth configuration error'), isFalse);
      });

      test('does not detect SSL/TLS errors', () {
        expect(isOAuthUserCancellation('SSL handshake failed'), isFalse);
        expect(isOAuthUserCancellation('Certificate error'), isFalse);
      });
    });

    group('edge cases', () {
      test('handles very long error messages', () {
        final longMessage = '${'A' * 1000} canceled ${'B' * 1000}';
        expect(isOAuthUserCancellation(longMessage), isTrue);
      });

      test('handles special characters in error message', () {
        expect(
          isOAuthUserCancellation('Error: user canceled! @#\$%'),
          isTrue,
        );
      });

      test('handles newlines in error message', () {
        expect(
          isOAuthUserCancellation('Error\nUser canceled\nPlease try again'),
          isTrue,
        );
      });

      test('handles unicode in error message', () {
        expect(isOAuthUserCancellation('Benutzer hat canceled 你好'), isTrue);
      });
    });
  });

  group('logNonCancellationOAuthError', () {
    // Note: These tests verify the function doesn't throw.
    // Actual log output is tested via integration tests or log capture.

    test('does not throw for non-cancellation error', () {
      expect(
        () => logNonCancellationOAuthError('Network error'),
        returnsNormally,
      );
    });

    test('does not throw for cancellation error', () {
      expect(
        () => logNonCancellationOAuthError('User canceled'),
        returnsNormally,
      );
    });

    test('does not throw with provider parameter', () {
      expect(
        () => logNonCancellationOAuthError('Network error', provider: 'google'),
        returnsNormally,
      );
    });

    test('does not throw with null provider', () {
      expect(
        () => logNonCancellationOAuthError('Network error', provider: null),
        returnsNormally,
      );
    });
  });
}
