import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

/// Extracted Unknown UI widget for isolated testing.
///
/// IMPORTANT: This mirrors `_buildUnknownUI` from SplashScreen
/// (lib/features/splash/screens/splash_screen.dart:222-284).
/// If the production UI changes, update this test widget to match.
/// This is a deliberate test-only copy for isolated widget testing.
// TODO(sync-check): Keep in sync with SplashScreen._buildUnknownUI
// Sync checklist: Icon, title, body text, button styling, disabled states
// Last synced: 2024-12 (consent-onboarding-refactor-v3)
class _TestableUnknownUI extends StatefulWidget {
  const _TestableUnknownUI({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  State<_TestableUnknownUI> createState() => _TestableUnknownUIState();
}

class _TestableUnknownUIState extends State<_TestableUnknownUI> {
  bool _hasUsedManualRetry = false;

  void _handleRetry() {
    if (!mounted) return;
    setState(() {
      _hasUsedManualRetry = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: DsColors.welcomeWaveBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: DsColors.textPrimary,
                semanticLabel: l10n.splashGateUnknownTitle,
              ),
              const SizedBox(height: Spacing.l),
              Text(
                l10n.splashGateUnknownTitle,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.m),
              Text(
                l10n.splashGateUnknownBody,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              // Primary CTA: Retry (Welcome-style magenta pill button)
              SizedBox(
                width: double.infinity,
                child: WelcomeButton(
                  label: l10n.splashGateRetryCta,
                  onPressed: _hasUsedManualRetry ? null : _handleRetry,
                ),
              ),
              const SizedBox(height: Spacing.m),
              // Secondary CTA: Sign out (outline style)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onSignOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DsColors.welcomeButtonBg,
                    side: const BorderSide(color: DsColors.welcomeButtonBg),
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.welcomeButtonPaddingVertical,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Sizes.radiusWelcomeButton),
                    ),
                  ),
                  child: Text(l10n.splashGateSignOutCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  TestConfig.ensureInitialized();

  Widget buildTestApp({
    required VoidCallback onSignOut,
    Locale locale = const Locale('de'),
  }) {
    return ProviderScope(
      overrides: [initModeProvider.overrideWithValue(InitMode.test)],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: _TestableUnknownUI(onSignOut: onSignOut),
      ),
    );
  }

  group('SplashScreen Unknown UI', () {
    testWidgets('renders all UI elements correctly (DE)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        onSignOut: () {},
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Verify all text elements are present
      expect(find.text(l10n.splashGateUnknownTitle), findsOneWidget);
      expect(find.text(l10n.splashGateUnknownBody), findsOneWidget);
      expect(find.text(l10n.splashGateRetryCta), findsOneWidget);
      expect(find.text(l10n.splashGateSignOutCta), findsOneWidget);

      // Verify icon is present
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      // Verify buttons are present (WelcomeButton wraps ElevatedButton)
      expect(find.byType(WelcomeButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders all UI elements correctly (EN)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        onSignOut: () {},
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.splashGateUnknownTitle), findsOneWidget);
      expect(find.text(l10n.splashGateUnknownBody), findsOneWidget);
      expect(find.text(l10n.splashGateRetryCta), findsOneWidget);
      expect(find.text(l10n.splashGateSignOutCta), findsOneWidget);
    });

    testWidgets('Retry button is enabled initially', (tester) async {
      await tester.pumpWidget(buildTestApp(onSignOut: () {}));
      await tester.pumpAndSettle();

      // Find the WelcomeButton (Retry)
      final retryButton = tester.widget<WelcomeButton>(find.byType(WelcomeButton));

      // Button should be enabled (onPressed is not null)
      expect(retryButton.onPressed, isNotNull);
    });

    testWidgets('Retry button becomes disabled after click', (tester) async {
      await tester.pumpWidget(buildTestApp(onSignOut: () {}));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Initial state: button enabled
      var retryButton = tester.widget<WelcomeButton>(find.byType(WelcomeButton));
      expect(retryButton.onPressed, isNotNull);

      // Tap the retry button
      await tester.tap(find.text(l10n.splashGateRetryCta));
      await tester.pumpAndSettle();

      // After tap: button disabled (onPressed is null)
      retryButton = tester.widget<WelcomeButton>(find.byType(WelcomeButton));
      expect(retryButton.onPressed, isNull);
    });

    testWidgets('Sign out button triggers callback', (tester) async {
      bool callbackTriggered = false;

      await tester.pumpWidget(buildTestApp(
        onSignOut: () {
          callbackTriggered = true;
        },
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Tap Sign out button
      await tester.tap(find.text(l10n.splashGateSignOutCta));
      await tester.pumpAndSettle();

      expect(callbackTriggered, isTrue);
    });

    testWidgets('Sign out button remains enabled after Retry click',
        (tester) async {
      await tester.pumpWidget(buildTestApp(onSignOut: () {}));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Click Retry first
      await tester.tap(find.text(l10n.splashGateRetryCta));
      await tester.pumpAndSettle();

      // Sign out should still be enabled
      final signOutButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(signOutButton.onPressed, isNotNull);
    });

    testWidgets('has correct semantics for accessibility', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(buildTestApp(onSignOut: () {}));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(_TestableUnknownUI));
        final l10n = AppLocalizations.of(context)!;

        // Icon should have semantic label
        final iconFinder = find.byIcon(Icons.cloud_off_outlined);
        expect(iconFinder, findsOneWidget);

        final icon = tester.widget<Icon>(iconFinder);
        expect(icon.semanticLabel, equals(l10n.splashGateUnknownTitle));
      } finally {
        handle.dispose();
      }
    });
  });

  group('SplashScreen Unknown UI Navigation', () {
    GoRouter createTestRouter() {
      return GoRouter(
        initialLocation: '/unknown',
        routes: [
          GoRoute(
            path: '/unknown',
            builder: (context, state) => _TestableUnknownUI(
              onSignOut: () => context.go(AuthSignInScreen.routeName),
            ),
          ),
          GoRoute(
            path: AuthSignInScreen.routeName,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('AuthSignInScreen')),
            ),
          ),
        ],
      );
    }

    testWidgets('Sign out navigates to AuthSignInScreen', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(ProviderScope(
        overrides: [initModeProvider.overrideWithValue(InitMode.test)],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Tap Sign out
      await tester.tap(find.text(l10n.splashGateSignOutCta));
      await tester.pumpAndSettle();

      // Should navigate to AuthSignInScreen
      expect(find.text('AuthSignInScreen'), findsOneWidget);
    });
  });
}
