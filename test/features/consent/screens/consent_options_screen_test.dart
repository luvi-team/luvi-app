import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_blocking_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';
import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

/// Mock ConsentService for testing navigation without Supabase
class _MockConsentService extends Mock implements ConsentService {}

/// Mock UserStateService for testing without real persistence
class _MockUserStateService extends Mock implements UserStateService {}

void main() {
  TestConfig.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  group('ConsentOptionsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ConsentOptionsScreen), findsOneWidget);
    });

    testWidgets('renders with correct L10n (DE)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final screenContext = tester.element(find.byType(ConsentOptionsScreen));
      final l10n = AppLocalizations.of(screenContext)!;

      // Verify title and subtitle
      expect(find.text(l10n.consentOptionsTitle), findsOneWidget);
      expect(find.text(l10n.consentOptionsSubtitle), findsOneWidget);

      // Verify section headers
      expect(find.text(l10n.consentOptionsSectionRequired), findsOneWidget);
      expect(find.text(l10n.consentOptionsSectionOptional), findsOneWidget);

      // Verify buttons
      expect(find.text(l10n.consentOptionsCtaContinue), findsOneWidget);
      expect(find.text(l10n.consentOptionsCtaAcceptAll), findsOneWidget);
    });

    testWidgets('renders with correct L10n (EN)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final screenContext = tester.element(find.byType(ConsentOptionsScreen));
      final l10n = AppLocalizations.of(screenContext)!;

      expect(find.text(l10n.consentOptionsTitle), findsOneWidget);
      expect(find.text(l10n.consentOptionsSubtitle), findsOneWidget);
    });

    testWidgets('has correct semantics header', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: AppTheme.buildAppTheme(),
              home: const ConsentOptionsScreen(
                appLinks: TestConfig.defaultAppLinks,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify there's a semantics header
        final headerFinder = find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.header == true),
        );
        expect(headerFinder, findsOneWidget);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('has two buttons (Weiter and Alles akzeptieren)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find exactly two ElevatedButtons
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Continue button is always enabled (navigates to blocking if required not accepted)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Continue button
      final continueButtonFinder = find.byKey(const Key('consent_options_btn_continue'));
      expect(continueButtonFinder, findsOneWidget);

      // Fix 1: Button is ALWAYS enabled (not disabled when required not accepted)
      // If required consents are not accepted, tapping navigates to C3 (Blocking)
      final button = tester.widget<ElevatedButton>(continueButtonFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Accept all button is enabled after scrolling (scroll-gate test)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to the bottom to enable "Accept all" button (Fix 4)
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Find the Accept All button by key
      final acceptAllFinder = find.byKey(const Key('consent_options_btn_accept_all'));
      expect(acceptAllFinder, findsOneWidget);

      // Verify button is enabled after scroll (Fix 4)
      final acceptAllButton = tester.widget<ElevatedButton>(acceptAllFinder);
      expect(acceptAllButton.onPressed, isNotNull,
          reason: 'Accept all button should be enabled after scrolling');

      // Continue button should still be enabled
      final continueButtonFinder = find.byKey(const Key('consent_options_btn_continue'));
      final button = tester.widget<ElevatedButton>(continueButtonFinder);
      expect(button.onPressed, isNotNull);
    });

    // Gap 1: Test button is disabled BEFORE scrolling (when content is scrollable)
    testWidgets('Accept all button is disabled before scrolling (scroll-gate)', (tester) async {
      // Force small viewport to ensure content IS scrollable
      await tester.binding.setSurfaceSize(const Size(400, 300));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Accept All button by key
      final acceptAllFinder = find.byKey(const Key('consent_options_btn_accept_all'));
      expect(acceptAllFinder, findsOneWidget);

      // Button should be DISABLED before scrolling (content is scrollable)
      final button = tester.widget<ElevatedButton>(acceptAllFinder);
      expect(button.onPressed, isNull,
          reason: 'Accept all button should be disabled before scrolling');
    });

    // Gap 3: Test button is enabled immediately when content fits on screen
    testWidgets('Accept all button enabled immediately when content fits on screen', (tester) async {
      // Force very large viewport so content definitely fits
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Accept All button by key
      final acceptAllFinder = find.byKey(const Key('consent_options_btn_accept_all'));
      expect(acceptAllFinder, findsOneWidget);

      // Button should be ENABLED immediately (no scroll needed, content fits)
      final button = tester.widget<ElevatedButton>(acceptAllFinder);
      expect(button.onPressed, isNotNull,
          reason: 'Accept all should be enabled when content fits on screen');
    });

    // Fix 6: Button Gap Test (updated to 16px per Figma audit)
    // Note: buttonGapC2 = 16px which equals Spacing.m, so multiple SizedBoxes may match.
    // We verify the design token is used correctly by checking at least one exists.
    testWidgets('Button gap uses correct design token (16px per Figma)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find SizedBox with buttonGapC2 height (16px per Figma)
      // Note: Multiple may exist since Spacing.m also equals 16px
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.height == ConsentSpacing.buttonGapC2,
      );
      expect(sizedBoxFinder, findsWidgets,
          reason: 'Should find SizedBox(es) with height = buttonGapC2 (16px per Figma)');
    });

    // Gap 4: Navigation Integration Test with GoRouter (per CLAUDE.md buildTestApp)
    testWidgets('Continue button navigates to blocking screen when required not accepted', (tester) async {
      // Setup GoRouter with consent routes
      final router = GoRouter(
        initialLocation: '/consent/options',
        routes: [
          GoRoute(
            path: '/consent/options',
            builder: (context, state) => const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
          GoRoute(
            path: '/consent/blocking',
            builder: (context, state) => const ConsentBlockingScreen(),
          ),
        ],
      );

      // Use buildTestApp per CLAUDE.md guidelines
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify we're on ConsentOptionsScreen
      expect(find.byType(ConsentOptionsScreen), findsOneWidget);

      // Tap Continue button (without accepting required consents)
      final continueButton = find.byKey(const Key('consent_options_btn_continue'));
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Should navigate to ConsentBlockingScreen
      expect(find.byType(ConsentBlockingScreen), findsOneWidget,
          reason: 'Should navigate to blocking screen when required consents not accepted');
    });

    // Bug Fix: Test for "Alles akzeptieren" race condition fix
    // Verifies that tapping "Accept all" navigates to Onboarding, NOT blocking screen.
    // Uses mocked ConsentService and UserStateService for full integration test.
    testWidgets('Accept all button navigates to onboarding (race condition fix)', (tester) async {
      // Setup mocks
      final mockConsentService = _MockConsentService();
      final mockUserStateService = _MockUserStateService();

      when(
        () => mockConsentService.accept(
          version: ConsentConfig.currentVersion,
          scopes: any(named: 'scopes'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockUserStateService.markWelcomeSeen()).thenAnswer((_) async {});
      when(() => mockUserStateService.setAcceptedConsentVersion(any()))
          .thenAnswer((_) async {});

      // Setup GoRouter with consent + onboarding routes
      final router = GoRouter(
        initialLocation: '/consent/options',
        routes: [
          GoRoute(
            path: '/consent/options',
            builder: (context, state) => const ConsentOptionsScreen(
              appLinks: TestConfig.defaultAppLinks,
            ),
          ),
          GoRoute(
            path: '/consent/blocking',
            builder: (context, state) => const ConsentBlockingScreen(),
          ),
          GoRoute(
            path: '/onboarding/01',
            builder: (context, state) => const Onboarding01Screen(),
          ),
        ],
      );

      // Build widget with mocked providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            consentServiceProvider.overrideWithValue(mockConsentService),
            userStateServiceProvider.overrideWith((ref) async => mockUserStateService),
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

      // Verify we're on ConsentOptionsScreen
      expect(find.byType(ConsentOptionsScreen), findsOneWidget);

      // Scroll to enable "Alles akzeptieren" button (DSGVO scroll-gate)
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Find and verify the Accept All button is enabled
      final acceptAllButton = find.byKey(const Key('consent_options_btn_accept_all'));
      expect(acceptAllButton, findsOneWidget);
      final button = tester.widget<ElevatedButton>(acceptAllButton);
      expect(button.onPressed, isNotNull,
          reason: 'Accept all button should be enabled after scrolling');

      // Tap "Alles akzeptieren" - the race condition fix ensures fresh state is read
      await tester.tap(acceptAllButton);
      await tester.pumpAndSettle();

      // CRITICAL: Should NOT navigate to ConsentBlockingScreen
      // Before the fix, the stale state caused navigation to blocking on first tap
      expect(find.byType(ConsentBlockingScreen), findsNothing,
          reason: 'Accept all should NOT navigate to blocking screen (race condition fix)');

      // Should navigate to Onboarding01Screen
      expect(find.byType(Onboarding01Screen), findsOneWidget,
          reason: 'Accept all should navigate to Onboarding01 after consent');

      // Verify mocks were called correctly
      verify(
        () => mockConsentService.accept(
          version: ConsentConfig.currentVersion,
          scopes: any(named: 'scopes'),
        ),
      ).called(1);
      verify(() => mockUserStateService.markWelcomeSeen()).called(1);
    });
  });
}
