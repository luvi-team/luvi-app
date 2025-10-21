import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';

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
  group('Mini Owner Probe', () {
    late Widget testWidget;

    setUp(() {
      testWidget = MaterialApp(
        theme: AppTheme.buildAppTheme(),
        home: const CreateNewPasswordScreen(),
      );
    });

    Future<Map<String, dynamic>> quickMeasure(
      WidgetTester tester, {
      required double keyboardHeight,
      int? focusFieldIndex,
    }) async {
      // iPhone 390x844, realistic keyboard
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
        final passwordFields = find.byType(Focus);
        if (focusFieldIndex < passwordFields.evaluate().length) {
          await tester.tap(passwordFields.at(focusFieldIndex));
          await tester.pumpAndSettle();
        }
      }

      // Find widgets by specific finders
      final backButtonFinder = find.byKey(
        const ValueKey('backButtonCircle'),
      );
      final subtitleFinder = find.text('Mach es stark.');
      final passwordFieldFinder = find.text('Neues Passwort').first;
      final confirmFieldFinder = find.text('Neues Passwort bestätigen').first;
      final ctaFinder = find.byType(ElevatedButton);

      // Get positions
      final backButtonRect = tester.getRect(backButtonFinder);
      final subtitleRect = tester.getRect(subtitleFinder);
      final passwordRect = tester.getRect(passwordFieldFinder);
      final confirmRect = tester.getRect(confirmFieldFinder);
      final ctaRect = tester.getRect(ctaFinder);

      return {
        'backButtonY': backButtonRect.top,
        'headerTop': subtitleRect.top,
        'headerBottom': subtitleRect.bottom,
        'passwordTop': passwordRect.top,
        'confirmTop': confirmRect.top,
        'confirmBottom': confirmRect.bottom,
        'ctaTop': ctaRect.top,
        'ctaBottom': ctaRect.bottom,
        'gap': ctaRect.top - confirmRect.bottom,
      };
    }

    testWidgets('K0 - Baseline', (tester) async {
      final m = await quickMeasure(tester, keyboardHeight: 0);
      print(
        '- K0:   gap=${m['gap']?.toStringAsFixed(0)}, backButtonY=${m['backButtonY']?.toStringAsFixed(0)}, headerTop=${m['headerTop']?.toStringAsFixed(0)}',
      );
    });

    testWidgets('K300/F1 - Keyboard + Field 1', (tester) async {
      final m = await quickMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 0,
      );
      print(
        '- K300/F1: gap=${m['gap']?.toStringAsFixed(0)}, backButtonY=${m['backButtonY']?.toStringAsFixed(0)}, headerTop=${m['headerTop']?.toStringAsFixed(0)}',
      );
    });

    testWidgets('K300/F2 - Keyboard + Field 2', (tester) async {
      final m = await quickMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 1,
      );
      print(
        '- K300/F2: gap=${m['gap']?.toStringAsFixed(0)}, backButtonY=${m['backButtonY']?.toStringAsFixed(0)}, headerTop=${m['headerTop']?.toStringAsFixed(0)}',
      );

      // Ampel evaluation
      final gap = m['gap'] as double;
      final backButtonY = m['backButtonY'] as double;
      final headerTop = m['headerTop'] as double;

      final gapColor = gap >= 24
          ? 'green'
          : gap >= 16
          ? 'yellow'
          : 'red';
      const safeTop = 47;
      const backInset = 12;
      final visibilityColor = (backButtonY >= (safeTop + backInset) && headerTop >= safeTop)
          ? 'green'
          : 'red';
      print('');
      print('SUMMARY:');
      print(
        '- BottomOwner: double-reserve',
      ); // includeBottomReserve=true + Footer SafeArea
      print('- Gap(K300/F1,F2): $gapColor (${gap.toStringAsFixed(0)}px)');
      print('- Header/Back visibility(K300): $visibilityColor');
    });
  });
}
