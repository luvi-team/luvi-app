import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/dashboard/widgets/cycle_tip_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/l10n/app_localizations_en.dart';

import '../../../support/test_config.dart';

class FakeAppLocalizations extends AppLocalizationsEn {
  FakeAppLocalizations(this.strings) : super('en');

  final Map<Phase, ({String headline, String body})> strings;

  @override
  String get cycleTipHeadlineMenstruation =>
      strings[Phase.menstruation]?.headline ?? super.cycleTipHeadlineMenstruation;

  @override
  String get cycleTipBodyMenstruation =>
      strings[Phase.menstruation]?.body ?? super.cycleTipBodyMenstruation;

  @override
  String get cycleTipHeadlineFollicular =>
      strings[Phase.follicular]?.headline ?? super.cycleTipHeadlineFollicular;

  @override
  String get cycleTipBodyFollicular =>
      strings[Phase.follicular]?.body ?? super.cycleTipBodyFollicular;

  @override
  String get cycleTipHeadlineOvulation =>
      strings[Phase.ovulation]?.headline ?? super.cycleTipHeadlineOvulation;

  @override
  String get cycleTipBodyOvulation =>
      strings[Phase.ovulation]?.body ?? super.cycleTipBodyOvulation;

  @override
  String get cycleTipHeadlineLuteal =>
      strings[Phase.luteal]?.headline ?? super.cycleTipHeadlineLuteal;

  @override
  String get cycleTipBodyLuteal =>
      strings[Phase.luteal]?.body ?? super.cycleTipBodyLuteal;
}

class _FakeAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _FakeAppLocalizationsDelegate(this.l10n);

  final FakeAppLocalizations l10n;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(l10n);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

void main() {
  TestConfig.ensureInitialized();

  group('CycleTipCard l10n', () {
    final fakeStrings = <Phase, ({String headline, String body})>{
      Phase.menstruation: (
        headline: 'headline menstruation',
        body: 'body menstruation',
      ),
      Phase.follicular: (headline: 'headline follicular', body: 'body follicular'),
      Phase.ovulation: (headline: 'headline ovulation', body: 'body ovulation'),
      Phase.luteal: (headline: 'headline luteal', body: 'body luteal'),
    };

    final fakeL10n = FakeAppLocalizations(fakeStrings);
    const locale = Locale('en');
    final delegates = <LocalizationsDelegate<dynamic>>[
      _FakeAppLocalizationsDelegate(fakeL10n),
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];

    testWidgets(
      'renders localized headline, body, and semantics for each phase',
      (tester) async {
        for (final phase in Phase.values) {
          final expected = fakeStrings[phase]!;
          final expectedSemantics = '${expected.headline}. ${expected.body}';

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.buildAppTheme(),
              localizationsDelegates: delegates,
              supportedLocales: const [locale],
              locale: locale,
              home: Scaffold(body: CycleTipCard(phase: phase)),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text(expected.headline), findsOneWidget);
          expect(find.text(expected.body), findsOneWidget);

          final semanticsFinder = find.descendant(
            of: find.byType(CycleTipCard),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.child is ExcludeSemantics &&
                  widget.properties.label == expectedSemantics,
            ),
          );

          expect(semanticsFinder, findsOneWidget);
          final semantics = tester.getSemantics(semanticsFinder);
          expect(semantics.label, equals(expectedSemantics));
        }
      },
    );
  });
}
