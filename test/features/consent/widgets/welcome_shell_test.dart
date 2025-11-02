import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_app.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  testWidgets('WelcomeShell shows title semantics and wave', (tester) async {
    await tester.pumpWidget(
      buildLocalizedApp(
        theme: AppTheme.buildAppTheme(),
        home: const ConsentWelcome01Screen(),
      ),
    );

    await tester.pumpAndSettle();

    final shellContext = tester.element(find.byType(WelcomeShell));
    final l10n = AppLocalizations.of(shellContext)!;
    final richTitle = tester.widget<RichText>(
      find.descendant(
        of: find.byType(WelcomeShell),
        matching: find.byType(RichText),
      ).first,
    );
    final plainText = richTitle.text.toPlainText();
    expect(plainText, contains(l10n.welcome01TitlePrefix.trim()));
    expect(plainText, contains(l10n.welcome01TitleAccent.trim()));
    expect(plainText, contains(l10n.welcome01TitleSuffixLine1.trim()));
    expect(plainText, contains(l10n.welcome01TitleSuffixLine2.trim()));

    // Wave SVG present and asset path verified
    final svgFinder = find.byType(SvgPicture);
    expect(svgFinder, findsWidgets);

    final svg = tester.widget<SvgPicture>(svgFinder.first);
    // Version-flexible asset path extraction (flutter_svg v1/v2)
    final assetName = (() {
      try {
        final provider = (svg as dynamic).pictureProvider; // flutter_svg v1.x
        try {
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          return (provider as dynamic).assetName as String;
        } catch (_) {
          return provider.toString();
        }
      } catch (_) {
        // flutter_svg v2.x: uses loaders instead of picture providers
        try {
          final loader = (svg as dynamic).bytesLoader; // common in v2
          try {
            return (loader as dynamic).assetName as String;
          } catch (_) {
            return loader.toString();
          }
        } catch (_) {
          try {
            final loader = (svg as dynamic).loader; // alternate name
            try {
              return (loader as dynamic).assetName as String;
            } catch (_) {
              return loader.toString();
            }
          } catch (_) {
            return svg.toString();
          }
        }
      }
    })();

    expect(assetName, contains(Assets.images.welcomeWave));

    // Semantics header present
    final handle = tester.ensureSemantics();
    try {
      final headerFinder = find.byWidgetPredicate(
        (w) => w is Semantics && (w.properties.header == true),
      );
      expect(headerFinder, findsWidgets);
    } finally {
      handle.dispose();
    }
  });
}
