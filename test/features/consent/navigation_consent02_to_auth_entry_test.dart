import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_02_screen.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';

import '../../support/test_config.dart';

const _preselectedOptionalScopes = <ConsentScope>{
  ConsentScope.analytics,
  ConsentScope.ai_journal,
};

class _PreselectedConsent02Notifier extends Consent02Notifier {
  @override
  Consent02State build() {
    return Consent02State({
      for (final scope in ConsentScope.values)
        scope: kRequiredConsentScopes.contains(scope) ||
            _preselectedOptionalScopes.contains(scope),
    });
  }
}

class _MockConsentService extends Mock implements ConsentService {}

class _MockUserStateService extends Mock implements UserStateService {}

void main() {
  TestConfig.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  testWidgets('Consent CTA logs scopes and navigates to auth when accept succeeds pre-auth', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final consentService = _MockConsentService();
    final userState = _MockUserStateService();

    when(
      () => consentService.accept(
        version: ConsentConfig.currentVersion,
        scopes: any(named: 'scopes'),
      ),
    ).thenAnswer((_) async {});
    // Stub local cache methods (not called when uid is null in test env).
    when(() => userState.bindUser(any())).thenAnswer((_) async {});
    when(() => userState.markWelcomeSeen()).thenAnswer((_) async {});
    when(() => userState.setAcceptedConsentVersion(any())).thenAnswer((_) async {});

    await _pumpConsentScreen(
      tester,
      consentService: consentService,
      userStateService: userState,
    );

    await tester.tap(find.byKey(const Key('consent02_btn_next')));
    await tester.pumpAndSettle();

    final consentCall = verify(
      () => consentService.accept(
        version: ConsentConfig.currentVersion,
        scopes: captureAny(named: 'scopes'),
      ),
    );
    consentCall.called(1);
    final capturedScopes = consentCall.captured.single as List<String>;
    expect(capturedScopes, _expectedScopeIds());

    // Local cache writes are skipped when uid is null (test env has no real Supabase).
    // This is correct behavior - we don't write to cache without a valid user.
    verifyNever(() => userState.markWelcomeSeen());

    // FTUE: Consent happens before auth → navigate to Auth Sign-In.
    expect(find.byType(AuthSignInScreen), findsOneWidget);
  });

  testWidgets(
    'skips local cache writes silently when uid is null (no false-positive warning)',
    (tester) async {
      // This test validates the fix for consentErrorSavingConsent false-positive:
      // When SupabaseService.currentUser?.id is null (as in tests or edge cases),
      // local cache writes are skipped entirely - no StateError, no warning snackbar.
      final consentService = _MockConsentService();
      final userState = _MockUserStateService();

      when(
        () => consentService.accept(
          version: ConsentConfig.currentVersion,
          scopes: any(named: 'scopes'),
        ),
      ).thenAnswer((_) async {});
      // Note: We still stub these in case they're called, but they shouldn't be
      // because uid is null in test environment (no real Supabase).
      when(() => userState.bindUser(any())).thenAnswer((_) async {});
      when(() => userState.markWelcomeSeen()).thenAnswer((_) async {});
      when(() => userState.setAcceptedConsentVersion(any())).thenAnswer((_) async {});

      await _pumpConsentScreen(
        tester,
        consentService: consentService,
        userStateService: userState,
      );

      final screenContext = tester.element(find.byType(Consent02Screen));
      final l10n = AppLocalizations.of(screenContext)!;

      await tester.tap(find.byKey(const Key('consent02_btn_next')));
      await tester.pumpAndSettle();

      // Consent acceptance should still be called (server-side).
      final consentCall = verify(
        () => consentService.accept(
          version: ConsentConfig.currentVersion,
          scopes: captureAny(named: 'scopes'),
        ),
      );
      consentCall.called(1);
      final capturedScopes = consentCall.captured.single as List<String>;
      expect(capturedScopes, _expectedScopeIds());

      // Local cache writes should NOT be called (uid is null in test env).
      verifyNever(() => userState.markWelcomeSeen());
      verifyNever(() => userState.setAcceptedConsentVersion(any()));

      // No false-positive warning snackbar should appear.
      expect(find.text(l10n.consentErrorSavingConsent), findsNothing);

      // FTUE: Consent happens before auth → navigate to Auth Sign-In.
      expect(find.byType(AuthSignInScreen), findsOneWidget);
    },
  );

  testWidgets('Consent CTA shows rate-limit snackbar and blocks navigation', (
    tester,
  ) async {
    final consentService = _MockConsentService();
    final userState = _MockUserStateService();

    when(
      () => consentService.accept(
        version: ConsentConfig.currentVersion,
        scopes: any(named: 'scopes'),
      ),
    ).thenThrow(
      ConsentException(429, 'rate limited', code: 'rate_limit'),
    );

    await _pumpConsentScreen(
      tester,
      consentService: consentService,
      userStateService: userState,
    );

    final screenContext = tester.element(find.byType(Consent02Screen));
    final l10n = AppLocalizations.of(screenContext)!;

    await tester.tap(find.byKey(const Key('consent02_btn_next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final consentCall = verify(
      () => consentService.accept(
        version: ConsentConfig.currentVersion,
        scopes: captureAny(named: 'scopes'),
      ),
    );
    consentCall.called(1);
    final capturedScopes = consentCall.captured.single as List<String>;
    expect(capturedScopes, _expectedScopeIds());

    verifyNever(() => userState.markWelcomeSeen());

    expect(find.text(l10n.consentSnackbarRateLimited), findsOneWidget);
    // Rate-limit error blocks navigation.
    expect(find.byType(AuthSignInScreen), findsNothing);
  });
}

Future<void> _pumpConsentScreen(
  WidgetTester tester, {
  required ConsentService consentService,
  required UserStateService userStateService,
}) async {
  // Note: Consent02Screen is no longer in featureRoutes (replaced by ConsentIntroScreen + ConsentOptionsScreen).
  // We create a custom router with Consent02Screen for backwards compatibility.
  final router = GoRouter(
    routes: [
      GoRoute(
        path: Consent02Screen.routeName,
        builder: (context, state) => const Consent02Screen(
          appLinks: TestConfig.defaultAppLinks,
        ),
      ),
      GoRoute(
        path: Onboarding01Screen.routeName,
        builder: (context, state) => const Onboarding01Screen(),
      ),
      GoRoute(
        path: AuthSignInScreen.routeName,
        builder: (context, state) => const AuthSignInScreen(),
      ),
    ],
    initialLocation: Consent02Screen.routeName,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        consent02Provider.overrideWith(_PreselectedConsent02Notifier.new),
        consentServiceProvider.overrideWithValue(consentService),
        userStateServiceProvider.overrideWith(
          (ref) async => userStateService,
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );

  await tester.pumpAndSettle();
}

List<String> _expectedScopeIds() {
  return [
    for (final scope in ConsentScope.values)
      if (kRequiredConsentScopes.contains(scope) ||
          _preselectedOptionalScopes.contains(scope))
        scope.name,
  ];
}
