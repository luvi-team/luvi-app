import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

/// Extracted Unknown UI widget for isolated testing.
///
/// This mirrors the `_buildUnknownUI` from SplashScreen but is testable.
class _TestableUnknownUI extends StatefulWidget {
  const _TestableUnknownUI({required this.onStartOnboarding});

  final VoidCallback onStartOnboarding;

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: DsColors.welcomeWaveBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: DsColors.textMuted,
                semanticLabel: l10n.splashGateUnknownTitle,
              ),
              const SizedBox(height: Spacing.l),
              Text(
                l10n.splashGateUnknownTitle,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.s),
              Text(
                l10n.splashGateUnknownBody,
                style: textTheme.bodyMedium?.copyWith(
                  color: DsColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _hasUsedManualRetry ? null : _handleRetry,
                  child: Text(l10n.splashGateRetryCta),
                ),
              ),
              const SizedBox(height: Spacing.s),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onStartOnboarding,
                  child: Text(l10n.splashGateStartOnboardingCta),
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
    required VoidCallback onStartOnboarding,
    Locale locale = const Locale('de'),
  }) {
    return ProviderScope(
      overrides: [initModeProvider.overrideWithValue(InitMode.test)],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: _TestableUnknownUI(onStartOnboarding: onStartOnboarding),
      ),
    );
  }

  group('SplashScreen Unknown UI', () {
    testWidgets('renders all UI elements correctly (DE)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        onStartOnboarding: () {},
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Verify all text elements are present
      expect(find.text(l10n.splashGateUnknownTitle), findsOneWidget);
      expect(find.text(l10n.splashGateUnknownBody), findsOneWidget);
      expect(find.text(l10n.splashGateRetryCta), findsOneWidget);
      expect(find.text(l10n.splashGateStartOnboardingCta), findsOneWidget);

      // Verify icon is present
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      // Verify buttons are present
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders all UI elements correctly (EN)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        onStartOnboarding: () {},
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.splashGateUnknownTitle), findsOneWidget);
      expect(find.text(l10n.splashGateUnknownBody), findsOneWidget);
      expect(find.text(l10n.splashGateRetryCta), findsOneWidget);
      expect(find.text(l10n.splashGateStartOnboardingCta), findsOneWidget);
    });

    testWidgets('Retry button is enabled initially', (tester) async {
      await tester.pumpWidget(buildTestApp(onStartOnboarding: () {}));
      await tester.pumpAndSettle();

      // Find the FilledButton (Retry)
      final retryButton = tester.widget<FilledButton>(find.byType(FilledButton));

      // Button should be enabled (onPressed is not null)
      expect(retryButton.onPressed, isNotNull);
    });

    testWidgets('Retry button becomes disabled after click', (tester) async {
      await tester.pumpWidget(buildTestApp(onStartOnboarding: () {}));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Initial state: button enabled
      var retryButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(retryButton.onPressed, isNotNull);

      // Tap the retry button
      await tester.tap(find.text(l10n.splashGateRetryCta));
      await tester.pumpAndSettle();

      // After tap: button disabled (onPressed is null)
      retryButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(retryButton.onPressed, isNull);
    });

    testWidgets('Start Onboarding button triggers callback', (tester) async {
      bool callbackTriggered = false;

      await tester.pumpWidget(buildTestApp(
        onStartOnboarding: () {
          callbackTriggered = true;
        },
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Tap Start Onboarding button
      await tester.tap(find.text(l10n.splashGateStartOnboardingCta));
      await tester.pumpAndSettle();

      expect(callbackTriggered, isTrue);
    });

    testWidgets('Start Onboarding button remains enabled after Retry click',
        (tester) async {
      await tester.pumpWidget(buildTestApp(onStartOnboarding: () {}));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestableUnknownUI));
      final l10n = AppLocalizations.of(context)!;

      // Click Retry first
      await tester.tap(find.text(l10n.splashGateRetryCta));
      await tester.pumpAndSettle();

      // Start Onboarding should still be enabled
      final startButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(startButton.onPressed, isNotNull);
    });

    testWidgets('has correct semantics for accessibility', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(buildTestApp(onStartOnboarding: () {}));
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
              onStartOnboarding: () => context.go(Onboarding01Screen.routeName),
            ),
          ),
          GoRoute(
            path: Onboarding01Screen.routeName,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Onboarding01Screen')),
            ),
          ),
        ],
      );
    }

    testWidgets('Start Onboarding navigates to Onboarding01Screen',
        (tester) async {
      final router = createTestRouter();

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

      // Tap Start Onboarding
      await tester.tap(find.text(l10n.splashGateStartOnboardingCta));
      await tester.pumpAndSettle();

      // Should navigate to Onboarding01Screen
      expect(find.text('Onboarding01Screen'), findsOneWidget);
    });
  });
}
