import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  group('HeuteScreen Hero CTA', () {
    testWidgets('CTA has a minimum 44px touch target (de)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const HeuteScreen(),
        ),
      );

      // Find CTA text from l10n ("Mehr" in de)
      final ctx = tester.element(find.byType(HeuteScreen));
      final l10n = AppLocalizations.of(ctx)!;
      final ctaTextFinder = find.text(l10n.dashboardHeroCtaMore);
      expect(ctaTextFinder, findsWidgets);

      // Measure tappable hit area (outer SizedBox around CTA)
      final sizeCandidates = find.ancestor(
        of: ctaTextFinder.first,
        matching: find.byType(SizedBox),
      );
      double maxHeight = 0;
      for (var i = 0; i < sizeCandidates.evaluate().length; i++) {
        final sz = tester.getSize(sizeCandidates.at(i));
        if (sz.height > maxHeight) maxHeight = sz.height;
      }
      expect(
        maxHeight,
        greaterThanOrEqualTo(44),
        reason: 'CTA tap target should be at least 44px tall',
      );
    });
  });
}
