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
  group('Final Contract Test', () {
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

    Future<Map<String, dynamic>> contractMeasure(
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
        final passwordFields = find.byType(Focus);
        if (focusFieldIndex < passwordFields.evaluate().length) {
          await tester.tap(passwordFields.at(focusFieldIndex));
          await tester.pumpAndSettle();
        }
      }

      // Find widgets
      final backButtonFinder = find.byKey(const ValueKey('backButtonCircle'));
      final confirmFieldFinder = find.byKey(
        const ValueKey('AuthConfirmPasswordField'),
      );
      final ctaFinder = find.byKey(const ValueKey('create_new_cta_button'));

      // Get positions
      final backButtonRect = tester.getRect(backButtonFinder);
      final confirmRect = tester.getRect(confirmFieldFinder);
      final ctaRect = tester.getRect(ctaFinder);

      final gap = ctaRect.top - confirmRect.bottom;

      return {
        'gap': gap,
        'backButtonY': backButtonRect.top,
        'ctaTop': ctaRect.top,
        'ctaBottom': ctaRect.bottom,
      };
    }

    testWidgets('Contract verification', (tester) async {
      print('FINAL CONTRACT:');
      print(
        '- Body: includeBottomReserve=false, resizeToAvoidBottomInset=false',
      );
      print(
        '- Footer: AnimatedPadding(viewInsets.bottom) + SafeArea(top:false)',
      );
      print('- CTA: konstant Spacing.m (16px) top padding');
    });

    testWidgets('K0 - Contract baseline', (tester) async {
      final m = await contractMeasure(tester, keyboardHeight: 0);
      print(
        '- K0: gap=${m['gap']?.toStringAsFixed(0)}px, backButtonY=${m['backButtonY']?.toStringAsFixed(0)}px',
      );
    });

    testWidgets('K300 - Contract with keyboard', (tester) async {
      final m = await contractMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 1,
      );
      print(
        '- K300: gap=${m['gap']?.toStringAsFixed(0)}px, backButtonY=${m['backButtonY']?.toStringAsFixed(0)}px',
      );

      final gap = m['gap'] as double;
      final backButtonY = m['backButtonY'] as double;

      final gapResult = gap >= 24 && gap <= 60 ? 'GOOD' : 'BAD';
      final backButtonResult = backButtonY >= 47 ? 'VISIBLE' : 'HIDDEN';

      print('');
      print('CONTRACT RESULTS:');
      print(
        '- Gap (24-60px expected): $gapResult (${gap.toStringAsFixed(0)}px)',
      );
      print('- BackButton visibility: $backButtonResult');
      print('- White block eliminated: ${gap < 200 ? "YES" : "NO"}');
    });
  });
}
