import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/features/splash/widgets/unknown_state_ui.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

/// Test wrapper that manages state for [UnknownStateUi] testing.
///
/// Mirrors production behavior with 3 max retries and isRetrying state.
class _TestWrapper extends StatefulWidget {
  const _TestWrapper({required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  State<_TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<_TestWrapper> {
  static const _maxRetries = 3;
  int _retryCount = 0;
  bool _isRetrying = false;

  bool get _canRetry => _retryCount < _maxRetries;

  void _handleRetry() {
    if (!mounted || !_canRetry) return;
    setState(() {
      _retryCount++;
      _isRetrying = true;
    });
    // Simulate async completion (in real app this triggers navigation)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isRetrying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.welcomeWaveBg,
      body: UnknownStateUi(
        onRetry: _canRetry ? _handleRetry : null,
        onSignOut: widget.onSignOut,
        canRetry: _canRetry,
        isRetrying: _isRetrying,
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
        home: _TestWrapper(onSignOut: onSignOut),
      ),
    );
  }

  group('UnknownStateUi', () {
    testWidgets('renders all UI elements correctly (DE)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        onSignOut: () {},
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UnknownStateUi));
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

      final context = tester.element(find.byType(UnknownStateUi));
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
      final retryButton =
          tester.widget<WelcomeButton>(find.byType(WelcomeButton));

      // Button should be enabled (onPressed is not null)
      expect(retryButton.onPressed, isNotNull);
    });

    testWidgets('Retry button disabled after 3 clicks (production behavior)',
        (tester) async {
      await tester.pumpWidget(buildTestApp(onSignOut: () {}));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UnknownStateUi));
      final l10n = AppLocalizations.of(context)!;

      // Click retry 3 times
      for (var i = 0; i < 3; i++) {
        final retryButton =
            tester.widget<WelcomeButton>(find.byType(WelcomeButton));
        expect(retryButton.onPressed, isNotNull,
            reason: 'Retry should be enabled before click ${i + 1}');

        await tester.tap(find.text(l10n.splashGateRetryCta));
        await tester.pump(); // Process the setState
        await tester.pump(const Duration(milliseconds: 150)); // Wait for async
      }

      // After 3 clicks, button should be disabled
      final retryButton =
          tester.widget<WelcomeButton>(find.byType(WelcomeButton));
      expect(retryButton.onPressed, isNull,
          reason: 'Retry should be disabled after 3 attempts');
    });

    testWidgets('shows loading spinner during retry', (tester) async {
      await tester.pumpWidget(buildTestApp(onSignOut: () {}));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UnknownStateUi));
      final l10n = AppLocalizations.of(context)!;

      // Tap retry button
      await tester.tap(find.text(l10n.splashGateRetryCta));
      await tester.pump(); // Process setState (isRetrying = true)

      // During retry, isLoading should be true
      final retryButton =
          tester.widget<WelcomeButton>(find.byType(WelcomeButton));
      expect(retryButton.isLoading, isTrue,
          reason: 'Button should show loading state during retry');

      // After async completes, loading should be false
      await tester.pump(const Duration(milliseconds: 150));
      final retryButtonAfter =
          tester.widget<WelcomeButton>(find.byType(WelcomeButton));
      expect(retryButtonAfter.isLoading, isFalse,
          reason: 'Button should stop loading after retry completes');
    });

    testWidgets('Sign out button triggers callback', (tester) async {
      bool callbackTriggered = false;

      await tester.pumpWidget(buildTestApp(
        onSignOut: () {
          callbackTriggered = true;
        },
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UnknownStateUi));
      final l10n = AppLocalizations.of(context)!;

      // Tap Sign out button
      await tester.tap(find.text(l10n.splashGateSignOutCta));
      await tester.pumpAndSettle();

      expect(callbackTriggered, isTrue);
    });

    testWidgets('Sign out button remains enabled after Retry clicks',
        (tester) async {
      await tester.pumpWidget(buildTestApp(onSignOut: () {}));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UnknownStateUi));
      final l10n = AppLocalizations.of(context)!;

      // Click Retry multiple times
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text(l10n.splashGateRetryCta));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
      }

      // Sign out should still be enabled
      final signOutButton =
          tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(signOutButton.onPressed, isNotNull);
    });

    testWidgets('has correct semantics for accessibility', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(buildTestApp(onSignOut: () {}));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(UnknownStateUi));
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

  group('UnknownStateUi Navigation', () {
    GoRouter createTestRouter() {
      return GoRouter(
        initialLocation: '/unknown',
        routes: [
          GoRoute(
            path: '/unknown',
            builder: (context, state) => _TestWrapper(
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

      final context = tester.element(find.byType(UnknownStateUi));
      final l10n = AppLocalizations.of(context)!;

      // Tap Sign out
      await tester.tap(find.text(l10n.splashGateSignOutCta));
      await tester.pumpAndSettle();

      // Should navigate to AuthSignInScreen
      expect(find.text('AuthSignInScreen'), findsOneWidget);
    });
  });
}
