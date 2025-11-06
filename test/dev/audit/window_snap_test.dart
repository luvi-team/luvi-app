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
  group('Window Snap Test', () {
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

    Future<Map<String, dynamic>> snapMeasure(
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
      final headerFinder = find.byKey(const ValueKey('create_new_title'));
      final passwordFieldFinder = find.byKey(const ValueKey('AuthPasswordField'));
      final confirmFieldFinder = find.byKey(
        const ValueKey('AuthConfirmPasswordField'),
      );
      final ctaFinder = find.byKey(const ValueKey('create_new_cta_button'));

      // Get positions
      final headerRect = tester.getRect(headerFinder);
      final passwordRect = tester.getRect(passwordFieldFinder);
      final confirmRect = tester.getRect(confirmFieldFinder);
      final ctaRect = tester.getRect(ctaFinder);

      final headerBottomY = headerRect.bottom;
      final ctaTopY = ctaRect.top;
      final windowTop = headerBottomY + 16; // Spacing.m
      final windowBottom = ctaTopY - 24; // Spacing.l

      return {
        'headerBottom': headerBottomY,
        'ctaTop': ctaTopY,
        'windowTop': windowTop,
        'windowBottom': windowBottom,
        'passwordTop': passwordRect.top,
        'passwordBottom': passwordRect.bottom,
        'confirmTop': confirmRect.top,
        'confirmBottom': confirmRect.bottom,
        'gap': ctaRect.top - confirmRect.bottom,
      };
    }

    testWidgets('Acceptance Criteria Test', (tester) async {
      print('WINDOW SNAP ACCEPTANCE TEST:');
      print(
        '- Target: fieldTop >= headerBottom + 16 && fieldBottom <= ctaTop - 24',
      );
      print('- Gap: CTATop - ConfirmBottom >= 16px');
      print(
        '- BackButton/Header: always visible (BackButton pinned via Positioned)',
      );
      print(
        '- Contract: includeBottomReserve:false, resizeToAvoidBottomInset:false',
      );
    });

    testWidgets('K300/F1 - Password field focused', (tester) async {
      final m = await snapMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 0,
      );

      final passwordInWindow =
          m['passwordTop'] >= m['windowTop'] &&
          m['passwordBottom'] <= m['windowBottom'];
      final gap = m['gap'] as double;

      print(
        '- K300/F1: passwordTop=${m['passwordTop']?.toStringAsFixed(0)}, windowTop=${m['windowTop']?.toStringAsFixed(0)}, windowBottom=${m['windowBottom']?.toStringAsFixed(0)}, gap=${gap.toStringAsFixed(0)}',
      );
      print('  Password in window: ${passwordInWindow ? "✅ YES" : "❌ NO"}');
    });

    testWidgets('K300/F2 - Confirm field focused', (tester) async {
      final m = await snapMeasure(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 1,
      );

      final confirmInWindow =
          m['confirmTop'] >= m['windowTop'] &&
          m['confirmBottom'] <= m['windowBottom'];
      final gap = m['gap'] as double;
      final gapOk = gap >= 16;

      print(
        '- K300/F2: confirmTop=${m['confirmTop']?.toStringAsFixed(0)}, windowTop=${m['windowTop']?.toStringAsFixed(0)}, windowBottom=${m['windowBottom']?.toStringAsFixed(0)}, gap=${gap.toStringAsFixed(0)}',
      );
      print('  Confirm in window: ${confirmInWindow ? "✅ YES" : "❌ NO"}');
      print('  Gap >= 16px: ${gapOk ? "✅ YES" : "❌ NO"}');

      print('');
      print('FINAL RESULT:');
      print(
        '- Window snap functioning: ${confirmInWindow ? "✅ SUCCESS" : "❌ NEEDS_FIX"}',
      );
      print('- No CTA overlap: ${gapOk ? "✅ SUCCESS" : "❌ NEEDS_FIX"}');
    });
  });
}
