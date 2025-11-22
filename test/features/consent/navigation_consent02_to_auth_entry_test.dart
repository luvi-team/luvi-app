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

    expect(
      find.byKey(const ValueKey('auth_entry_register_cta')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('auth_entry_login_cta')), findsOneWidget);

    final registerButton = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('auth_entry_register_cta')),
    );
    final loginButton = tester.widget<TextButton>(
      find.byKey(const ValueKey('auth_entry_login_cta')),
    );

    expect(registerButton.onPressed, isNotNull);
    expect(loginButton.onPressed, isNotNull);
  });

  testWidgets(
    'navigates to auth entry and shows best-effort snackbar when markWelcomeSeen fails',
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
      expect(find.byKey(const ValueKey('auth_entry_register_cta')), findsOneWidget);
      expect(find.byKey(const ValueKey('auth_entry_login_cta')), findsOneWidget);
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
    expect(find.byKey(const ValueKey('auth_entry_register_cta')), findsNothing);
    expect(find.byKey(const ValueKey('auth_entry_login_cta')), findsNothing);
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
