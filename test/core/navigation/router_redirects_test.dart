import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/router.dart';

import '../../support/test_config.dart';
import '../../support/video_player_mock.dart';

/// Router redirect tests for legacy Welcome routes.
///
/// Ensures backward compatibility: /onboarding/w1..w5 → /welcome.
/// Prevents accidental removal of these redirects during refactoring.
void main() {
  TestConfig.ensureInitialized();

  late GoRouter router;

  setUp(() {
    // Fresh VideoPlayer mock for each test (WelcomeScreen contains videos)
    VideoPlayerMock.registerWith();
  });

  Widget buildTestApp(GoRouter testRouter) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: testRouter,
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }

  group('Legacy Welcome Redirects', () {
    for (final legacyPath in [
      '/onboarding/w1',
      '/onboarding/w2',
      '/onboarding/w3',
      '/onboarding/w4',
      '/onboarding/w5',
    ]) {
      testWidgets('$legacyPath redirects to ${RoutePaths.welcome}',
          (tester) async {
        router = GoRouter(
          initialLocation: legacyPath,
          routes: testAppRoutes,
          redirect: null, // Disable global auth redirect for this test
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(buildTestApp(router));
        await tester.pumpAndSettle();

        // Verify redirect occurred
        final currentLocation =
            router.routerDelegate.currentConfiguration.uri.toString();
        expect(
          currentLocation,
          equals(RoutePaths.welcome),
          reason: 'Legacy path $legacyPath should redirect to /welcome',
        );
      });
    }
  });

  group('Canonical Welcome Route', () {
    testWidgets('/welcome renders without redirect', (tester) async {
      router = GoRouter(
        initialLocation: RoutePaths.welcome,
        routes: testAppRoutes,
        redirect: null,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(buildTestApp(router));
      await tester.pumpAndSettle();

      final currentLocation =
          router.routerDelegate.currentConfiguration.uri.toString();
      expect(
        currentLocation,
        equals(RoutePaths.welcome),
        reason: 'Canonical /welcome should not redirect',
      );
    });
  });
}
