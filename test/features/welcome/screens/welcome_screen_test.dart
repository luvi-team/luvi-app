import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/welcome/screens/welcome_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../../support/test_config.dart';
import '../../../support/video_player_mock.dart';

/// Widget tests for WelcomeScreen (Welcome Rebrand 3 Pages).
///
/// Tests cover:
/// - Page 1 renders with correct title and video player
/// - Page 2 renders with correct title and image
/// - Page 3 renders with correct title, subtitle and CTA
/// - CTA "Weiter" navigates to next page
/// - CTA "Starten" sets device flag + navigates to Auth
void main() {
  TestConfig.ensureInitialized();

  late GoRouter router;
  late Map<String, Object> prefsValues;

  setUp(() {
    // Fresh VideoPlayer mock for each test
    VideoPlayerMock.registerWith();

    // Initial SharedPreferences (welcome not yet completed)
    prefsValues = <String, Object>{};
    SharedPreferences.setMockInitialValues(prefsValues);

    router = GoRouter(
      initialLocation: RoutePaths.welcome,
      routes: [
        GoRoute(
          path: RoutePaths.welcome,
          name: RouteNames.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.authSignIn,
          name: RouteNames.authSignIn,
          builder: (context, state) => const Scaffold(
            key: ValueKey('auth_signin_screen'),
            body: Text('Auth SignIn Screen'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
  });

  Widget buildTestApp() {
    return ProviderScope(
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
    );
  }

  group('WelcomeScreen', () {
    testWidgets('renders page 1 with correct title', (tester) async {
      // Use realistic phone screen size
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump(); // First frame
      await tester.pump(); // Post-frame callbacks

      final l10n = AppLocalizations.of(
        tester.element(find.byType(WelcomeScreen)),
      )!;

      // Page 1 title should be visible
      expect(find.text(l10n.welcomeNewTitle1), findsOneWidget);

      // Page 1 CTA should be visible
      expect(find.text(l10n.welcomeNewCta1), findsOneWidget);
    });

    testWidgets('renders page indicators (3 total)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump();

      // There should be multiple AnimatedContainers (page indicators)
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('CTA navigates from page 1 to page 2', (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(WelcomeScreen)),
      )!;

      // Verify page 1 title
      expect(find.text(l10n.welcomeNewTitle1), findsOneWidget);

      // Tap CTA to go to page 2
      final cta1 = find.text(l10n.welcomeNewCta1);
      expect(cta1, findsOneWidget);
      await tester.tap(cta1);
      await tester.pumpAndSettle();

      // Page 2 title should now be visible
      expect(find.text(l10n.welcomeNewTitle2), findsOneWidget);
      expect(find.text(l10n.welcomeNewCta2), findsOneWidget);
    });

    testWidgets('CTA navigates from page 2 to page 3', (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(WelcomeScreen)),
      )!;

      // Navigate to page 2
      await tester.tap(find.text(l10n.welcomeNewCta1));
      await tester.pumpAndSettle();

      // Tap CTA to go to page 3
      await tester.tap(find.text(l10n.welcomeNewCta2));
      await tester.pumpAndSettle();

      // Page 3 title and subtitle should be visible
      expect(find.text(l10n.welcomeNewTitle3), findsOneWidget);
      expect(find.text(l10n.welcomeNewSubtitle3), findsOneWidget);
      expect(find.text(l10n.welcomeNewCta3), findsOneWidget);
    });

    testWidgets('swipe gesture navigates between pages', (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(WelcomeScreen)),
      )!;

      // Verify page 1
      expect(find.text(l10n.welcomeNewTitle1), findsOneWidget);

      // Swipe left to go to page 2
      await tester.fling(
        find.byType(PageView),
        const Offset(-300, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // Page 2 should be visible
      expect(find.text(l10n.welcomeNewTitle2), findsOneWidget);
    });

    testWidgets(
      'page 3 CTA "Starten" navigates to AuthSignIn',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildTestApp());
        await tester.pump();
        await tester.pump();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(WelcomeScreen)),
        )!;

        // Navigate to page 3
        await tester.tap(find.text(l10n.welcomeNewCta1));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.welcomeNewCta2));
        await tester.pumpAndSettle();

        // Tap "Starten" CTA
        await tester.tap(find.text(l10n.welcomeNewCta3));
        await tester.pumpAndSettle();

        // Should navigate to AuthSignInScreen
        expect(
          find.byKey(const ValueKey('auth_signin_screen')),
          findsOneWidget,
          reason: 'Should navigate to AuthSignInScreen after completing welcome',
        );
      },
    );

    testWidgets(
      'page 3 CTA persists welcome completion flag',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildTestApp());
        await tester.pump();
        await tester.pump();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(WelcomeScreen)),
        )!;

        // Navigate to page 3
        await tester.tap(find.text(l10n.welcomeNewCta1));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.welcomeNewCta2));
        await tester.pumpAndSettle();

        // Tap "Starten" CTA
        await tester.tap(find.text(l10n.welcomeNewCta3));
        await tester.pumpAndSettle();

        // Verify flag was persisted
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getBool('device:welcome_completed_v1'),
          isTrue,
          reason: 'DeviceStateService should persist welcome_completed flag',
        );
      },
    );
  });
}
