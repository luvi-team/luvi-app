import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_app.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/widgets/dots_indicator.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('WelcomeShell forwards activeIndex to DotsIndicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildLocalizedApp(
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return WelcomeShell(
              hero: const SizedBox(), // asset-free for test stability
              title: Text('${l10n.welcome01TitlePrefix} ${l10n.welcome01TitleAccent}'),
              subtitle: l10n.welcome01Subtitle,
              onNext: () {},
              heroAspect: 438 / 619,
              waveHeightPx: 413.0,
              activeIndex: 1,
            );
          },
        ),
      ),
    );

    final dotsIndicator = tester.widget<DotsIndicator>(
      find.byType(DotsIndicator),
    );
    expect(dotsIndicator.activeIndex, equals(1));

    final dot1 = find.byKey(const Key('dot_1'));
    expect(dot1, findsOneWidget);
  });
}
