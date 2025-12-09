import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/test_config.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestConfig.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  Future<void> pumpSignupScreen(
    WidgetTester tester,
    AuthRepository repository,
    GoRouter router,
  ) async {
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

  Finder textFieldByHint(String hint) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint,
  );

  group('AuthSignupScreen submit behaviour', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: features.featureRoutes,
        initialLocation: AuthSignupScreen.routeName,
      );
    });

    tearDown(() {
      router.dispose();
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

      await pumpSignupScreen(tester, mockRepo, router);

      await tester.enterText(
        textFieldByHint(AuthStrings.emailHint),
        'user@example.com',
      );
      await tester.enterText(
        textFieldByHint(AuthStrings.passwordHint),
        'strongpass',
      );

      await tester.tap(find.byKey(const ValueKey('signup_cta_button')));
      await tester.pumpAndSettle();

      verify(
        () => mockRepo.signUp(
          email: 'user@example.com',
          password: 'strongpass',
          data: null,
        ),
      ).called(1);

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

      await pumpSignupScreen(tester, mockRepo, router);

      await tester.enterText(
        textFieldByHint(AuthStrings.emailHint),
        'user@example.com',
      );
      await tester.enterText(
        textFieldByHint(AuthStrings.passwordHint),
        'strongpass',
      );

      final buttonFinder = find.byKey(const ValueKey('signup_cta_button'));
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Email already registered'), findsOneWidget);

      // WelcomeButton wraps ElevatedButton - find the inner ElevatedButton
      final elevatedButtonFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(ElevatedButton),
      );
      final button = tester.widget<ElevatedButton>(elevatedButtonFinder);
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

      await pumpSignupScreen(tester, mockRepo, router);

      await tester.enterText(
        textFieldByHint(AuthStrings.emailHint),
        'user@example.com',
      );
      await tester.enterText(
        textFieldByHint(AuthStrings.passwordHint),
        'strongpass',
      );

      final buttonFinder = find.byKey(const ValueKey('signup_cta_button'));
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.byKey(const ValueKey('signup_cta_loading')), findsOneWidget);

      // WelcomeButton wraps ElevatedButton - find the inner ElevatedButton
      final elevatedButtonFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(ElevatedButton),
      );
      final loadingButton = tester.widget<ElevatedButton>(elevatedButtonFinder);
      expect(loadingButton.onPressed, isNull);

      completer.complete(AuthResponse(session: null, user: null));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('signup_cta_loading')), findsNothing);
    });
  });
}
