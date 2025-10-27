import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/consent/routes.dart';
import 'package:luvi_app/features/routes.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import '../../support/test_config.dart';

class _PreselectedConsent02Notifier extends Consent02Notifier {
  @override
  Consent02State build() {
    return Consent02State({
      for (final scope in ConsentScope.values)
        scope: requiredScopes.contains(scope),
    });
  }
}

void main() {
    testWidgets('Consent02 forwards to /auth/entry (AuthEntry screen)', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      routes: featureRoutes,
      initialLocation: ConsentRoutes.consent02,
    );

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consent02NotifierProvider.overrideWith(
            _PreselectedConsent02Notifier.new,
          ),
          userStateServiceProvider.overrideWith(
            (ref) async => UserStateService(prefs: prefs),
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

    // Tap the primary CTA 'Weiter'.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Weiter'));
    await tester.pumpAndSettle();

    // Expect we navigated to AuthEntry and see both CTAs (stable keys)
    expect(
      find.byKey(const ValueKey('auth_entry_register_cta')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('auth_entry_login_cta')), findsOneWidget);

    // Smoke-check: both CTAs expose enabled tap handlers
    final registerButton = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('auth_entry_register_cta')),
    );
    final loginButton = tester.widget<TextButton>(
      find.byKey(const ValueKey('auth_entry_login_cta')),
    );

    expect(registerButton.onPressed, isNotNull);
    expect(loginButton.onPressed, isNotNull);
  });
}
