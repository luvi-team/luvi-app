import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/widgets/social_auth_row.dart';
import '../../../support/test_app.dart';
import '../../../support/test_config.dart';
// Note: No Supabase usage in these tests; keep imports minimal.

// Minimum expected height when both social buttons are present in vertical layout.
// Lower-bound target for vertical layout when two providers are enabled.
// Intentionally conservative to avoid device/theme variance flakiness.
const double _expectedMinHeightForTwoButtons = 150.0;

VoidCallback _overridePlatformToIos() {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  return () {
    debugDefaultTargetPlatformOverride = null;
  };
}

void main() {
  TestConfig.ensureInitialized();
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('SocialAuthRow Widget Tests', () {
    // No repository interactions in these tests.

    testWidgets(
      'Apple button appears above Google button (both enabled)',
      (tester) async {
        final restorePlatform = _overridePlatformToIos();
        try {
          await tester.pumpWidget(
            buildLocalizedApp(
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SocialAuthRow(onGoogle: () {}, onApple: () {}),
                ),
              ),
            ),
          );

          final appleButton = find.byType(SignInWithAppleButton);
          // Use a locale-independent finder: there is exactly one Google SignInButton
          // in this widget tree; avoid relying on a localized label.
          final googleButton = find.byType(SignInButton);

          expect(appleButton, findsOneWidget);
          expect(googleButton, findsOneWidget);

          final appleY = tester.getTopLeft(appleButton).dy;
          final googleY = tester.getTopLeft(googleButton).dy;
          expect(
            appleY,
            lessThan(googleY),
            reason: 'Apple button must appear above Google button per Apple HIG',
          );

          // Note: To test single-provider scenarios, run with:
          // --dart-define=enable_google_sign_in=false or --dart-define=enable_apple_sign_in=false
        } finally {
          restorePlatform();
        }
      },
      skip:
          !(FeatureFlags.enableAppleSignIn && FeatureFlags.enableGoogleSignIn),
    );

    testWidgets('Social block height is within reserve constant (both enabled)', (
      tester,
    ) async {
      final restorePlatform = _overridePlatformToIos();
      try {
        await tester.pumpWidget(
          buildLocalizedApp(
            // Use IntrinsicHeight to measure the widget's intrinsic height
            home: Center(
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SocialAuthRow(onGoogle: () {}, onApple: () {}),
                ),
              ),
            ),
          ),
        );

        final socialAuthRow = find.byType(SocialAuthRow);
        expect(socialAuthRow, findsOneWidget);

        final actualHeight = tester.getSize(socialAuthRow).height;
        expect(
          actualHeight,
          lessThanOrEqualTo(AuthLayout.socialBlockReserveFallback),
          reason:
              'Actual height ($actualHeight dp) must fit within reserve (${AuthLayout.socialBlockReserveFallback} dp)',
        );
        // Assert lower bound sanity
        expect(
          actualHeight,
          greaterThan(_expectedMinHeightForTwoButtons),
          reason: 'Height should exceed a conservative 150dp bound',
        );
      } finally {
        restorePlatform();
      }
    },
    skip: !(FeatureFlags.enableAppleSignIn && FeatureFlags.enableGoogleSignIn),
    );

    testWidgets(
      'Apple-only variant (enable_apple_sign_in=true, enable_google_sign_in=false)',
      (tester) async {
        final restorePlatform = _overridePlatformToIos();
        try {
          await tester.pumpWidget(
            buildLocalizedApp(
              home: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SocialAuthRow(onGoogle: () {}, onApple: () {}),
                ),
              ),
            ),
          );

          expect(find.byType(SignInWithAppleButton), findsOneWidget);
          expect(find.byType(SignInButton), findsNothing);
        } finally {
          restorePlatform();
        }
      },
      skip:
          !(FeatureFlags.enableAppleSignIn && !FeatureFlags.enableGoogleSignIn),
    );

    testWidgets(
      'Google-only variant (enable_google_sign_in=true, enable_apple_sign_in=false)',
      (tester) async {
        final restorePlatform = _overridePlatformToIos();
        try {
          await tester.pumpWidget(
            buildLocalizedApp(
              home: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SocialAuthRow(onGoogle: () {}, onApple: () {}),
                ),
              ),
            ),
          );

          expect(find.byType(SignInWithAppleButton), findsNothing);
          expect(find.byType(SignInButton), findsOneWidget);
        } finally {
          restorePlatform();
        }
      },
      skip:
          !(FeatureFlags.enableGoogleSignIn && !FeatureFlags.enableAppleSignIn),
    );

    // Note: LoginScreen no longer contains SocialAuthRow (moved to AuthSignInScreen)
    // Integration test for keyboard overflow was removed during Auth v2 refactoring.
  });
}
