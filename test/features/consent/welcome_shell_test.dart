import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';

void main() {
  testWidgets('WelcomeShell shows title semantics and wave', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        home: WelcomeShell(
          heroAsset: 'assets/images/consent/welcome_01.png',
          title: const Text('Dein Zyklus ist deine\nSuperkraft.'),
          subtitle:
              'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
          onNext: () {},
          heroAspect: 438 / 619,
          waveHeightPx: 413,
          waveAsset: 'assets/images/consent/welcome_wave.svg',
        ),
      ),
    );

    // Title present
    expect(find.textContaining('Dein Zyklus'), findsOneWidget);
    // Wave SVG present
    expect(find.byType(SvgPicture), findsWidgets);
  });
}
