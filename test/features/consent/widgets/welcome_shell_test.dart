import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import '../../../support/test_app.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/core/widgets/welcome_button.dart';

import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  testWidgets('WelcomeShell shows title semantics and wave', (tester) async {
    await tester.pumpWidget(
      buildLocalizedApp(
        theme: AppTheme.buildAppTheme(),
        home: Scaffold(
          body: WelcomeShell(
            hero: const SizedBox(height: 200),
            heroAspect: 1.0,
            waveHeightPx: 300,
            title: const Text('Test Title'),
            subtitle: 'Test Subtitle',
            onNext: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Title is now a simple Text widget
    expect(find.text('Test Title'), findsOneWidget);

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

  testWidgets('WelcomeShell renders WelcomeButton with DS tokens', (
    tester,
  ) async {
    var buttonPressed = false;

    await tester.pumpWidget(
      buildLocalizedApp(
        theme: AppTheme.buildAppTheme(),
        home: Scaffold(
          body: WelcomeShell(
            hero: const SizedBox(height: 200),
            heroAspect: 1.0,
            waveHeightPx: 300,
            title: const Text('Test Title'),
            subtitle: 'Test Subtitle',
            onNext: () => buttonPressed = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify WelcomeButton is rendered inside WelcomeShell
    expect(find.byType(WelcomeButton), findsOneWidget);

    // 2. Verify button uses Design System token colors
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final style = button.style!;
    final bgColor = style.backgroundColor?.resolve({});
    expect(bgColor, equals(DsColors.welcomeButtonBg));

    // 3. Verify button is functional (onNext callback works)
    await tester.tap(find.byType(WelcomeButton));
    expect(buttonPressed, isTrue);
  });
}
