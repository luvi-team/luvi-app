import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/core/privacy/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:luvi_app/core/init/session_dependencies.dart';
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
            home: const ConsentOptionsScreen(),
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
            home: const ConsentOptionsScreen(),
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
            home: const ConsentOptionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final screenContext = tester.element(find.byType(ConsentOptionsScreen));
      final l10n = AppLocalizations.of(screenContext)!;

      expect(find.text(l10n.consentOptionsTitle), findsOneWidget);
      expect(find.text(l10n.consentOptionsSubtitle), findsOneWidget);
    });

    // D4: C12 - Analytics consent shows revoke instruction separately
    testWidgets('analytics consent shows revoke instruction separately (C12)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final screenContext = tester.element(find.byType(ConsentOptionsScreen));
      final l10n = AppLocalizations.of(screenContext)!;

      // Verify analytics main text is present
      expect(find.text(l10n.consentOptionsAnalyticsText), findsOneWidget);

      // Verify revoke instruction is displayed separately (C12 fix)
      expect(find.text(l10n.consentOptionsAnalyticsRevoke), findsOneWidget);
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
              home: const ConsentOptionsScreen(),
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

    testWidgets('has two buttons (Weiter and Alle akzeptieren)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find exactly two ElevatedButtons
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    // New CTA Logic: Weiter button is disabled until required consents accepted
    testWidgets('Weiter button is disabled when required consents not accepted', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Continue button
      final continueButtonFinder = find.byKey(const Key('consent_options_btn_continue'));
      expect(continueButtonFinder, findsOneWidget);

      // Button should be DISABLED when required consents are not accepted
      final button = tester.widget<ElevatedButton>(continueButtonFinder);
      expect(button.onPressed, isNull,
          reason: 'Weiter button should be disabled when required consents not accepted');
    });

    // New CTA Logic: Accept all button is always enabled
    testWidgets('Accept all button is always enabled (no scroll-gate)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Accept All button by key
      final acceptAllFinder = find.byKey(const Key('consent_options_btn_accept_all'));
      expect(acceptAllFinder, findsOneWidget);

      // Button should be ENABLED immediately (no scroll-gate)
      final acceptAllButton = tester.widget<ElevatedButton>(acceptAllFinder);
      expect(acceptAllButton.onPressed, isNotNull,
          reason: 'Accept all button should always be enabled (scroll-gate removed)');
    });

    // Button Gap Test
    testWidgets('Button gap uses correct design token (16px per Figma)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the button gap SizedBox by key
      final buttonGapFinder = find.byKey(const Key('consent_options_button_gap'));
      expect(buttonGapFinder, findsOneWidget,
          reason: 'Should find exactly one SizedBox between the two buttons');

      // Verify it uses the correct design token height
      final sizedBox = tester.widget<SizedBox>(buttonGapFinder);
      expect(sizedBox.height, ConsentSpacing.buttonGapC2,
          reason: 'Button gap should use ConsentSpacing.buttonGapC2 (16px per Figma)');
    });

    // New CTA Logic: Weiter button becomes enabled after accepting required consents
    testWidgets('Weiter button enabled after accepting required consents', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.buildAppTheme(),
            home: const ConsentOptionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially disabled
      var continueButtonFinder = find.byKey(const Key('consent_options_btn_continue'));
      var button = tester.widget<ElevatedButton>(continueButtonFinder);
      expect(button.onPressed, isNull);

      // Scroll to make checkboxes visible and tap health consent
      final healthCheckbox = find.byKey(const Key('consent_options_health'));
      await tester.ensureVisible(healthCheckbox);
      await tester.pumpAndSettle();
      await tester.tap(healthCheckbox);
      await tester.pumpAndSettle();

      // Scroll to make terms checkbox visible and tap it
      final termsCheckbox = find.byKey(const Key('consent_options_terms'));
      await tester.ensureVisible(termsCheckbox);
      await tester.pumpAndSettle();
      await tester.tap(termsCheckbox);
      await tester.pumpAndSettle();

      // Now the button should be enabled
      button = tester.widget<ElevatedButton>(continueButtonFinder);
      expect(button.onPressed, isNotNull,
          reason: 'Weiter button should be enabled after accepting all required consents');
    });

    // Accept all button navigates to auth
    testWidgets('Accept all button navigates to auth', (tester) async {
      // Setup mocks
      final mockConsentService = _MockConsentService();
      final mockUserStateService = _MockUserStateService();

      when(
        () => mockConsentService.accept(
          version: ConsentConfig.currentVersion,
          scopes: any(named: 'scopes'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockUserStateService.bindUser(any())).thenAnswer((_) async {});
      when(() => mockUserStateService.markWelcomeSeen()).thenAnswer((_) async {});
      when(() => mockUserStateService.setAcceptedConsentVersion(any()))
          .thenAnswer((_) async {});

      // Setup GoRouter with consent + onboarding routes
      final router = GoRouter(
        initialLocation: RoutePaths.consentOptions,
        routes: [
          GoRoute(
            path: RoutePaths.consentOptions,
            builder: (context, state) => const ConsentOptionsScreen(),
          ),
          GoRoute(
            path: RoutePaths.onboarding01,
            builder: (context, state) => const Onboarding01Screen(),
          ),
          GoRoute(
            path: RoutePaths.authSignIn,
            builder: (context, state) => const AuthSignInScreen(),
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

      // Find and verify the Accept All button is enabled (no scroll needed)
      final acceptAllButton = find.byKey(const Key('consent_options_btn_accept_all'));
      expect(acceptAllButton, findsOneWidget);
      final button = tester.widget<ElevatedButton>(acceptAllButton);
      expect(button.onPressed, isNotNull,
          reason: 'Accept all button should be enabled immediately');

      // Tap "Alle akzeptieren"
      await tester.tap(acceptAllButton);
      await tester.pumpAndSettle();

      // Should navigate to AuthSignInScreen (pre-auth consent flow)
      expect(find.byType(AuthSignInScreen), findsOneWidget,
          reason: 'Consent happens before auth → navigate to AuthSignIn');

      // Verify mocks were called correctly
      verify(
        () => mockConsentService.accept(
          version: ConsentConfig.currentVersion,
          scopes: any(named: 'scopes'),
        ),
      ).called(1);
    });

    testWidgets(
      'Accept all navigates to auth when consent logging is unauthorized (pre-auth flow)',
      (tester) async {
        final mockConsentService = _MockConsentService();
        final mockUserStateService = _MockUserStateService();

        when(
          () => mockConsentService.accept(
            version: ConsentConfig.currentVersion,
            scopes: any(named: 'scopes'),
          ),
        ).thenThrow(ConsentException(401, 'Unauthorized'));
        when(() => mockUserStateService.bindUser(any())).thenAnswer((_) async {});
        when(() => mockUserStateService.markWelcomeSeen()).thenAnswer((_) async {});
        when(() => mockUserStateService.setAcceptedConsentVersion(any()))
            .thenAnswer((_) async {});

        final router = GoRouter(
          initialLocation: RoutePaths.consentOptions,
          routes: [
            GoRoute(
              path: RoutePaths.consentOptions,
              builder: (context, state) => const ConsentOptionsScreen(),
            ),
            GoRoute(
              path: RoutePaths.onboarding01,
              builder: (context, state) => const Onboarding01Screen(),
            ),
            GoRoute(
              path: RoutePaths.authSignIn,
              builder: (context, state) => const AuthSignInScreen(),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              consentServiceProvider.overrideWithValue(mockConsentService),
              userStateServiceProvider.overrideWith(
                (ref) async => mockUserStateService,
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

        final screenContext = tester.element(find.byType(ConsentOptionsScreen));
        final l10n = AppLocalizations.of(screenContext)!;

        // Tap "Alle akzeptieren" (no scroll needed - scroll-gate removed)
        final acceptAllButton =
            find.byKey(const Key('consent_options_btn_accept_all'));
        expect(acceptAllButton, findsOneWidget);

        await tester.tap(acceptAllButton);
        await tester.pumpAndSettle();

        // Unauthorized consent logging must not block navigation in the pre-auth flow.
        expect(find.byType(AuthSignInScreen), findsOneWidget);
        expect(find.text(l10n.consentSnackbarError), findsNothing);

        verify(
          () => mockConsentService.accept(
            version: ConsentConfig.currentVersion,
            scopes: any(named: 'scopes'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Navigation succeeds when userStateServiceProvider throws (local cache failure)',
      (tester) async {
        // Phase 2.2 test: local cache failure should not block navigation
        final mockConsentService = _MockConsentService();

        when(
          () => mockConsentService.accept(
            version: ConsentConfig.currentVersion,
            scopes: any(named: 'scopes'),
          ),
        ).thenAnswer((_) async {});

        final router = GoRouter(
          initialLocation: RoutePaths.consentOptions,
          routes: [
            GoRoute(
              path: RoutePaths.consentOptions,
              builder: (context, state) => const ConsentOptionsScreen(),
            ),
            GoRoute(
              path: RoutePaths.onboarding01,
              builder: (context, state) => const Onboarding01Screen(),
            ),
            GoRoute(
              path: RoutePaths.authSignIn,
              builder: (context, state) => const AuthSignInScreen(),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              consentServiceProvider.overrideWithValue(mockConsentService),
              // Simulate local cache failure
              userStateServiceProvider.overrideWith(
                (ref) => Future<UserStateService>.error(
                  StateError('Local cache failure'),
                ),
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

        // Tap "Alle akzeptieren"
        final acceptAllButton =
            find.byKey(const Key('consent_options_btn_accept_all'));
        expect(acceptAllButton, findsOneWidget);

        await tester.tap(acceptAllButton);
        await tester.pumpAndSettle();

        // Navigation should succeed despite local cache failure (best-effort semantics)
        expect(find.byType(AuthSignInScreen), findsOneWidget,
            reason: 'Navigation should proceed even when local cache fails');

        verify(
          () => mockConsentService.accept(
            version: ConsentConfig.currentVersion,
            scopes: any(named: 'scopes'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Authenticated user navigates to onboarding after consent',
      (tester) async {
        // Setup mocks
        final mockConsentService = _MockConsentService();
        final mockUserStateService = _MockUserStateService();

        when(
          () => mockConsentService.accept(
            version: ConsentConfig.currentVersion,
            scopes: any(named: 'scopes'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockUserStateService.bindUser(any()))
            .thenAnswer((_) async {});
        when(() => mockUserStateService.markWelcomeSeen())
            .thenAnswer((_) async {});
        when(() => mockUserStateService.setAcceptedConsentVersion(any()))
            .thenAnswer((_) async {});
        when(() => mockUserStateService.setAcceptedConsentScopes(any()))
            .thenAnswer((_) async {});

        // Setup GoRouter
        final router = GoRouter(
          initialLocation: RoutePaths.consentOptions,
          routes: [
            GoRoute(
              path: RoutePaths.consentOptions,
              builder: (context, state) => const ConsentOptionsScreen(),
            ),
            GoRoute(
              path: RoutePaths.onboarding01,
              builder: (context, state) => const Onboarding01Screen(),
            ),
            GoRoute(
              path: RoutePaths.authSignIn,
              builder: (context, state) => const AuthSignInScreen(),
            ),
          ],
        );

        // Build widget with auth = TRUE (authenticated user)
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              consentServiceProvider.overrideWithValue(mockConsentService),
              userStateServiceProvider
                  .overrideWith((ref) async => mockUserStateService),
              // KEY: Override isAuthenticatedFnProvider to return true
              isAuthenticatedFnProvider.overrideWithValue(() => true),
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

        // Tap "Alle akzeptieren"
        final acceptAllButton =
            find.byKey(const Key('consent_options_btn_accept_all'));
        await tester.tap(acceptAllButton);
        await tester.pumpAndSettle();

        // AUTH USER → should navigate to Onboarding, NOT AuthSignIn
        expect(
          find.byType(Onboarding01Screen),
          findsOneWidget,
          reason: 'Authenticated user should go to Onboarding after consent',
        );
        expect(find.byType(AuthSignInScreen), findsNothing);
      },
    );
  });
}
