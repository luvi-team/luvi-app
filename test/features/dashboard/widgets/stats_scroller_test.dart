import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/widgets/stats_scroller.dart';
import 'package:luvi_app/features/screens/heute_fixtures.dart';

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
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('dashboard_wearable_connect_card')),
        findsOneWidget,
      );
      expect(find.textContaining('Verbinde dein Wearable'), findsOneWidget);
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
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Puls'), findsOneWidget);
      expect(find.text('Verbrannte Energie'), findsOneWidget);
      expect(find.text('Schritte'), findsOneWidget);
      expect(find.text('2.500'), findsOneWidget);
    });
  });
}
