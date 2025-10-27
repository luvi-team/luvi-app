import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/widgets/dashboard/cycle_tip_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  group('CycleTipCard l10n', () {
    testWidgets('renders localized headline and body per phase (de)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const Scaffold(body: CycleTipCard(phase: Phase.luteal)),
        ),
      );

      final ctx = tester.element(find.byType(CycleTipCard));
      final l10n = AppLocalizations.of(ctx)!;

      expect(find.text(l10n.cycleTipHeadlineLuteal), findsOneWidget);
      expect(find.text(l10n.cycleTipBodyLuteal), findsOneWidget);
    });
  });
}
