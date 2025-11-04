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
  group('CreateNewPasswordScreen Layout Probe', () {
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

    Future<Map<String, dynamic>> measureLayout(
      WidgetTester tester, {
      required double keyboardHeight,
      int? focusFieldIndex,
    }) async {
      // Set device size to iPhone 390x844
      await tester.binding.setSurfaceSize(const Size(390, 844));

      // Set keyboard insets using proper TestWindow API
      final testWindow = tester.binding.window;
      testWindow.viewInsetsTestValue = FakeViewPadding(bottom: keyboardHeight);
      testWindow.paddingTestValue = const FakeViewPadding(
        top: 47, // Figma SafeTop
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

      // Measure MediaQuery values
      final mediaQuery = MediaQuery.of(
        tester.element(find.byType(CreateNewPasswordScreen)),
      );

      // Find key widgets and their positions
      final backButtonFinder = find.byKey(const ValueKey('backButtonCircle'));
      final titleFinder = find.byKey(const ValueKey('create_new_title'));
      final subtitleFinder = find.byKey(const ValueKey('create_new_subtitle'));
      final ctaFinder = find.byKey(const ValueKey('create_new_cta_button'));

      // Get Y positions
      final backButtonRect = tester.getRect(backButtonFinder);
      final titleRect = tester.getRect(titleFinder);
      final subtitleRect = tester.getRect(subtitleFinder);
      final ctaRect = tester.getRect(ctaFinder);

      // Try to find password fields by their hint text
      final field1Finder = find.byKey(const ValueKey('AuthPasswordField'));
      final field2Finder = find.byKey(const ValueKey('AuthConfirmPasswordField'));

      final field1Rect = tester.getRect(field1Finder);
      final field2Rect = tester.getRect(field2Finder);

      // Calculate gaps
      final headerBottomY = subtitleRect.bottom;
      final gapHeaderToField1 = field1Rect.top - headerBottomY;
      final gapField1ToField2 = field2Rect.top - field1Rect.bottom;
      final gapField2ToCta = ctaRect.top - field2Rect.bottom;
      final whiteSpaceAboveCta = ctaRect.top < mediaQuery.size.height
          ? mediaQuery.size.height - ctaRect.bottom
          : 0.0;

      return {
        'mediaQuery': {
          'safeTop': mediaQuery.padding.top,
          'safeBottom': mediaQuery.padding.bottom,
          'viewInsetsBottom': mediaQuery.viewInsets.bottom,
          'viewHeight': mediaQuery.size.height,
        },
        'positions': {
          'backButtonTop': backButtonRect.top,
          'backButtonBottom': backButtonRect.bottom,
          'titleTop': titleRect.top,
          'titleBottom': titleRect.bottom,
          'subtitleTop': subtitleRect.top,
          'subtitleBottom': subtitleRect.bottom,
          'field1Top': field1Rect.top,
          'field1Bottom': field1Rect.bottom,
          'field2Top': field2Rect.top,
          'field2Bottom': field2Rect.bottom,
          'ctaTop': ctaRect.top,
          'ctaBottom': ctaRect.bottom,
        },
        'gaps': {
          'headerBottomY': headerBottomY,
          'headerToField1': gapHeaderToField1,
          'field1ToField2': gapField1ToField2,
          'field2ToCta': gapField2ToCta,
          'whiteSpaceAboveCta': whiteSpaceAboveCta,
        },
        'visibility': {
          'backButtonVisible': backButtonRect.top >= mediaQuery.padding.top,
          'headerVisible': titleRect.top >= mediaQuery.padding.top,
        },
        'overlaps': {
          'ctaOverlapsField2': ctaRect.top < field2Rect.bottom,
          'gapField2ToCta': gapField2ToCta,
        },
      };
    }

    testWidgets('K0 - Keyboard closed baseline', (tester) async {
      final measurements = await measureLayout(tester, keyboardHeight: 0);

      print('=== K0 (Keyboard aus) ===');
      print('MediaQuery:');
      print('  safeTop: ${measurements['mediaQuery']['safeTop']}');
      print('  safeBottom: ${measurements['mediaQuery']['safeBottom']}');
      print(
        '  viewInsetsBottom: ${measurements['mediaQuery']['viewInsetsBottom']}',
      );
      print('  viewHeight: ${measurements['mediaQuery']['viewHeight']}');

      print('Y-Positionen:');
      final pos = measurements['positions'];
      print(
        '  BackButton: ${pos['backButtonTop']} - ${pos['backButtonBottom']}',
      );
      print('  Title: ${pos['titleTop']} - ${pos['titleBottom']}');
      print('  Subtitle: ${pos['subtitleTop']} - ${pos['subtitleBottom']}');
      print('  Field1: ${pos['field1Top']} - ${pos['field1Bottom']}');
      print('  Field2: ${pos['field2Top']} - ${pos['field2Bottom']}');
      print('  CTA: ${pos['ctaTop']} - ${pos['ctaBottom']}');

      print('Gaps:');
      final gaps = measurements['gaps'];
      print('  HeaderBottomY: ${gaps['headerBottomY']}');
      print('  Header→Field1: ${gaps['headerToField1']}');
      print('  Field1→Field2: ${gaps['field1ToField2']}');
      print('  Field2→CTA: ${gaps['field2ToCta']}');
      print('  White-Space über CTA: ${gaps['whiteSpaceAboveCta']}');

      print('Sichtbarkeit:');
      final vis = measurements['visibility'];
      print('  BackButton sichtbar: ${vis['backButtonVisible']}');
      print('  Header sichtbar: ${vis['headerVisible']}');

      print('');
    });

    testWidgets('K180 - Keyboard 180px, Focus Field 1', (tester) async {
      final measurements = await measureLayout(
        tester,
        keyboardHeight: 180,
        focusFieldIndex: 0,
      );

      print('=== K180 (Keyboard=180px, Fokus Feld 1) ===');
      print('MediaQuery:');
      print('  safeTop: ${measurements['mediaQuery']['safeTop']}');
      print('  safeBottom: ${measurements['mediaQuery']['safeBottom']}');
      print(
        '  viewInsetsBottom: ${measurements['mediaQuery']['viewInsetsBottom']}',
      );
      print('  viewHeight: ${measurements['mediaQuery']['viewHeight']}');

      print('Y-Positionen:');
      final pos = measurements['positions'];
      print(
        '  BackButton: ${pos['backButtonTop']} - ${pos['backButtonBottom']}',
      );
      print('  Title: ${pos['titleTop']} - ${pos['titleBottom']}');
      print('  Subtitle: ${pos['subtitleTop']} - ${pos['subtitleBottom']}');
      print('  Field1: ${pos['field1Top']} - ${pos['field1Bottom']}');
      print('  Field2: ${pos['field2Top']} - ${pos['field2Bottom']}');
      print('  CTA: ${pos['ctaTop']} - ${pos['ctaBottom']}');

      print('Gaps:');
      final gaps = measurements['gaps'];
      print('  HeaderBottomY: ${gaps['headerBottomY']}');
      print('  Header→Field1: ${gaps['headerToField1']}');
      print('  Field1→Field2: ${gaps['field1ToField2']}');
      print('  Field2→CTA: ${gaps['field2ToCta']}');
      print('  White-Space über CTA: ${gaps['whiteSpaceAboveCta']}');

      print('Sichtbarkeit:');
      final vis = measurements['visibility'];
      print('  BackButton sichtbar: ${vis['backButtonVisible']}');
      print('  Header sichtbar: ${vis['headerVisible']}');

      final overlaps = measurements['overlaps'];
      print('Overlaps:');
      print('  CTA überlappt Field2: ${overlaps['ctaOverlapsField2']}');
      print('  Gap Field2→CTA: ${overlaps['gapField2ToCta']}px');

      // Ampel-Bewertung
      final gapColor = overlaps['gapField2ToCta'] >= 24
          ? 'GRÜN'
          : overlaps['gapField2ToCta'] >= 16
          ? 'GELB'
          : 'ROT';
      final whiteSpaceColor = gaps['whiteSpaceAboveCta'] <= 40
          ? 'GRÜN'
          : gaps['whiteSpaceAboveCta'] <= 80
          ? 'GELB'
          : 'ROT';
      print('AMPEL:');
      print('  Gap: $gapColor (${overlaps['gapField2ToCta']}px)');
      print(
        '  White-Space: $whiteSpaceColor (${gaps['whiteSpaceAboveCta']}px)',
      );
      print('  Header sichtbar: ${vis['headerVisible'] ? 'GRÜN' : 'ROT'}');
      print('');
    });

    testWidgets('K180 - Keyboard 180px, Focus Field 2', (tester) async {
      final measurements = await measureLayout(
        tester,
        keyboardHeight: 180,
        focusFieldIndex: 1,
      );

      print('=== K180 (Keyboard=180px, Fokus Feld 2) ===');
      print('Y-Positionen:');
      final pos = measurements['positions'];
      print(
        '  BackButton: ${pos['backButtonTop']} - ${pos['backButtonBottom']}',
      );
      print('  Title: ${pos['titleTop']} - ${pos['titleBottom']}');
      print('  Subtitle: ${pos['subtitleTop']} - ${pos['subtitleBottom']}');
      print('  Field1: ${pos['field1Top']} - ${pos['field1Bottom']}');
      print('  Field2: ${pos['field2Top']} - ${pos['field2Bottom']}');
      print('  CTA: ${pos['ctaTop']} - ${pos['ctaBottom']}');

      print('Gaps:');
      final gaps = measurements['gaps'];
      print('  Field2→CTA: ${gaps['field2ToCta']}');
      print('  White-Space über CTA: ${gaps['whiteSpaceAboveCta']}');

      final overlaps = measurements['overlaps'];
      final gapColor = overlaps['gapField2ToCta'] >= 24
          ? 'GRÜN'
          : overlaps['gapField2ToCta'] >= 16
          ? 'GELB'
          : 'ROT';
      print('AMPEL Gap: $gapColor (${overlaps['gapField2ToCta']}px)');
      print('');
    });

    testWidgets('K300 - Keyboard 300px, Focus Field 1', (tester) async {
      final measurements = await measureLayout(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 0,
      );

      print('=== K300 (Keyboard=300px, Fokus Feld 1) ===');
      final gaps = measurements['gaps'];
      final overlaps = measurements['overlaps'];
      final vis = measurements['visibility'];

      print('Field2→CTA: ${gaps['field2ToCta']}px');
      print('White-Space über CTA: ${gaps['whiteSpaceAboveCta']}px');
      print('Header sichtbar: ${vis['headerVisible']}');

      final gapColor = overlaps['gapField2ToCta'] >= 24
          ? 'GRÜN'
          : overlaps['gapField2ToCta'] >= 16
          ? 'GELB'
          : 'ROT';
      final whiteSpaceColor = gaps['whiteSpaceAboveCta'] <= 40
          ? 'GRÜN'
          : gaps['whiteSpaceAboveCta'] <= 80
          ? 'GELB'
          : 'ROT';
      print('AMPEL:');
      print('  Gap: $gapColor (${overlaps['gapField2ToCta']}px)');
      print(
        '  White-Space: $whiteSpaceColor (${gaps['whiteSpaceAboveCta']}px)',
      );
      print('  Header sichtbar: ${vis['headerVisible'] ? 'GRÜN' : 'ROT'}');
      print('');
    });

    testWidgets('K300 - Keyboard 300px, Focus Field 2', (tester) async {
      final measurements = await measureLayout(
        tester,
        keyboardHeight: 300,
        focusFieldIndex: 1,
      );

      print('=== K300 (Keyboard=300px, Fokus Feld 2) ===');
      final gaps = measurements['gaps'];
      final overlaps = measurements['overlaps'];
      final vis = measurements['visibility'];

      print('Field2→CTA: ${gaps['field2ToCta']}px');
      print('Header sichtbar: ${vis['headerVisible']}');

      final gapColor = overlaps['gapField2ToCta'] >= 24
          ? 'GRÜN'
          : overlaps['gapField2ToCta'] >= 16
          ? 'GELB'
          : 'ROT';
      print('AMPEL Gap: $gapColor (${overlaps['gapField2ToCta']}px)');
      print('');
    });
  });
}
