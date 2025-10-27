import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/dashboard/weekly_training_card.dart';
import 'package:luvi_app/features/widgets/dashboard/cycle_tip_card.dart';
import 'package:luvi_app/features/widgets/recommendation_card.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

// ignore: unused_import
import '../../support/test_config.dart';

void main() {
    setUpAll(() async {
    await initializeDateFormatting('de_DE', null);
  });

  group('waveBottomRevealForWidth', () {
    test('scales reveal proportionally to viewport width', () {
      expect(
        waveBottomRevealForWidth(214, 40), // half the asset width
        closeTo(20, 0.001),
      );
    });

    test('clamps reveal when hero gap is smaller than scaled arc', () {
      expect(
        waveBottomRevealForWidth(856, 30), // double width => 80px reveal
        30,
      );
    });
  });

  group('HeuteScreen', () {
    testWidgets('renders key dashboard sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Check that section titles are rendered
      final ctx = tester.element(find.byType(HeuteScreen));
      final loc = AppLocalizations.of(ctx)!;
      if (TestConfig.featureDashboardV2) {
        expect(find.text(loc.dashboardTrainingWeekTitle), findsOneWidget);
        expect(find.text(loc.dashboardCategoriesTitle), findsNothing);
      } else {
        expect(find.text(loc.dashboardCategoriesTitle), findsOneWidget);
        expect(find.text(loc.dashboardTrainingWeekTitle), findsNothing);
      }
      if (TestConfig.featureDashboardV2) {
        // V2: Legacy sections hidden (scrolled to y=600, would see if visible)
        expect(find.text(loc.dashboardMoreTrainingsTitle), findsNothing);
        expect(find.text(loc.dashboardTrainingDataTitle), findsNothing);
      } else {
        // V1: Legacy sections visible
        expect(find.text(loc.dashboardMoreTrainingsTitle), findsOneWidget);
        expect(find.text(loc.dashboardTrainingDataTitle), findsOneWidget);
      }
      if (!TestConfig.featureDashboardV2) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      if (TestConfig.featureDashboardV2) {
        expect(find.text(loc.dashboardTopRecommendationTitle), findsNothing);
      } else {
        expect(find.text(loc.dashboardTopRecommendationTitle), findsOneWidget);
      }
      if (TestConfig.featureDashboardV2) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(find.text(loc.dashboardRecommendationsTitle), findsOneWidget);
      }
    });

    testWidgets(
      'renders weekly training section when feature flag enabled',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.buildAppTheme(),
            home: const HeuteScreen(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(HeuteScreen));
        final loc = AppLocalizations.of(ctx)!;
        expect(
          find.byKey(const Key('dashboard_weekly_training_section')),
          findsOneWidget,
        );
        expect(find.text(loc.dashboardTrainingWeekTitle), findsOneWidget);
        expect(find.text(loc.dashboardTrainingWeekSubtitle), findsOneWidget);
        expect(find.byType(WeeklyTrainingCard), findsAtLeastNWidgets(2));
        final weeklyList = find.descendant(
          of: find.byKey(const Key('dashboard_weekly_training_section')),
          matching: find.byType(ListView),
        );
        await tester.drag(weeklyList, const Offset(-600, 0));
        await tester.pumpAndSettle();
      },
      skip: !TestConfig.featureDashboardV2,
    );

    testWidgets('renders 4 category labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      // Check that all 4 category labels are present
      final ctx = tester.element(find.byType(HeuteScreen));
      final loc = AppLocalizations.of(ctx)!;
      expect(find.text(loc.dashboardCategoryTraining), findsOneWidget);
      expect(find.text(loc.dashboardCategoryNutrition), findsOneWidget);
      expect(find.text(loc.dashboardCategoryRegeneration), findsOneWidget);
      expect(find.text(loc.dashboardCategoryMindfulness), findsOneWidget);
    }, skip: TestConfig.featureDashboardV2);

    testWidgets('renders horizontal list with 3 recommendation cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Check that the 3 recommendation titles are present
      if (!TestConfig.featureDashboardV2) {
        // V1: Recommendations visible
        expect(find.text('Beine & Po'), findsOneWidget);
        expect(find.text('Rücken & Schulter'), findsOneWidget);
        expect(find.text('Ganzkörper'), findsOneWidget);
      } else {
        // V2: Recommendations hidden (scrolled to y=600, would see if visible)
        expect(find.text('Beine & Po'), findsNothing);
        expect(find.text('Rücken & Schulter'), findsNothing);
        expect(find.text('Ganzkörper'), findsNothing);
      }
    });

    testWidgets('renders training stats scroller with glass cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();

      if (!TestConfig.featureDashboardV2) {
        // V1: Stats scroller visible
        expect(
          find.byKey(const Key('dashboard_training_stats_scroller')),
          findsOneWidget,
        );
        expect(find.text('Puls'), findsOneWidget);
        expect(find.text('Verbrannte\nEnergie'), findsOneWidget);
        expect(find.text('Schritte'), findsOneWidget);
        expect(find.text('bpm'), findsOneWidget);
        expect(find.text('2.500'), findsOneWidget);
      } else {
        // V2: Stats scroller hidden (scrolled to y=900, would see if visible)
        expect(
          find.byKey(const Key('dashboard_training_stats_scroller')),
          findsNothing,
        );
      }
    });

    testWidgets(
      'hides legacy sections when feature flag enabled',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.buildAppTheme(),
            home: const HeuteScreen(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        );
        await tester.pumpAndSettle();
        // Scroll far enough to reach where legacy sections would appear
        // (prevents false positive if sections are just off-screen)
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(HeuteScreen));
        final loc = AppLocalizations.of(ctx)!;

        // Verify legacy sections are hidden (not just off-screen)
        expect(find.text(loc.dashboardMoreTrainingsTitle), findsNothing);
        expect(find.text(loc.dashboardTrainingDataTitle), findsNothing);
        expect(
          find.byKey(const Key('dashboard_training_stats_scroller')),
          findsNothing,
        );
        expect(find.byType(CycleTipCard), findsNothing);

        // Verify top recommendation is hidden in V2
        expect(find.text(loc.dashboardTopRecommendationTitle), findsNothing);
      },
      skip: !TestConfig.featureDashboardV2,
    );

    testWidgets(
      'renders phase recommendations section when feature flag enabled',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.buildAppTheme(),
            home: const HeuteScreen(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1200),
        );
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(HeuteScreen));
        final loc = AppLocalizations.of(ctx)!;

        expect(find.text(loc.dashboardRecommendationsTitle), findsOneWidget);
        expect(find.text(loc.dashboardNutritionTitle), findsOneWidget);
        expect(find.text(loc.dashboardRegenerationTitle), findsOneWidget);
        expect(find.byType(RecommendationCard), findsAtLeastNWidgets(4));
      },
      skip: !TestConfig.featureDashboardV2,
    );
  });
}
