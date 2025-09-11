import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:luvi_app/widgets/phase_badge.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';

void main() {
  testWidgets('Badge hides without consent & shows with consent', (t) async {
    final info = CycleInfo(
      lastPeriod: DateTime(2025, 9, 1),
      cycleLength: 28,
      periodDuration: 4,
    );
    await t.pumpWidget(
      MaterialApp(
        home: PhaseBadge(
          info: info,
          date: DateTime(2025, 9, 1),
          consentGiven: false,
        ),
      ),
    );
    expect(find.byKey(const Key('phase-text')), findsNothing);
    await t.pumpWidget(
      MaterialApp(
        home: PhaseBadge(
          info: info,
          date: DateTime(2025, 9, 1),
          consentGiven: true,
        ),
      ),
    );
    expect(find.text('Menstruation'), findsOneWidget);
  });

  testWidgets('Badge remains hidden without consent for non-period date', (
    t,
  ) async {
    final info = CycleInfo(
      lastPeriod: DateTime(2025, 9, 1),
      cycleLength: 28,
      periodDuration: 4,
    );
    // Test with a date in the follicular phase
    await t.pumpWidget(
      MaterialApp(
        home: PhaseBadge(
          info: info,
          date: DateTime(2025, 9, 7),
          consentGiven: false,
        ),
      ),
    );
    expect(find.byKey(const Key('phase-text')), findsNothing);
  });
}
