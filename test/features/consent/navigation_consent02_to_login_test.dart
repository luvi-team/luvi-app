import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/routes.dart' as consent;
import 'package:luvi_app/features/consent/state/consent02_state.dart';

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
  testWidgets('Consent02 forwards to /auth/login', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      routes: [...consent.consentRoutes],
      initialLocation: '/consent/02',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consent02NotifierProvider.overrideWith(
            _PreselectedConsent02Notifier.new,
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
        ),
      ),
    );

    // Tap the primary CTA 'Weiter'.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Weiter'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Willkommen zurück'), findsOneWidget);
  });
}
