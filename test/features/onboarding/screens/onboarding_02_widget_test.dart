import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_02.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_03_fitness.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/birthdate_picker.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

/// Test notifier that initializes with a pre-set birthDate.
/// Required for @riverpod notifier tests that need both state and notifier access.
class _PreSetOnboardingNotifier extends OnboardingNotifier {
  final DateTime _initialBirthDate;
  _PreSetOnboardingNotifier(this._initialBirthDate);

  @override
  OnboardingData build() => OnboardingData(birthDate: _initialBirthDate);
}

void main() {
  TestConfig.ensureInitialized();

  testWidgets('renders title and shows BirthdatePicker', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Onboarding01Screen.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 01')),
        ),
        GoRoute(
          path: Onboarding02Screen.routeName,
          builder: (context, state) => const Onboarding02Screen(),
        ),
        GoRoute(
          path: Onboarding03FitnessScreen.routeName,
          name: 'onboarding_03_fitness',
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 03')),
        ),
      ],
      initialLocation: Onboarding02Screen.routeName,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify personalized title renders (L10n: "Hey {name},\nwann hast du Geburtstag?")
    expect(find.textContaining('Hey'), findsOneWidget);
    expect(find.textContaining('wann hast du Geburtstag'), findsOneWidget);

    // Verify BirthdatePicker is present with 3 wheels
    expect(find.byType(BirthdatePicker), findsOneWidget);
    expect(find.byType(ListWheelScrollView), findsNWidgets(3));

    // Verify CTA is disabled initially
    final cta = find.byKey(const Key(TestKeys.onbCta));
    expect(cta, findsOneWidget);
    expect(tester.widget<OnboardingButton>(cta).isEnabled, isFalse);
  });

  testWidgets('back button navigates to onboarding 01', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Onboarding01Screen.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 01')),
        ),
        GoRoute(
          path: Onboarding02Screen.routeName,
          builder: (context, state) => const Onboarding02Screen(),
        ),
      ],
      initialLocation: Onboarding02Screen.routeName,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap back button
    await tester.tap(find.byType(BackButtonCircle));
    await tester.pumpAndSettle();

    // Verify navigation to O1
    expect(find.text('Onboarding 01'), findsOneWidget);
  });

  // Note: BirthdatePicker interaction tests are covered in
  // birthdate_picker_test.dart. The ListWheelScrollView drag gesture
  // requires special handling in widget tests.

  testWidgets('CTA enabled and navigates when birthDate is pre-set', (tester) async {
    // Pre-set birthDate via overrideWith with custom notifier
    // (Best Practice for @riverpod when notifier access is required)
    final preSetBirthDate = DateTime(2000, 6, 15);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: Onboarding01Screen.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 01')),
        ),
        GoRoute(
          path: Onboarding02Screen.routeName,
          builder: (context, state) => const Onboarding02Screen(),
        ),
        GoRoute(
          path: Onboarding03FitnessScreen.routeName,
          name: 'onboarding_03_fitness',
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 03')),
        ),
      ],
      initialLocation: Onboarding02Screen.routeName,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Best Practice: overrideWith for notifier tests requiring notifier access
          onboardingProvider.overrideWith(
            () => _PreSetOnboardingNotifier(preSetBirthDate),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify CTA is enabled when birthDate is pre-set
    final cta = find.byKey(const Key(TestKeys.onbCta));
    expect(cta, findsOneWidget);
    expect(tester.widget<OnboardingButton>(cta).isEnabled, isTrue);

    // Scroll CTA into view (required for Stack layout with BirthdatePicker overlay)
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();

    // Tap CTA and verify navigation to O3
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.text('Onboarding 03'), findsOneWidget);
  });
}
