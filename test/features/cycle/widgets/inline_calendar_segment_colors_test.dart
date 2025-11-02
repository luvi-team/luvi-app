import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/cycle/domain/week_strip.dart';
import 'package:luvi_app/features/cycle/widgets/cycle_inline_calendar.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Segment painter exposes phases and colors via debug callback', (
    tester,
  ) async {
    // 28-day baseline where week view spans multiple phases
    final today = DateTime(2025, 9, 21);
    final cycleInfo = CycleInfo(
      lastPeriod: DateTime(2025, 9, 1),
      cycleLength: 28,
      periodDuration: 5,
    );
    final view = weekViewFor(today, cycleInfo);

    // Capture debug segments from painter
    List<PaintedSegmentDebug>? captured;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Theme(
            data: AppTheme.buildAppTheme(),
            child: Builder(
              builder: (context) {
                final tokens = Theme.of(context).extension<CyclePhaseTokens>()!;
                return CycleInlineCalendar(
                  view: view,
                  onSegmentsPainted: (segments) {
                    captured = segments;
                    // Expect colors to map to phase tokens with required opacities
                    for (final s in segments) {
                      switch (s.phase) {
                        case Phase.menstruation:
                          expect(
                            s.color,
                            equals(tokens.menstruation.withValues(alpha: 0.25)),
                            reason: 'Menstruation segment color opacity mapping',
                          );
                          break;
                        case Phase.follicular:
                          expect(
                            s.color,
                            equals(tokens.follicularDark.withValues(alpha: 0.20)),
                            reason: 'Follicular segment color opacity mapping',
                          );
                          break;
                        case Phase.ovulation:
                          expect(
                            s.color,
                            equals(tokens.ovulation.withValues(alpha: 0.50)),
                            reason: 'Ovulation segment color opacity mapping',
                          );
                          break;
                        case Phase.luteal:
                          expect(
                            s.color,
                            equals(tokens.luteal.withValues(alpha: 0.25)),
                            reason: 'Luteal segment color opacity mapping',
                          );
                          break;
                      }
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure callback was invoked and segments captured
    expect(captured, isNotNull, reason: 'Segments should be captured for debug');
    expect(captured!.isNotEmpty, isTrue, reason: 'At least one segment expected');

    // Sanity: rects should have positive width and match track height region
    for (final s in captured!) {
      expect(s.rect.width > 0, isTrue, reason: 'Segment has positive width');
      expect(s.rect.height > 0, isTrue, reason: 'Segment has positive height');
    }
  });
}
