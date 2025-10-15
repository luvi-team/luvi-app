import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
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

      // The immediate Container ancestor of the CTA Text holds the fixed height.
      final containerFinder = find
          .ancestor(of: ctaTextFinder.first, matching: find.byType(Container))
          .first;

      final Size size = tester.getSize(containerFinder);
      expect(
        size.height,
        greaterThanOrEqualTo(44),
        reason: 'CTA button should be at least 44px tall',
      );
    });
  });
}
