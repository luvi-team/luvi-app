import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/features/cycle/widgets/phase_badge.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
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
    expect(find.byKey(const Key(TestKeys.phaseText)), findsNothing);
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
    expect(find.byKey(const Key(TestKeys.phaseText)), findsNothing);
  });
}
