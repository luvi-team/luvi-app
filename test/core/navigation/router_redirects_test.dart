import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/router.dart';

import '../../support/test_app.dart';
import '../../support/test_config.dart';
import '../../support/video_player_mock.dart';

/// Router redirect tests for legacy routes.
///
/// Ensures backward compatibility:
/// - /onboarding/w1..w5 → /welcome
/// - /consent/intro, /consent/blocking, /consent/02 → /consent/options
/// Prevents accidental removal of these redirects during refactoring.
void main() {
  TestConfig.ensureInitialized();

  late GoRouter router;

  setUp(() {
    // Fresh VideoPlayer mock for each test (WelcomeScreen contains videos)
    VideoPlayerMock.registerWith();
  });

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

        await tester.pumpWidget(buildTestApp(router: router));
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

      await tester.pumpWidget(buildTestApp(router: router));
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

  group('Legacy Consent Redirects', () {
    for (final legacyPath in [
      RoutePaths.consentIntro, // /consent/intro
      RoutePaths.consentBlocking, // /consent/blocking
      RoutePaths.consentIntroLegacy, // /consent/02
    ]) {
      testWidgets('$legacyPath redirects to ${RoutePaths.consentOptions}',
          (tester) async {
        router = GoRouter(
          initialLocation: legacyPath,
          routes: testAppRoutes,
          redirect: null, // Disable global auth redirect for this test
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(buildTestApp(router: router));
        await tester.pumpAndSettle();

        // Verify redirect occurred
        final currentLocation =
            router.routerDelegate.currentConfiguration.uri.toString();
        expect(
          currentLocation,
          equals(RoutePaths.consentOptions),
          reason: 'Legacy consent path $legacyPath should redirect to /consent/options',
        );
      });
    }
  });

  group('Canonical Consent Options Route', () {
    testWidgets('/consent/options renders without redirect', (tester) async {
      router = GoRouter(
        initialLocation: RoutePaths.consentOptions,
        routes: testAppRoutes,
        redirect: null,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      final currentLocation =
          router.routerDelegate.currentConfiguration.uri.toString();
      expect(
        currentLocation,
        equals(RoutePaths.consentOptions),
        reason: 'Canonical /consent/options should not redirect',
      );
    });
  });
}
