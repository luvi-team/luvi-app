import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../support/test_config.dart';

import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/core/navigation/routes.dart' as routes;
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Configures test view size. Returns teardown function to reset.
void Function() _configureTestView(WidgetTester tester) {
  final view = tester.view;
  view.physicalSize = const Size(1080, 2340);
  view.devicePixelRatio = 1.0;
  return () {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  };
}

void main() {
  TestConfig.ensureInitialized();
  late _MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = _MockAuthRepository();
    // Default behavior: throw invalid credentials to avoid real network
    when(
      () => mockRepo.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(AuthException('invalid credentials'));
  });

  testWidgets('LoginScreen shows headline and button', (tester) async {
    addTearDown(_configureTestView(tester));

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

    // Per Auth v2 refactoring: LoginScreen shows title (not headline)
    // Title uses l10n.authLoginTitle
    expect(find.byKey(const ValueKey('auth_login_screen')), findsOneWidget);
    final l10n = AppLocalizations.of(tester.element(find.byType(LoginScreen)))!;
    expect(find.text(l10n.authLoginTitle), findsOneWidget);
    expect(find.text(AuthStrings.loginCta), findsOneWidget);
  });

  testWidgets('CTA enabled before submit; disables on field errors', (
    tester,
  ) async {
    addTearDown(_configureTestView(tester));

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

    final button = find.widgetWithText(ElevatedButton, AuthStrings.loginCta);

    // Always enabled
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);

    await tester.tap(button);
    await tester.pump();

    expect(find.text(AuthStrings.errEmailEmpty), findsOneWidget);
    expect(find.text(AuthStrings.errPasswordEmpty), findsOneWidget);
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
  });

  testWidgets('shows signup link with correct text', (tester) async {
    addTearDown(_configureTestView(tester));

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

    // Scroll down to ensure the signup link is visible
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    // Verify signup link exists with correct key
    final signupLink = find.byKey(const ValueKey('login_signup_link'));
    expect(signupLink, findsOneWidget);

    // Verify the link contains expected l10n text
    // Note: LoginScreen uses RichText with TextSpan, so find.text() won't work
    final l10n = AppLocalizations.of(
      tester.element(find.byType(LoginScreen)),
    )!;

    // Find RichText inside the signup link and verify its content
    final richTextFinder = find.descendant(
      of: signupLink,
      matching: find.byType(RichText),
    );
    expect(richTextFinder, findsOneWidget);

    // Extract the plain text from RichText and verify both parts are present
    final richText = tester.widget<RichText>(richTextFinder);
    final plainText = richText.text.toPlainText();
    expect(plainText, contains(l10n.authLoginCtaLinkPrefix));
    expect(plainText, contains(l10n.authLoginCtaLinkAction));
  });

  testWidgets('tapping signup link navigates to AuthSignupScreen', (
    tester,
  ) async {
    addTearDown(_configureTestView(tester));

    when(
      () => mockRepo.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(AuthException('invalid credentials'));

    final router = GoRouter(
      routes: routes.featureRoutes,
      initialLocation: LoginScreen.routeName,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.buildAppTheme(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify we start on LoginScreen
    expect(find.byKey(const ValueKey('auth_login_screen')), findsOneWidget);

    // Scroll down to ensure the signup link is visible
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    // Tap the signup link
    final signupLink = find.byKey(const ValueKey('login_signup_link'));
    expect(signupLink, findsOneWidget);
    await tester.tap(signupLink);
    await tester.pumpAndSettle();

    // Verify navigation to AuthSignupScreen
    expect(find.byKey(const ValueKey('auth_signup_screen')), findsOneWidget);
  });
}
