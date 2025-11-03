import 'dart:async';
import '../../support/test_config.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/widgets/global_error_banner.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

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
    ).thenThrow(AuthException('invalid credentials'));

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

    // Tap the CTA button
    final loginButton = find.widgetWithText(
      ElevatedButton,
      AuthStrings.loginCta,
    );
    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Expect error message from invalid credentials handling
    expect(find.text(AuthStrings.invalidCredentials), findsOneWidget);

    // Button should be disabled because validation errors are present
    final btn = tester.widget<ElevatedButton>(loginButton);
    expect(btn.onPressed, isNull);
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

    final loginButton = find.byType(ElevatedButton);
    await tester.tap(loginButton);
    await tester.pump(); // start async call -> loading state

    expect(find.byKey(const ValueKey('login_cta_loading')), findsOneWidget);
    final loadingBtn = tester.widget<ElevatedButton>(loginButton);
    expect(loadingBtn.onPressed, isNull);

    // Resolve the future with a dummy response so the notifier clears loading state.
    completer.complete(AuthResponse(session: null, user: null));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login_cta_label')), findsOneWidget);
    final enabledBtn = tester.widget<ElevatedButton>(loginButton);
    expect(enabledBtn.onPressed, isNotNull);
  });

  testWidgets(
    'Global error banner clears on new input while field errors stay',
    (tester) async {
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
      ).thenThrow(AuthException('Please confirm your email.'));

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

      final loginButton = find.widgetWithText(
        ElevatedButton,
        AuthStrings.loginCta,
      );
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      final confirmBanner = find.text(AuthStrings.errConfirmEmail);
      expect(confirmBanner, findsOneWidget);

      await tester.enterText(emailField, 'user@example.com1');
      await tester.pump();

      expect(confirmBanner, findsNothing);
      // Field errors remain untouched (stay null)
      expect(find.text(AuthStrings.errEmailInvalid), findsNothing);
      expect(find.text(AuthStrings.errPasswordInvalid), findsNothing);
    },
  );

  testWidgets('Global error banner clears when tapped', (tester) async {
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
    ).thenThrow(AuthException('Please confirm your email.'));

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

    final loginButton = find.widgetWithText(
      ElevatedButton,
      AuthStrings.loginCta,
    );
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    final confirmBanner = find.text(AuthStrings.errConfirmEmail);
    expect(confirmBanner, findsOneWidget);

    await tester.tap(find.byType(GlobalErrorBanner));
    await tester.pump();

    expect(confirmBanner, findsNothing);
    expect(find.text(AuthStrings.errEmailInvalid), findsNothing);
    expect(find.text(AuthStrings.errPasswordInvalid), findsNothing);
  });
}
