import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/dashboard/top_recommendation_tile.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
// ignore: unused_import
import '../../../support/test_config.dart';

void main() {
    group('TopRecommendationTile semantics', () {
    testWidgets('uses localized label and hint (de)', (tester) async {
      const title = 'Foo';
      const tag = 'Kraft';
      const id = 'workout-1';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: TopRecommendationTile(
              workoutId: id,
              tag: tag,
              title: title,
              imagePath: 'assets/images/does_not_exist.png',
              badgeAssetPath: 'assets/images/does_not_exist_badge.png',
              fromLuviSync: true,
              duration: '15 Min',
            ),
          ),
        ),
      );

      final semanticsFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.button == true,
      );
      final semantics = tester.widget<Semantics>(semanticsFinder.first);

      final buildContext = tester.element(find.byType(TopRecommendationTile));
      final l10n = AppLocalizations.of(buildContext)!;

      final expectedLabel =
          '${l10n.topRecommendation} $title. ${l10n.category} $tag. ${l10n.fromLuviSync}.';
      expect(semantics.properties.label, equals(expectedLabel));
      expect(semantics.properties.hint, equals(l10n.tapToOpenWorkout));
    });
  });
}
