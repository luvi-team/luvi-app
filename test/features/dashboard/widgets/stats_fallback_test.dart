import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/dashboard/widgets/stats_scroller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets(
    'shows wearable connect fallback with accessible semantics when no wearable is connected',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const StatsScroller(
            trainingStats: [],
            isWearableConnected: false,
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byKey(const Key('dashboard_wearable_connect_card')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Verbinde dein Wearable, um deine Trainingsdaten anzeigen zu lassen.',
        ),
        findsOneWidget,
      );
    },
  );
}
