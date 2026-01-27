import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/dashboard/domain/weekly_training_props.dart';
import 'package:luvi_app/features/dashboard/widgets/weekly_training_card.dart';
import 'package:luvi_app/features/dashboard/widgets/weekly_training_section.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  const trainings = <WeeklyTrainingProps>[
    WeeklyTrainingProps(
      id: 't1',
      title: 'Kraft',
      subtitle: 'Unterkörper',
      imagePath: 'assets/images/dashboard/training_1.png',
      dayLabel: 'Mo',
      duration: '30 min',
    ),
    WeeklyTrainingProps(
      id: 't2',
      title: 'Cardio',
      subtitle: 'Intervall',
      imagePath: 'assets/images/dashboard/training_2.png',
      dayLabel: 'Di',
      duration: '25 min',
    ),
  ];

  group('WeeklyTrainingSection', () {
    testWidgets('renders section and cards for all trainings', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: WeeklyTrainingSection(
              trainings: trainings,
              onTrainingTap: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('dashboard_weekly_training_section')),
        findsOneWidget,
      );
      expect(find.byType(WeeklyTrainingCard), findsNWidgets(trainings.length));
    });

    testWidgets('tapping a training card triggers callback with id', (
      tester,
    ) async {
      final tappedIds = <String>[];
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: WeeklyTrainingSection(
              trainings: trainings,
              onTrainingTap: tappedIds.add,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Kraft'));
      await tester.pump();

      expect(tappedIds, equals(['t1']));
    });
  });
}
