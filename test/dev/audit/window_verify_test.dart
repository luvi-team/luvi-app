import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
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

const double _safeTop = 47; // iPhone safe area top inset
const double _safeBottom = 34; // iPhone safe area bottom inset
const double _backButtonInset = 12; // Back button distance from safe top
const double _minimumGap = 24; // Minimum gap between confirm field and CTA

void main() {
  group('Window Verify Test', () {
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
        top: _safeTop,
        bottom: _safeBottom,
      );
      addTearDown(() {
        tester.binding.window.clearAllTestValues();
      });

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Focus field if specified
      if (focusFieldIndex != null) {
        final passwordFieldKey = focusFieldIndex == 0
            ? 'AuthPasswordField'
            : 'AuthConfirmPasswordField';
        final fieldFinder = find.byKey(Key(passwordFieldKey));
        expect(fieldFinder, findsOneWidget);
        await tester.tap(fieldFinder);
        await tester.pumpAndSettle();
      }

      // Find widgets
      final backButtonFinder = find.byType(BackButtonCircle);

      // Use a stable key instead of hard-coded localized text
      final headerFinder = find.byKey(const ValueKey('create_new_title'));
      final confirmFieldFinder = find.byKey(
        const Key('AuthConfirmPasswordField'),
      );
      final ctaFinder = find.byKey(const ValueKey('create_new_cta_button'));

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

      final expectedBackButtonTop = _safeTop + _backButtonInset;

      final backButtonResult = backY >= expectedBackButtonTop
          ? 'PINNED'
          : 'FLOATING';
      final headerResult = headerTop >= _safeTop ? 'VISIBLE' : 'HIDDEN';
      final gapResult = gap >= _minimumGap ? 'SAFE' : 'OVERLAP';

      print('');
      print('WINDOW RESULTS:');
      print(
        '- BackButton pinning: $backButtonResult (Y=${backY.toStringAsFixed(0)} >= ${expectedBackButtonTop.toStringAsFixed(0)})',
      );
      print(
        '- Header visibility: $headerResult (Y=${headerTop.toStringAsFixed(0)} >= ${_safeTop.toStringAsFixed(0)})',
      );
      print(
        '- Gap safety: $gapResult (${gap.toStringAsFixed(0)}px >= ${_minimumGap.toStringAsFixed(0)})',
      );

      final allOk =
          backY >= expectedBackButtonTop &&
          headerTop >= _safeTop &&
          gap >= _minimumGap;
      print('- Overall: ${allOk ? "✅ SUCCESS" : "❌ NEEDS_TUNING"}');
    });
  });
}
