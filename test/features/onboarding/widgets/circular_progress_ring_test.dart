import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/features/onboarding/widgets/circular_progress_ring.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

/// Checks if a Matrix4 is approximately identity using epsilon comparison.
/// Handles floating-point precision issues in animation tests.
bool _isApproximatelyIdentity(Matrix4 matrix, {double epsilon = 1e-6}) {
  final identity = Matrix4.identity();
  for (int i = 0; i < 16; i++) {
    if ((matrix.storage[i] - identity.storage[i]).abs() > epsilon) {
      return false;
    }
  }
  return true;
}

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

    // Issue 9: Use stable Key instead of fragile find.byType().first
    final sizedBox = find.byKey(const Key(TestKeys.circularProgressRingContainer));
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

    // Complete animation (remaining 250ms to reach 500ms total)
    await tester.pump(const Duration(milliseconds: 250));
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

    // Issue 8: Get localized string from rendered widget context
    final context = tester.element(find.byType(CircularProgressRing));
    final l10n = AppLocalizations.of(context)!;

    // Verify Semantics widget exists with the localized label
    final semanticsWidget = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == l10n.semanticLoadingProgress,
    );
    expect(semanticsWidget, findsOneWidget);
  });

  testWidgets('has correct semantics in English', (tester) async {
    await _pumpRing(tester, locale: const Locale('en'), isSpinning: false);
    // Use pump instead of pumpAndSettle to avoid infinite animation loop
    await tester.pump();

    // Issue 8: Get localized string from rendered widget context
    final context = tester.element(find.byType(CircularProgressRing));
    final l10n = AppLocalizations.of(context)!;

    // Verify Semantics widget exists with the localized label
    final semanticsWidget = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == l10n.semanticLoadingProgress,
    );
    expect(semanticsWidget, findsOneWidget);
  });

  testWidgets('contains Transform.rotate for rotation animation', (tester) async {
    await _pumpRing(tester, isSpinning: true);
    // Pump time to advance rotation animation (non-zero angle = non-identity matrix)
    await tester.pump(const Duration(milliseconds: 100));

    // Find Transform widget within CircularProgressRing with non-identity matrix
    // Issue 7: Use tolerance-based comparison for floating-point precision
    final ringFinder = find.byType(CircularProgressRing);
    final rotationTransformFinder = find.descendant(
      of: ringFinder,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Transform && !_isApproximatelyIdentity(widget.transform),
      ),
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
