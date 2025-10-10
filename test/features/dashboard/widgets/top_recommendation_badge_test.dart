import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/dashboard/widgets/top_recommendation_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets(
    'shows LUVI Sync badge and semantics when recommendation originates from sync',
    (tester) async {
      await tester.pumpWidget(wrapWithApp(buildTile(fromLuviSync: true)));
      await tester.pump();

      expect(find.byKey(const Key('top_recommendation_badge')), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Top-Empfehlung Shoulder Stretching. Kategorie Kraft. Von LUVI Sync.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'hides LUVI Sync badge and semantics when recommendation is local',
    (tester) async {
      await tester.pumpWidget(wrapWithApp(buildTile(fromLuviSync: false)));
      await tester.pump();

      expect(find.byKey(const Key('top_recommendation_badge')), findsNothing);
      expect(
        find.bySemanticsLabel(
          'Top-Empfehlung Shoulder Stretching. Kategorie Kraft. Von LUVI Sync.',
        ),
        findsNothing,
      );
      expect(
        find.bySemanticsLabel(
          'Top-Empfehlung Shoulder Stretching. Kategorie Kraft.',
        ),
        findsOneWidget,
      );
    },
  );
}
