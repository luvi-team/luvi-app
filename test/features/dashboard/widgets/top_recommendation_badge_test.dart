import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/dashboard/widgets/top_recommendation_tile.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.setup();

  TopRecommendationTile buildTile({required bool fromLuviSync}) {
    return TopRecommendationTile(
      workoutId: 'reco-shoulder-stretching',
      tag: 'Kraft',
      title: 'Shoulder Stretching',
      imagePath: 'assets/images/dashboard/reco.ganzkoerper.png',
      badgeAssetPath: 'assets/icons/dashboard/navhero.sync.png',
      fromLuviSync: fromLuviSync,
    );
  }

  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets(
    'shows LUVI Sync badge and semantics when recommendation originates from sync',
    (tester) async {
      await tester.pumpWidget(wrapWithApp(buildTile(fromLuviSync: true)));
      await tester.pump();

      final l10n = await AppLocalizations.delegate.load(const Locale('de'));
      final baseLabel =
          '${l10n.topRecommendation} Shoulder Stretching. ${l10n.category} Kraft.';
      final expectedLabel = '$baseLabel ${l10n.fromLuviSync}.';

      expect(find.byKey(const Key('top_recommendation_badge')), findsOneWidget);
      expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);
    },
  );

  testWidgets(
    'hides LUVI Sync badge and semantics when recommendation is local',
    (tester) async {
      await tester.pumpWidget(wrapWithApp(buildTile(fromLuviSync: false)));
      await tester.pump();

      final l10n = await AppLocalizations.delegate.load(const Locale('de'));
      final baseLabel =
          '${l10n.topRecommendation} Shoulder Stretching. ${l10n.category} Kraft.';
      final syncLabel = '$baseLabel ${l10n.fromLuviSync}.';

      expect(find.byKey(const Key('top_recommendation_badge')), findsNothing);
      expect(find.bySemanticsLabel(syncLabel), findsNothing);
      expect(find.bySemanticsLabel(baseLabel), findsOneWidget);
    },
  );
}
