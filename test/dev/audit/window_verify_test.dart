import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

class FakeViewPadding implements ViewPadding {
  const FakeViewPadding({
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
  });

  @override
  final double left;
  @override
  final double top;
  @override
  final double right;
  @override
  final double bottom;
}

void main() {
  group('Window Verify Test', () {
    late Widget testWidget;

    setUp(() {
      testWidget = MaterialApp(
        theme: AppTheme.buildAppTheme(),
        home: const CreateNewPasswordScreen(),
      );
    });

    Future<Map<String, dynamic>> windowMeasure(
      WidgetTester tester, {
      required double keyboardHeight,
      int? focusFieldIndex,
    }) async {
      // iPhone 390x844
      await tester.binding.setSurfaceSize(const Size(390, 844));

      final testWindow = tester.binding.window;
      testWindow.viewInsetsTestValue = FakeViewPadding(bottom: keyboardHeight);
      testWindow.paddingTestValue = const FakeViewPadding(
        top: 47, // iPhone SafeTop
        bottom: 34, // iPhone SafeBottom
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Focus field if specified
      if (focusFieldIndex != null) {
        final passwordFieldKey = focusFieldIndex == 0
            ? 'AuthPasswordField'
            : 'AuthConfirmPasswordField';
        final fieldFinder = find.byKey(Key(passwordFieldKey));
        if (fieldFinder.evaluate().isNotEmpty) {
          await tester.tap(fieldFinder);
          await tester.pumpAndSettle();
        }
      }

      // Find widgets
      final backButtonFinder = find.byType(BackButtonCircle);
      final headerFinder = find.text('Mach es stark.');
      final confirmFieldFinder = find.text('Neues Passwort bestätigen').first;
      final ctaFinder = find.byType(ElevatedButton);

      // Get positions
      final backButtonRect = tester.getRect(backButtonFinder);
      final headerRect = tester.getRect(headerFinder);
      final confirmRect = tester.getRect(confirmFieldFinder);
      final ctaRect = tester.getRect(ctaFinder);

      final gap = ctaRect.top - confirmRect.bottom;

      return {
        'backY': backButtonRect.top,
        'headerTop': headerRect.top,
        'gap': gap,
        'ctaTop': ctaRect.top,
        'ctaBottom': ctaRect.bottom,
      };
    }

    testWidgets('Window Contract', (tester) async {
      print('WINDOW_VERIFY:');
      print('- BackButton: Positioned(top: safeTop + 12)');
      print('- Header: Column with key, in scroll flow');
      print('- CTA: SizedBox with key for window snap');
      print('- Fields: snapIntoViewWindow with header/CTA boundaries');
    });

    testWidgets('K300/F1 - Window snap field 1', (tester) async {
      final m = await windowMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 0,
      );
      print(
        '- K300/F1: backY=${m['backY']?.toStringAsFixed(0)}, headerTop=${m['headerTop']?.toStringAsFixed(0)}, gap=${m['gap']?.toStringAsFixed(0)}',
      );
    });

    testWidgets('K300/F2 - Window snap field 2', (tester) async {
      final m = await windowMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 1,
      );
      print(
        '- K300/F2: backY=${m['backY']?.toStringAsFixed(0)}, headerTop=${m['headerTop']?.toStringAsFixed(0)}, gap=${m['gap']?.toStringAsFixed(0)}',
      );

      final backY = m['backY'] as double;
      final headerTop = m['headerTop'] as double;
      final gap = m['gap'] as double;

      final backButtonResult = backY >= 59
          ? 'PINNED'
          : 'FLOATING'; // safeTop(47) + inset(12)
      final headerResult = headerTop >= 47 ? 'VISIBLE' : 'HIDDEN';
      final gapResult = gap >= 24 ? 'SAFE' : 'OVERLAP';

      print('');
      print('WINDOW RESULTS:');
      print(
        '- BackButton pinning: $backButtonResult (Y=${backY.toStringAsFixed(0)})',
      );
      print(
        '- Header visibility: $headerResult (Y=${headerTop.toStringAsFixed(0)})',
      );
      print('- Gap safety: $gapResult (${gap.toStringAsFixed(0)}px)');

      final allOk = backY >= 59 && headerTop >= 47 && gap >= 24;
      print('- Overall: ${allOk ? "✅ SUCCESS" : "❌ NEEDS_TUNING"}');
    });
  });
}
