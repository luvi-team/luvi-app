import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../support/test_config.dart';
import '../../../support/test_view.dart';

import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

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
    addTearDown(configureTestView(tester));

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
    // AuthPrimaryButton uses l10n.authEntryCta for button label
    expect(find.byType(AuthPrimaryButton), findsOneWidget);
  });

  testWidgets('CTA shows validation errors on empty submit', (
    tester,
  ) async {
    addTearDown(configureTestView(tester));

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

    // AuthPrimaryButton wraps ElevatedButton
    final buttonFinder = find.byKey(const ValueKey('login_cta_button'));
    final innerButton = find.descendant(
      of: buttonFinder,
      matching: find.byType(ElevatedButton),
    );

    // Always enabled initially
    expect(innerButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(innerButton).onPressed, isNotNull);

    await tester.tap(buttonFinder);
    await tester.pump();

    // LoginScreen shows generic L10n error messages
    final l10n = AppLocalizations.of(tester.element(find.byType(LoginScreen)))!;
    expect(find.text(l10n.authErrorEmailCheck), findsOneWidget);
    expect(find.text(l10n.authErrorPasswordCheck), findsOneWidget);
    // Auth Rebrand v3: Button stays enabled even with errors (allows retry)
    expect(tester.widget<ElevatedButton>(innerButton).onPressed, isNotNull);
  });

  // Note: Signup link was removed from LoginScreen per SSOT P0.6
  // Only "Passwort vergessen?" link is visible now
}
