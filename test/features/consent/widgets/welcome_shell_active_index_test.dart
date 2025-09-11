import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/widgets/dots_indicator.dart';

void main() {
  testWidgets('WelcomeShell forwards activeIndex to DotsIndicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeShell(
          hero: const SizedBox(), // asset-free for test stability
          title: const Text('Test Title'),
          subtitle: 'Test Subtitle',
          onNext: () {},
          heroAspect: 438 / 619,
          waveHeightPx: 413.0,
          activeIndex: 1,
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
