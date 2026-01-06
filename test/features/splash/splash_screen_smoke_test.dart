import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/features/splash/widgets/splash_video_player.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/init_mode.dart';

import '../../support/test_config.dart';
import '../../support/video_player_mock.dart';

/// Builds a test harness with ProviderScope and MaterialApp.router.
///
/// Encapsulates common test setup:
/// - InitMode.test provider override
/// - AppTheme
/// - Localization delegates
///
/// [locale] defaults to German ('de') but can be overridden for i18n tests.
Widget buildTestHarness(GoRouter router, {Locale locale = const Locale('de')}) {
  return ProviderScope(
    overrides: [
      initModeProvider.overrideWithValue(InitMode.test),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.buildAppTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [locale],
      locale: locale,
    ),
  );
}

/// Smoke Widget-Tests for SplashScreen.
///
/// These tests verify the critical UI flows:
/// - skipAnimation=true immediately triggers navigation (post-login redirect)
/// - Normal splash renders the SplashVideoPlayer widget
///
/// Codex-Audit: Closes gap in test coverage for SplashScreen widget behavior.
void main() {
  TestConfig.ensureInitialized();

  setUp(() {
    // Fresh SharedPreferences mock for each test (no persisted state)
    SharedPreferences.setMockInitialValues({});
    // Fresh VideoPlayerMock for each test
    VideoPlayerMock.registerWith();
  });

  group('SplashScreen smoke tests', () {
    testWidgets(
      'skipAnimation=true navigates to AuthSignInScreen (unauth default)',
      (tester) async {
        // Router with Splash (skipAnimation=true) and AuthSignIn routes
        final router = GoRouter(
          initialLocation: '${SplashScreen.routeName}?skipAnimation=true',
          routes: [
            GoRoute(
              path: SplashScreen.routeName,
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: AuthSignInScreen.routeName,
              name: RouteNames.authSignIn,
              builder: (context, state) => const AuthSignInScreen(),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(buildTestHarness(router));

        // Initial frame: Splash is shown (briefly)
        await tester.pump();

        // Allow post-frame callback and navigation to complete
        // The skipAnimation flow uses addPostFrameCallback, so we need multiple pumps
        await tester.pump();
        await tester.pump();

        // pumpAndSettle to ensure all navigation transitions complete
        await tester.pumpAndSettle();

        // Verify: Navigation to AuthSignInScreen (unauth user default)
        expect(
          find.byKey(const ValueKey('auth_signin_screen')),
          findsOneWidget,
          reason: 'skipAnimation=true should navigate to AuthSignInScreen for unauthenticated users',
        );
      },
    );

    testWidgets(
      'renders SplashVideoPlayer when skipAnimation is not set',
      (tester) async {
        // Router with Splash route (no skipAnimation query param)
        final router = GoRouter(
          initialLocation: SplashScreen.routeName,
          routes: [
            GoRoute(
              path: SplashScreen.routeName,
              builder: (context, state) => const SplashScreen(),
            ),
            // AuthSignIn route needed for potential navigation
            GoRoute(
              path: AuthSignInScreen.routeName,
              name: RouteNames.authSignIn,
              builder: (context, state) => const AuthSignInScreen(),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(buildTestHarness(router));

        // Initial pump to build the widget tree
        await tester.pump();

        // Verify: SplashVideoPlayer is rendered
        expect(
          find.byType(SplashVideoPlayer),
          findsOneWidget,
          reason: 'Splash without skipAnimation should render SplashVideoPlayer',
        );

        // Verify: Still on SplashScreen (not navigated away yet)
        // Note: We don't pump(Duration) to avoid triggering max duration timeout
        expect(
          find.byType(SplashScreen),
          findsOneWidget,
          reason: 'Should still be on SplashScreen during video playback',
        );
      },
    );
  });
}
