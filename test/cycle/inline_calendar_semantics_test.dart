import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';
import 'package:luvi_app/features/cycle/domain/week_strip.dart';
import 'package:luvi_app/features/cycle/widgets/cycle_inline_calendar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Intl.defaultLocale = 'de_DE';
    await initializeDateFormatting('de_DE');
  });

  testWidgets(
    'CycleInlineCalendar exposes semantic label and renders seven day chips',
    (tester) async {
      final today = DateTime(2023, 9, 28);
      final cycleInfo = CycleInfo(
        lastPeriod: DateTime(2023, 9, 19),
        cycleLength: 28,
        periodDuration: 5,
      );
      final view = weekViewFor(today, cycleInfo);

      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de', 'DE'),
          supportedLocales: const [Locale('de', 'DE')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: Center(
              child: Theme(
                data: AppTheme.buildAppTheme(),
                child: CycleInlineCalendar(view: view),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final semanticsNode = tester.getSemantics(
        find.byKey(const ValueKey('cycle_inline_calendar_semantics')),
      );
      expect(
        semanticsNode.label,
        'Zykluskalender. Heute 28. Sept. Phase: Follikelphase.',
      );

      final dayNumberCount = tester
          .widgetList(find.byType(Text))
          .whereType<Text>()
          .where((text) => RegExp(r'^\d+$').hasMatch(text.data ?? ''))
          .length;

      expect(dayNumberCount, 7);

      semanticsHandle.dispose();
    },
  );
}
