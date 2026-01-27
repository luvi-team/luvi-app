import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/dashboard/domain/models/recommendation.dart';
import 'package:luvi_app/features/dashboard/widgets/phase_recommendations_section.dart';
import 'package:luvi_app/features/dashboard/widgets/recommendation_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  const nutrition = <Recommendation>[
    Recommendation(
      tag: 'makros',
      title: 'Protein Fokus',
      imagePath: 'assets/images/dashboard/nutrition_1.png',
      subtitle: '20g pro Mahlzeit',
    ),
  ];
  const regeneration = <Recommendation>[
    Recommendation(
      tag: 'schlaf',
      title: 'Schlafroutine',
      imagePath: 'assets/images/dashboard/regeneration_1.png',
      subtitle: '8 Stunden Ziel',
    ),
    Recommendation(
      tag: 'achtsamkeit',
      title: 'Atemübung',
      imagePath: 'assets/images/dashboard/regeneration_2.png',
    ),
  ];

  group('PhaseRecommendationsSection', () {
    testWidgets('renders localized titles and recommendation cards', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('de'));
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: PhaseRecommendationsSection(
              nutritionRecommendations: nutrition,
              regenerationRecommendations: regeneration,
            ),
          ),
        ),
      );

      expect(find.text(l10n.dashboardRecommendationsTitle), findsOneWidget);
      expect(find.text(l10n.dashboardNutritionTitle), findsOneWidget);
      expect(find.text(l10n.dashboardRegenerationTitle), findsOneWidget);
      expect(
        find.byType(RecommendationCard),
        findsNWidgets(nutrition.length + regeneration.length),
      );
    });

    testWidgets('shows empty placeholder when lists are empty', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('de'));
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: const PhaseRecommendationsSection(
              nutritionRecommendations: [],
              regenerationRecommendations: [],
            ),
          ),
        ),
      );

      expect(find.byType(RecommendationCard), findsNothing);
      expect(find.text(l10n.dashboardRecommendationsEmpty), findsNWidgets(2));
    });
  });
}
