
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/widgets/social_auth_row.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_app.dart';
import '../../../support/test_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _MockAuthRepository extends Mock implements AuthRepository {}

// Use FakeViewPadding from flutter_test (imported above)

void main() {
  TestConfig.ensureInitialized();

  group('SocialAuthRow Widget Tests', () {
    late _MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(supa.AuthException('invalid credentials'));
    });

    testWidgets('Apple button appears above Google button (both enabled)',
        (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SocialAuthRow(
                onGoogle: () {},
                onApple: () {},
              ),
            ),
          ),
        ),
      );

      final appleButton = find.byType(SignInWithAppleButton);
      final googleButton = find.widgetWithText(SignInButton, 'Mit Google anmelden');

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
    }, skip: !(FeatureFlags.enableAppleSignIn && FeatureFlags.enableGoogleSignIn));

    testWidgets('Social block height is within reserve constant (both enabled)',
        (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          // Use IntrinsicHeight to measure the widget's intrinsic height
          home: Center(
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SocialAuthRow(
                  onGoogle: () {},
                  onApple: () {},
                ),
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
        lessThanOrEqualTo(AuthLayout.socialBlockReserveApprox),
        reason:
            'Actual height ($actualHeight dp) must fit within reserve (${AuthLayout.socialBlockReserveApprox} dp)',
      );
      // Assert lower bound sanity only when both providers are enabled
      if (FeatureFlags.enableAppleSignIn && FeatureFlags.enableGoogleSignIn) {
        expect(
          actualHeight,
          greaterThan(150.0),
          reason:
              'Height should be ~173dp for vertical layout with both buttons',
        );
      }
    });

    testWidgets(
      'Apple-only variant (enable_apple_sign_in=true, enable_google_sign_in=false)',
      (tester) async {
        await tester.pumpWidget(
        buildLocalizedApp(
          home: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SocialAuthRow(
                onGoogle: () {},
                onApple: () {},
              ),
            ),
          ),
        ),
        );

        expect(find.byType(SignInWithAppleButton), findsOneWidget);
        expect(find.byType(SignInButton), findsNothing);
      },
      skip: !(FeatureFlags.enableAppleSignIn && !FeatureFlags.enableGoogleSignIn),
    );

    testWidgets(
      'Google-only variant (enable_google_sign_in=true, enable_apple_sign_in=false)',
      (tester) async {
        await tester.pumpWidget(
        buildLocalizedApp(
          home: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SocialAuthRow(
                onGoogle: () {},
                onApple: () {},
              ),
            ),
          ),
        ),
        );

        expect(find.byType(SignInWithAppleButton), findsNothing);
        expect(find.byType(SignInButton), findsOneWidget);
      },
      skip: !(FeatureFlags.enableGoogleSignIn && !FeatureFlags.enableAppleSignIn),
    );

    testWidgets('No overflow when keyboard is visible on LoginScreen (integration test)',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.buildAppTheme(),
            home: const LoginScreen(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).first;
      expect(emailField, findsOneWidget);

      await tester.tap(emailField);
      await tester.pumpAndSettle();

      await tester.showKeyboard(emailField);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300.0);
      addTearDown(() {
        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason: 'No overflow exception should occur when keyboard is visible',
      );

      final socialAuthRow = find.byType(SocialAuthRow);
      expect(socialAuthRow, findsOneWidget);
      await tester.ensureVisible(socialAuthRow);
      await tester.pumpAndSettle();
      expect(
        socialAuthRow,
        findsOneWidget,
        reason: 'Social buttons should remain accessible via scrolling',
      );
    });
  });
}
