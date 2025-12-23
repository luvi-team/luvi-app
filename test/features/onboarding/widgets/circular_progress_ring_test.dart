import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/widgets/circular_progress_ring.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

Future<void> _pumpRing(
  WidgetTester tester, {
  Duration duration = const Duration(seconds: 3),
  VoidCallback? onAnimationComplete,
  double size = 200,
  GlobalKey<CircularProgressRingState>? ringKey,
  Locale locale = const Locale('de'),
  bool isSpinning = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: CircularProgressRing(
          key: ringKey,
          duration: duration,
          onAnimationComplete: onAnimationComplete,
          size: size,
          isSpinning: isSpinning,
        ),
      ),
    ),
  );
}

void main() {
  TestConfig.ensureInitialized();

  testWidgets('renders with correct size and initial state', (tester) async {
    await _pumpRing(tester, size: 150);

    final sizedBox = find.byType(SizedBox).first;
    final widget = tester.widget<SizedBox>(sizedBox);

    expect(widget.width, 150);
    expect(widget.height, 150);
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('animates progress and shows percentage', (tester) async {
    await _pumpRing(tester, duration: const Duration(milliseconds: 500));

    // Initial state
    expect(find.text('0%'), findsOneWidget);

    // Animate halfway
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('%'), findsOneWidget);

    // Complete animation (pump enough frames for progress to complete)
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('calls onAnimationComplete when animation finishes', (tester) async {
    bool completed = false;

    await _pumpRing(
      tester,
      duration: const Duration(milliseconds: 100),
      onAnimationComplete: () => completed = true,
    );

    expect(completed, isFalse);

    // Complete animation
    await tester.pump(const Duration(milliseconds: 150));

    expect(completed, isTrue);
  });

  testWidgets('has correct semantics in German', (tester) async {
    await _pumpRing(tester, locale: const Locale('de'), isSpinning: false);
    // Use pump instead of pumpAndSettle to avoid infinite animation loop
    await tester.pump();

    // Verify Semantics widget exists with the localized label
    final semanticsWidget = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Ladefortschritt',
    );
    expect(semanticsWidget, findsOneWidget);
  });

  testWidgets('has correct semantics in English', (tester) async {
    await _pumpRing(tester, locale: const Locale('en'), isSpinning: false);
    // Use pump instead of pumpAndSettle to avoid infinite animation loop
    await tester.pump();

    // Verify Semantics widget exists with the localized label
    final semanticsWidget = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Loading progress',
    );
    expect(semanticsWidget, findsOneWidget);
  });

  testWidgets('contains Transform.rotate for rotation animation', (tester) async {
    await _pumpRing(tester, isSpinning: true);
    await tester.pump();

    // Find Transform widget with non-identity rotation matrix
    // Note: Multiple Transforms may exist (e.g., FadeTransition uses Transform internally)
    final rotationTransformFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Transform && widget.transform != Matrix4.identity(),
    );

    expect(rotationTransformFinder, findsAtLeastNWidgets(1));
  });

  testWidgets('stops rotation when isSpinning is false', (tester) async {
    await _pumpRing(tester, isSpinning: false);
    await tester.pump();

    // Ring should still render without spinning
    expect(find.byType(CircularProgressRing), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
  });
}
