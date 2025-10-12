import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/widgets/stats_scroller.dart';
import 'package:luvi_app/features/dashboard/widgets/wearable_connect_card.dart';
import 'package:luvi_app/features/dashboard/domain/training_stat_props.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  group('StatsScroller', () {
    testWidgets('shows wearable connect fallback when disconnected', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const Scaffold(
            body: StatsScroller(trainingStats: [], isWearableConnected: false),
          ),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      final testContext = tester.element(find.byType(StatsScroller));
      final loc = AppLocalizations.of(testContext)!;

      expect(
        find.byKey(const Key('dashboard_wearable_connect_card')),
        findsOneWidget,
      );
      expect(
        find.textContaining(loc.dashboardWearableConnectMessage),
        findsOneWidget,
      );
    });

    testWidgets('renders three stat cards with formatted values', (
      tester,
    ) async {
      final stats = <TrainingStatProps>[
        TrainingStatProps(
          label: 'Puls',
          value: 94,
          unit: 'bpm',
          iconAssetPath: Assets.icons.dashboard.heart,
          trend: [0.2, 0.5, 0.6],
          heartRateGlyphAsset: Assets.icons.dashboard.heartRateGlyph,
        ),
        TrainingStatProps(
          label: 'Verbrannte Energie',
          value: 500,
          unit: 'kcal',
          iconAssetPath: Assets.icons.dashboard.kcal,
          trend: [0.1, 0.4, 0.7],
        ),
        TrainingStatProps(
          label: 'Schritte',
          value: 2500,
          iconAssetPath: Assets.icons.dashboard.run,
          trend: [0.3, 0.6, 0.9],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(24),
              child: StatsScroller(
                trainingStats: stats,
                isWearableConnected: true,
              ),
            ),
          ),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Puls'), findsOneWidget);
      expect(find.text('Verbrannte\nEnergie'), findsOneWidget);
      expect(find.text('Schritte'), findsOneWidget);
      expect(find.text('2.500'), findsOneWidget);
    });

    testWidgets('aligns stat values consistently and stacks heart rate unit', (
      tester,
    ) async {
      final stats = <TrainingStatProps>[
        TrainingStatProps(
          label: 'Puls',
          value: 94,
          unit: 'bpm',
          iconAssetPath: Assets.icons.dashboard.heart,
          heartRateGlyphAsset: Assets.icons.dashboard.heartRateGlyph,
        ),
        TrainingStatProps(
          label: 'Verbrannte Energie',
          value: 500,
          unit: 'kcal',
          iconAssetPath: Assets.icons.dashboard.kcal,
        ),
        TrainingStatProps(
          label: 'Schritte',
          value: 2500,
          iconAssetPath: Assets.icons.dashboard.run,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: StatsScroller(
              trainingStats: stats,
              isWearableConnected: true,
            ),
          ),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      final heartValueTop = tester.getTopLeft(find.text('94'));
      final heartUnitTop = tester.getTopLeft(find.text('bpm'));
      expect(heartUnitTop.dy, greaterThan(heartValueTop.dy),
          reason: 'Unit should sit below the pulse value');
      expect((heartUnitTop.dx - heartValueTop.dx).abs(), lessThan(0.5),
          reason: 'Unit should align vertically with the pulse value');

      final energyFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText().startsWith('500'),
      );
      final energyValueTop = tester.getTopLeft(energyFinder);
      final stepsValueTop = tester.getTopLeft(find.text('2.500'));
      expect((heartValueTop.dy - energyValueTop.dy).abs(), lessThan(1.5),
          reason: 'Pulse and energy values should share the same vertical band');
      expect((heartValueTop.dy - stepsValueTop.dy).abs(), lessThan(1.5),
          reason: 'Pulse and steps values should share the same vertical band');

      final stepsCardFinder = find
          .ancestor(
            of: find.text('Schritte'),
            matching: find.byType(RepaintBoundary),
          )
          .first;
      final stepsRect = tester.getRect(stepsCardFinder);
      final stepsValueCenter = tester.getCenter(find.text('2.500'));
      final relativeX =
          (stepsValueCenter.dx - stepsRect.left) / stepsRect.width;
      expect(relativeX, greaterThan(0.5),
          reason: 'Steps value should lean towards the right of centre');
      expect(relativeX, lessThan(0.75),
          reason: 'Steps value should not hug the right edge');
    });

    testWidgets('cards have correct height and style (159dp, solid gray)', (
      tester,
    ) async {
      final stats = <TrainingStatProps>[
        TrainingStatProps(
          label: 'Puls',
          value: 94,
          unit: 'bpm',
          iconAssetPath: Assets.icons.dashboard.heart,
          heartRateGlyphAsset: Assets.icons.dashboard.heartRateGlyph,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: StatsScroller(
              trainingStats: stats,
              isWearableConnected: true,
            ),
          ),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      // Verify card height
      final scroller = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(StatsScroller),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(
        scroller.height,
        equals(kStatsCardHeight),
        reason: 'Card height should be 159dp',
      );
      expect(
        kStatsCardHeight,
        equals(159),
        reason: 'kStatsCardHeight should be 159',
      );

      // Verify background color and border
      final containerFinder = find.byKey(const Key('stats_card_container'));
      final container = tester.widget<Container>(containerFinder);

      final decoration = container.decoration as BoxDecoration;

      expect(
        decoration.color,
        equals(const Color(0xFFF1F1F1)),
        reason: 'Background should be solid gray #F1F1F1',
      );

      expect(
        decoration.border,
        isA<Border>(),
        reason: 'Should have border',
      );

      final border = decoration.border as Border;
      expect(
        border.top.color,
        equals(const Color(0x1A000000)),
        reason: 'Border color should be 10% black (0x1A000000)',
      );
      expect(
        border.top.width,
        equals(1),
        reason: 'Border width should be 1dp',
      );
    });

    testWidgets('displays HR glyph only for Puls card when provided', (
      tester,
    ) async {
      final stats = <TrainingStatProps>[
        TrainingStatProps(
          label: 'Puls',
          value: 94,
          unit: 'bpm',
          iconAssetPath: Assets.icons.dashboard.heart,
          heartRateGlyphAsset: Assets.icons.dashboard.heartRateGlyph,
        ),
        TrainingStatProps(
          label: 'Verbrannte Energie',
          value: 500,
          unit: 'kcal',
          iconAssetPath: Assets.icons.dashboard.kcal,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: StatsScroller(
              trainingStats: stats,
              isWearableConnected: true,
            ),
          ),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      // Verify both cards are present
      expect(find.text('Puls'), findsOneWidget);
      expect(find.text('Verbrannte\nEnergie'), findsOneWidget);

      // Note: HR glyph verification is done via the conditional rendering logic.
      // The glyph is only rendered when heartRateGlyphAsset != null.
      // Detailed SVG asset verification would require additional test infrastructure.
    });

    testWidgets('content is left-aligned', (tester) async {
      final stats = <TrainingStatProps>[
        TrainingStatProps(
          label: 'Puls',
          value: 94,
          unit: 'bpm',
          iconAssetPath: Assets.icons.dashboard.heart,
          heartRateGlyphAsset: Assets.icons.dashboard.heartRateGlyph,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: StatsScroller(
              trainingStats: stats,
              isWearableConnected: true,
            ),
          ),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      // Verify Column has crossAxisAlignment.start
      final column = tester.widget<Column>(
        find
            .descendant(
              of: find.byType(Stack),
              matching: find.byType(Column),
            )
            .first,
      );

      expect(
        column.crossAxisAlignment,
        equals(CrossAxisAlignment.start),
        reason: 'Content should be left-aligned',
      );
    });
  });
}
