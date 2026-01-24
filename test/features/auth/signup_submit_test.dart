import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/timing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_error_banner.dart';
import 'package:luvi_app/router.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/test_config.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Creates a GoRouter configured for AuthSignupScreen tests.
/// Note: When used via pumpSignupScreen, disposal is handled automatically.
GoRouter _createSignupTestRouter() => GoRouter(
      routes: testAppRoutes,
      initialLocation: AuthSignupScreen.routeName,
    );

void main() {
  TestConfig.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  // Each test creates its own router instance for isolation
  // Router disposal is handled via addTearDown in pumpSignupScreen
  // Note: tester.addTearDown() is not available in Flutter 3.35.x; using global addTearDown()

  Future<void> pumpSignupScreen(
    WidgetTester tester,
    AuthRepository repository,
  ) async {
    final router = _createSignupTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Finds the inner ElevatedButton inside a WelcomeButton wrapper.
  Finder innerElevatedButton(Finder parent) {
    return find.descendant(
      of: parent,
      matching: find.byType(ElevatedButton),
    );
  }

  group('AuthSignupScreen submit behaviour', () {

    testWidgets('empty submit shows missing fields and field errors', (tester) async {
      final mockRepo = _MockAuthRepository();

      await pumpSignupScreen(tester, mockRepo);

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authSignupMissingFields), findsOneWidget);
      expect(find.text(l10n.authErrorEmailCheck), findsOneWidget);
      expect(find.text(l10n.authErrorPasswordCheck), findsOneWidget);
      expect(find.text(l10n.authErrPasswordInvalid), findsOneWidget);

      verifyNever(() => mockRepo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ));
    });

    testWidgets('successful signup navigates to login screen', (tester) async {
      // Per Auth v2 refactoring: VerificationScreen was removed,
      // signup now navigates to login screen with success snackbar
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: null, user: null));

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'strongpass',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'strongpass',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pump(); // Process tap
      await tester.pump(); // Process signup

      verify(
        () => mockRepo.signUp(
          email: 'user@example.com',
          password: 'strongpass',
          data: null,
        ),
      ).called(1);

      // Advance past the Timer delay for navigation
      await tester.pump(Timing.snackBarBrief);
      await tester.pumpAndSettle();

      // After successful signup, user is navigated to login screen
      expect(find.byKey(const ValueKey('auth_login_screen')), findsOneWidget);
    });

    testWidgets('shows API error message and re-enables CTA after failure', (
      tester,
    ) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(AuthException('Email already registered'));

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'strongpass',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'strongpass',
      );

      final buttonFinder = find.byKey(const ValueKey('signup_cta_button'));
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // AuthSignupScreen maps 'already registered' errors to L10n message
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authErrConfirmEmail), findsOneWidget);

      // WelcomeButton wraps ElevatedButton - find the inner ElevatedButton
      final innerButtonFinder = innerElevatedButton(buttonFinder);
      expect(
        innerButtonFinder,
        findsOneWidget,
        reason: 'Expected exactly one ElevatedButton inside WelcomeButton. '
            'Structure may have changed.',
      );
      final button = tester.widget<ElevatedButton>(
        innerButtonFinder,
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('displays loading spinner while submitting', (tester) async {
      final mockRepo = _MockAuthRepository();
      final completer = Completer<AuthResponse>();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) => completer.future);

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'strongpass',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'strongpass',
      );

      final buttonFinder = find.byKey(const ValueKey('signup_cta_button'));
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.byKey(const ValueKey('signup_cta_loading')), findsOneWidget);

      // WelcomeButton wraps ElevatedButton - find the inner ElevatedButton
      final innerButtonFinder = innerElevatedButton(buttonFinder);
      expect(
        innerButtonFinder,
        findsOneWidget,
        reason: 'Expected exactly one ElevatedButton inside WelcomeButton. '
            'Structure may have changed.',
      );
      final loadingButton = tester.widget<ElevatedButton>(
        innerButtonFinder,
      );
      expect(loadingButton.onPressed, isNull);

      completer.complete(AuthResponse(session: null, user: null));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('signup_cta_loading')), findsNothing);
    });

    testWidgets('shows snackbar and delays 800ms before navigation to login', (
      tester,
    ) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: null, user: null));

      await pumpSignupScreen(tester, mockRepo);

      // Fill form
      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'strongpass',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'strongpass',
      );

      // Submit
      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));

      // After API call completes, pump to show SnackBar
      await tester.pump(); // First pump: trigger setState after async completes
      await tester.pump(); // Second pump: build SnackBar overlay
      // SnackBar should be visible with correct success message
      expect(find.byType(SnackBar), findsOneWidget);
      final snackBarContext = tester.element(find.byType(SnackBar));
      final l10n = AppLocalizations.of(snackBarContext)!;
      expect(
        find.text(l10n.authSignupSuccess),
        findsOneWidget,
        reason: 'SnackBar should display the signup success message',
      );

      // Still on signup screen (delay hasn't passed)
      expect(find.byKey(const ValueKey('auth_signup_screen')), findsOneWidget);
      expect(find.byKey(const ValueKey('auth_login_screen')), findsNothing);

      // Advance past signup success navigation delay
      await tester.pump(Timing.snackBarBrief);
      await tester.pumpAndSettle();

      // Now on login screen
      expect(find.byKey(const ValueKey('auth_login_screen')), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      final mockRepo = _MockAuthRepository();
      // No mock setup needed - validation fails before API call

      await pumpSignupScreen(tester, mockRepo);

      // Fill email and mismatched passwords
      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'Password123!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'Different456!',
      );

      // Submit
      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      // Verify error message is shown (appears in both global banner and field error)
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authPasswordMismatchError), findsAtLeastNWidgets(1));

      // Verify API was NOT called (validation failed before)
      verifyNever(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      );
    });

    testWidgets('shows error when password is too short', (tester) async {
      final mockRepo = _MockAuthRepository();
      // No mock setup needed - validation fails before API call

      await pumpSignupScreen(tester, mockRepo);

      // Fill email and short password
      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'short', // < 8 characters
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'short',
      );

      // Submit
      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      // Verify error message is shown
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authErrPasswordTooShort), findsAtLeastNWidgets(1));

      // Verify API was NOT called (validation failed before)
      verifyNever(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      );
    });

    testWidgets('shows error when password is common/weak', (tester) async {
      final mockRepo = _MockAuthRepository();
      // No mock setup needed - validation fails before API call

      await pumpSignupScreen(tester, mockRepo);

      // Fill email and common weak password (blocked by _commonWeakPatterns in create_new_password_rules.dart)
      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'password123', // Common weak password (blocklisted)
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'password123',
      );

      // Submit
      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      // Verify error message is shown
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authErrPasswordCommonWeak), findsAtLeastNWidgets(1));

      // Verify API was NOT called (validation failed before)
      verifyNever(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      );
    });
  });

  group('AuthException error.code handling', () {
    testWidgets('uses error.code for weak_password', (tester) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(AuthException('Some message', code: 'weak_password'));

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'strongpass',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'strongpass',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      // Verify password error message is shown (not email)
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authErrPasswordTooShort), findsOneWidget);
      // Password field should show error, not email
      expect(find.text(l10n.authErrorPasswordCheck), findsOneWidget);
      expect(find.text(l10n.authErrorEmailCheck), findsNothing);
    });

    testWidgets('uses error.code for email_exists', (tester) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(AuthException('Some message', code: 'email_exists'));

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'strongpass',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'strongpass',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      // Verify email error message is shown
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authErrConfirmEmail), findsOneWidget);
      // Email field should show error, not password
      expect(find.text(l10n.authErrorEmailCheck), findsOneWidget);
      expect(find.text(l10n.authErrorPasswordCheck), findsNothing);
    });

    testWidgets('falls back to message matching when code is null', (tester) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(AuthException('Email already registered')); // No code

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'strongpass',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'strongpass',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      // Should still work via message fallback (contains 'already')
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authErrConfirmEmail), findsOneWidget);
    });

    testWidgets('uses error.code for user_already_exists', (tester) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(AuthException('Some message', code: 'user_already_exists'));

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'strongpass',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'strongpass',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;
      expect(find.text(l10n.authErrConfirmEmail), findsOneWidget);
    });

    testWidgets('ambiguous error without code shows banner but no field errors',
        (tester) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(AuthException('Connection timeout')); // No code, no keywords

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'ValidPass123!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'ValidPass123!',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;

      // POSITIVE: Error banner IS shown with generic message
      expect(find.byType(AuthErrorBanner), findsOneWidget);
      expect(find.text(l10n.authSignupGenericError), findsOneWidget);

      // NEGATIVE: NO field-specific error indicators
      expect(find.text(l10n.authErrorEmailCheck), findsNothing);
      expect(find.text(l10n.authErrorPasswordCheck), findsNothing);
    });

    testWidgets('rate limit error with code shows banner but no field errors',
        (tester) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        AuthException('Too many requests', code: 'over_request_rate_limit'),
      );

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'ValidPass123!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'ValidPass123!',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;

      // POSITIVE: Error banner IS shown with generic message
      expect(find.byType(AuthErrorBanner), findsOneWidget);
      expect(find.text(l10n.authSignupGenericError), findsOneWidget);

      // NEGATIVE: NO field-specific error indicators (after bug fix!)
      expect(find.text(l10n.authErrorEmailCheck), findsNothing);
      expect(find.text(l10n.authErrorPasswordCheck), findsNothing);
    });

    testWidgets('signup disabled error with code shows banner but no field errors',
        (tester) async {
      final mockRepo = _MockAuthRepository();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(AuthException('Signup is disabled', code: 'signup_disabled'));

      await pumpSignupScreen(tester, mockRepo);

      await tester.enterText(
        find.byKey(const ValueKey('signup_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'ValidPass123!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_confirm_field')),
        'ValidPass123!',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AuthSignupScreen)),
      )!;

      // Error banner shown, no field flags
      expect(find.byType(AuthErrorBanner), findsOneWidget);
      expect(find.text(l10n.authSignupGenericError), findsOneWidget);
      expect(find.text(l10n.authErrorEmailCheck), findsNothing);
      expect(find.text(l10n.authErrorPasswordCheck), findsNothing);
    });
  });
}
