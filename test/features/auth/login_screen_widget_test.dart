import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../support/test_config.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestConfig.ensureInitialized();
  setUpAll(() {
    // Register fallback values if needed in the future
  });

  testWidgets('Login shows error on invalid credentials', (tester) async {
    // Make the test device large enough to avoid overflow/scrolling issues
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final mockRepo = _MockAuthRepository();
    when(
      () => mockRepo.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(AuthException('Invalid login credentials', code: 'invalid_credentials'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const LoginScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );

    // Enter email and password
    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    await tester.enterText(emailField, 'user@example.com');
    // Ensure we pass client-side min length (8) so server-side invalid
    // credentials path is exercised.
    await tester.enterText(passwordField, 'wrongpass');
    // Allow UI to rebuild so the CTA enables (validation cleared)
    await tester.pump();

    // Tap the CTA button (AuthPrimaryButton wraps ElevatedButton)
    final buttonFinder = find.byKey(const ValueKey('login_cta_button'));
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Expect error message from invalid credentials handling
    // LoginScreen shows l10n.authInvalidCredentials when emailError is set
    final l10n = AppLocalizations.of(tester.element(find.byType(LoginScreen)))!;
    // SSOT P0.7: Both fields show error on invalid credentials -> findsNWidgets(2)
    expect(find.text(l10n.authInvalidCredentials), findsNWidgets(2));

    // Auth Rebrand v3: Button stays enabled after errors (allows retry)
    final innerButton = find.descendant(
      of: buttonFinder,
      matching: find.byType(ElevatedButton),
    );
    expect(innerButton, findsOneWidget);
    final btn = tester.widget<ElevatedButton>(innerButton);
    expect(btn.onPressed, isNotNull);
  });

  testWidgets('CTA shows spinner while loading and re-enables after success', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final mockRepo = _MockAuthRepository();
    final completer = Completer<AuthResponse>();
    when(
      () => mockRepo.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const LoginScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );

    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);
    await tester.enterText(emailField, 'user@example.com');
    await tester.enterText(passwordField, 'correctpw');

    final buttonFinder = find.byKey(const ValueKey('login_cta_button'));
    await tester.tap(buttonFinder);
    await tester.pump(); // start async call -> loading state

    expect(find.byKey(const ValueKey('login_cta_loading')), findsOneWidget);
    final innerButton = find.descendant(
      of: buttonFinder,
      matching: find.byType(ElevatedButton),
    );
    expect(innerButton, findsOneWidget);
    final loadingBtn = tester.widget<ElevatedButton>(innerButton);
    expect(loadingBtn.onPressed, isNull);

    // Resolve the future with a dummy response so the notifier clears loading state.
    completer.complete(AuthResponse(session: null, user: null));
    await tester.pumpAndSettle();

    // After loading completes, button text should be visible again
    final enabledBtn = tester.widget<ElevatedButton>(innerButton);
    expect(enabledBtn.onPressed, isNotNull);
  });

  testWidgets('Shows validation errors on empty submit', (tester) async {
    // Per Auth v2 refactoring: GlobalErrorBanner was removed from LoginScreen.
    // Error handling now uses FieldErrorText and inline error display.
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final mockRepo = _MockAuthRepository();
    when(
      () => mockRepo.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(AuthException('Invalid login credentials', code: 'invalid_credentials'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const LoginScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );

    // Submit with empty fields to trigger validation errors
    final buttonFinder = find.byKey(const ValueKey('login_cta_button'));
    await tester.tap(buttonFinder);
    await tester.pump();

    // Validation errors should appear for empty fields
    // LoginScreen now shows specific L10n error messages (empty email/password)
    final l10n = AppLocalizations.of(tester.element(find.byType(LoginScreen)))!;
    expect(find.text(l10n.authErrEmailEmpty), findsOneWidget);
    expect(find.text(l10n.authErrPasswordEmpty), findsOneWidget);

    // Auth Rebrand v3: Button stays enabled even with errors (allows retry)
    final innerButton = find.descendant(
      of: buttonFinder,
      matching: find.byType(ElevatedButton),
    );
    expect(innerButton, findsOneWidget);
    final btn = tester.widget<ElevatedButton>(innerButton);
    expect(btn.onPressed, isNotNull);
  });
}
