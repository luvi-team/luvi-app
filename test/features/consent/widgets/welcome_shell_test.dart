import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
// ignore: unused_import
import '../../../support/test_config.dart';

void main() {
    testWidgets('WelcomeShell shows title semantics and wave', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        home: WelcomeShell(
          hero: const SizedBox(), // asset-free for test stability
          title: const Text('Dein Zyklus ist deine\nSuperkraft.'),
          subtitle:
              'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
          onNext: () {},
          heroAspect: 438 / 619,
          waveHeightPx: 413,
          waveAsset: Assets.welcomeWave,
          activeIndex: 0,
        ),
      ),
    );

    // Title present
    expect(find.textContaining('Dein Zyklus'), findsOneWidget);

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

    expect(assetName, contains(Assets.welcomeWave));

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
