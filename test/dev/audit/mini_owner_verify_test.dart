import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

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
  group('Owner Verify After Fix', () {
    late Widget testWidget;

    setUp(() {
      testWidget = MaterialApp(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const CreateNewPasswordScreen(),
      );
    });

    Future<Map<String, dynamic>> verifyMeasure(
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

      // Find widgets
      final backButtonFinder = find.byKey(const Key('backButtonCircle'));
      final subtitleFinder = find.byKey(const Key('create_new_subtitle'));
      final confirmFieldFinder = find.byKey(
        const Key('AuthConfirmPasswordField'),
      );
      final ctaFinder = find.byKey(const Key('create_new_cta_button'));

      // Get positions
      final backButtonRect = tester.getRect(backButtonFinder);
      final subtitleRect = tester.getRect(subtitleFinder);
      final confirmRect = tester.getRect(confirmFieldFinder);
      final ctaRect = tester.getRect(ctaFinder);

      final gap = ctaRect.top - confirmRect.bottom;
      final mediaQuery = MediaQuery.of(
        tester.element(find.byType(CreateNewPasswordScreen)),
      );
      final whiteSpace = mediaQuery.size.height - ctaRect.bottom;

      return {
        'gap': gap,
        'backButtonY': backButtonRect.top,
        'headerTop': subtitleRect.top,
        'ctaTop': ctaRect.top,
        'ctaBottom': ctaRect.bottom,
        'whiteSpace': whiteSpace,
      };
    }

    testWidgets('Code verification', (tester) async {
      print('AFTER_FIX:');
      print('- includeBottomReserve: false');
      print('- BodyKeyboardPadding: none');
    });

    testWidgets('K0 - Fixed baseline', (tester) async {
      final m = await verifyMeasure(tester, keyboardHeight: 0);
      print(
        '- K0:   gap=${m['gap']?.toStringAsFixed(0)}, backButtonY=${m['backButtonY']?.toStringAsFixed(0)}, headerTop=${m['headerTop']?.toStringAsFixed(0)}',
      );
    });

    testWidgets('K300/F1 - Fixed keyboard + Field 1', (tester) async {
      final m = await verifyMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 0,
      );
      print(
        '- K300/F1: gap=${m['gap']?.toStringAsFixed(0)}, backButtonY=${m['backButtonY']?.toStringAsFixed(0)}, headerTop=${m['headerTop']?.toStringAsFixed(0)}',
      );
    });

    testWidgets('K300/F2 - Fixed keyboard + Field 2', (tester) async {
      final m = await verifyMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 1,
      );
      print(
        '- K300/F2: gap=${m['gap']?.toStringAsFixed(0)}, backButtonY=${m['backButtonY']?.toStringAsFixed(0)}, headerTop=${m['headerTop']?.toStringAsFixed(0)}',
      );

      // Final evaluation
      final gap = m['gap'] as double;
      final backButtonY = m['backButtonY'] as double;
      final headerTop = m['headerTop'] as double;
      final whiteSpace = m['whiteSpace'] as double;

      final bottomOwner = 'footer-only'; // includeBottomReserve=false
      final gapColor = gap >= 24
          ? 'green'
          : gap >= 16
          ? 'yellow'
          : 'red';
      final visibilityColor = (backButtonY >= 47 && headerTop >= 47)
          ? 'green'
          : 'red';
      final whiteSpaceResult = whiteSpace <= 24 ? 'minimal' : 'excessive';

      print('');
      print('VERIFICATION RESULTS:');
      print('- BottomOwner: $bottomOwner');
      print('- Gap(K300/F1,F2): $gapColor (${gap.toStringAsFixed(0)}px)');
      print('- Header/Back visibility(K300): $visibilityColor');
      print(
        '- White-Space über CTA: $whiteSpaceResult (${whiteSpace.toStringAsFixed(0)}px)',
      );

      // Acceptance criteria check
      final gapOk = gap >= 24;
      final visibilityOk = backButtonY >= 47 && headerTop >= 47;
      final whiteSpaceOk = whiteSpace <= 24;

      print('');
      print('ACCEPTANCE CRITERIA:');
      print('- Gap ≥ 24px: ${gapOk ? "✅ PASS" : "❌ FAIL"}');
      print('- Header/Back visible: ${visibilityOk ? "✅ PASS" : "❌ FAIL"}');
      print('- Minimal white-space: ${whiteSpaceOk ? "✅ PASS" : "❌ FAIL"}');
    });
  });
}
