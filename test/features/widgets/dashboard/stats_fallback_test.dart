import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/widgets/dashboard/stats_scroller.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
// ignore: unused_import
import '../../../support/test_config.dart';

void main() {
    TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
      locale: const Locale('de'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }

  testWidgets(
    'shows wearable connect fallback with accessible semantics when no wearable is connected',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const StatsScroller(trainingStats: [], isWearableConnected: false),
        ),
      );

      await tester.pumpAndSettle();

      final context = tester.element(find.byType(StatsScroller));
      final loc = AppLocalizations.of(context)!;

      expect(
        find.byKey(const Key('dashboard_wearable_connect_card')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(loc.dashboardWearableConnectMessage),
        findsOneWidget,
      );
    },
  );
}
