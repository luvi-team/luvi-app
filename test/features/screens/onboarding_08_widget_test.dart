import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/features/screens/onboarding_08.dart';
import 'package:luvi_app/features/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/shared/analytics/analytics_recorder.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/test_config.dart';

class _AnalyticsEvent {
  _AnalyticsEvent(this.name, Map<String, Object?> properties)
    : properties = Map.unmodifiable(properties);

  final String name;
  final Map<String, Object?> properties;
}

class _RecordingAnalyticsRecorder implements AnalyticsRecorder {
  final List<_AnalyticsEvent> events = [];

  @override
  void recordEvent(
    String name, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) {
    events.add(_AnalyticsEvent(name, Map<String, Object?>.from(properties)));
  }
}

void main() {
  TestConfig.setup();

  late SharedPreferences prefs;
  late UserStateService userStateService;
  late _RecordingAnalyticsRecorder analyticsRecorder;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    userStateService = UserStateService(prefs: prefs);
    analyticsRecorder = _RecordingAnalyticsRecorder();
  });

  Future<void> pumpRouter(
    WidgetTester tester, {
    required GoRouter router,
    Locale locale = const Locale('de'),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userStateServiceProvider.overrideWith(
            (ref) async => userStateService,
          ),
          analyticsRecorderProvider.overrideWithValue(analyticsRecorder),
        ],
        child: MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Onboarding08Screen', () {
    testWidgets(
      'option tap persists selection and navigates to success screen',
      (tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: Onboarding08Screen.routeName,
              builder: (context, state) => const Onboarding08Screen(),
            ),
            GoRoute(
              path: OnboardingSuccessScreen.routeName,
              builder: (context, state) =>
                  const Scaffold(body: Text('Success Screen')),
            ),
          ],
          initialLocation: Onboarding08Screen.routeName,
        );

        await pumpRouter(tester, router: router);

        final cta = find.byKey(const Key('onb_cta'));
        expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNull);

        final firstOption = find.byKey(const Key('onb_option_0'));
        await tester.tap(firstOption);
        await tester.pumpAndSettle();

        expect(userStateService.fitnessLevel, FitnessLevel.beginner);
        expect(prefs.getString('onboarding_fitness_level'), 'beginner');

        expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNotNull);
        await tester.ensureVisible(cta);
        await tester.pumpAndSettle();
        await tester.tap(cta);
        await tester.pumpAndSettle();

        expect(find.text('Success Screen'), findsOneWidget);
        expect(analyticsRecorder.events, hasLength(1));
        final event = analyticsRecorder.events.single;
        expect(event.name, 'onboarding_fitness_level_selected');
        expect(event.properties['level'], 'beginner');
        expect(event.properties['selection_index'], 0);
      },
    );

    testWidgets('back button navigates to 07 when canPop is false', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding07Screen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 07')),
          ),
          GoRoute(
            path: Onboarding08Screen.routeName,
            builder: (context, state) => const Onboarding08Screen(),
          ),
        ],
        initialLocation: Onboarding08Screen.routeName,
      );

      await pumpRouter(tester, router: router);

      final screenContext = tester.element(find.byType(Onboarding08Screen));
      final l10n = AppLocalizations.of(screenContext)!;
      expect(find.text(l10n.onboarding08Title), findsOneWidget);
      expect(
        find.text(l10n.onboardingStepFraction(8, kOnboardingTotalSteps)),
        findsOneWidget,
      );

      final backButton = find.byType(BackButtonCircle);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Onboarding 07'), findsOneWidget);
    });

    testWidgets('displays all 4 fitness level options', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding08Screen.routeName,
            builder: (context, state) => const Onboarding08Screen(),
          ),
        ],
        initialLocation: Onboarding08Screen.routeName,
      );

      await pumpRouter(tester, router: router);

      final context = tester.element(find.byType(Onboarding08Screen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.byKey(const Key('onb_option_0')), findsOneWidget);
      expect(find.byKey(const Key('onb_option_1')), findsOneWidget);
      expect(find.byKey(const Key('onb_option_2')), findsOneWidget);
      expect(find.byKey(const Key('onb_option_3')), findsOneWidget);

      expect(find.text(l10n.onboarding08OptBeginner), findsOneWidget);
      expect(find.text(l10n.onboarding08OptOccasional), findsOneWidget);
      expect(find.text(l10n.onboarding08OptFit), findsOneWidget);
      expect(find.text(l10n.onboarding08OptUnknown), findsOneWidget);
      expect(find.text(l10n.onboarding08Footnote), findsOneWidget);
    });

    testWidgets('restores previously persisted fitness level selection', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_fitness_level': 'fit',
      });
      prefs = await SharedPreferences.getInstance();
      userStateService = UserStateService(prefs: prefs);
      analyticsRecorder = _RecordingAnalyticsRecorder();

      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding08Screen.routeName,
            builder: (context, state) => const Onboarding08Screen(),
          ),
        ],
        initialLocation: Onboarding08Screen.routeName,
      );

      await pumpRouter(tester, router: router);

      final selectedCard = tester.widget<GoalCard>(
        find.byKey(const Key('onb_option_2')),
      );
      expect(selectedCard.selected, isTrue);

      final cta = find.byKey(const Key('onb_cta'));
      expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNotNull);
    });
  });
}
