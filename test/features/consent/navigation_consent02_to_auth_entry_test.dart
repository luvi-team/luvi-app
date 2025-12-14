import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/routes.dart';
import 'package:luvi_app/features/consent/screens/consent_02_screen.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
import 'package:luvi_app/core/navigation/routes.dart';
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

  testWidgets('Consent CTA logs scopes and navigates when accept succeeds', (
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
    when(() => userState.markWelcomeSeen()).thenAnswer((_) async {});

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

    verify(() => userState.markWelcomeSeen()).called(1);

    // Auth Flow Fix: After consent, user (already authenticated) goes to Onboarding, not Auth
    // User is already logged in at this point (logged in before Welcome/Consent flow)
    expect(
      find.byType(Onboarding01Screen),
      findsOneWidget,
      reason: 'Consent02 should navigate to Onboarding01 (user is already authenticated)',
    );
  });

  testWidgets(
    'navigates to onboarding and shows best-effort snackbar when markWelcomeSeen fails',
    (tester) async {
      final consentService = _MockConsentService();
      final userState = _MockUserStateService();

      when(
        () => consentService.accept(
          version: ConsentConfig.currentVersion,
          scopes: any(named: 'scopes'),
        ),
      ).thenAnswer((_) async {});
      when(() => userState.markWelcomeSeen()).thenThrow(Exception('fail'));

      await _pumpConsentScreen(
        tester,
        consentService: consentService,
        userStateService: userState,
      );

      final screenContext = tester.element(find.byType(Consent02Screen));
      final l10n = AppLocalizations.of(screenContext)!;

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

      verify(() => userState.markWelcomeSeen()).called(1);

      expect(find.text(l10n.consentErrorSavingConsent), findsOneWidget);
      // Auth Flow Fix: navigation goes to Onboarding (user is already authenticated)
      expect(
        find.byType(Onboarding01Screen),
        findsOneWidget,
        reason: 'Even on markWelcomeSeen failure, navigation should proceed to Onboarding',
      );
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
    // Auth Flow Fix: check that navigation to onboarding did NOT happen (blocked by error)
    expect(
      find.byType(Onboarding01Screen),
      findsNothing,
      reason: 'Rate-limit error should block navigation to Onboarding',
    );
  });
}

Future<void> _pumpConsentScreen(
  WidgetTester tester, {
  required ConsentService consentService,
  required UserStateService userStateService,
}) async {
  final router = GoRouter(
    routes: featureRoutes,
    initialLocation: ConsentRoutes.consent02,
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
