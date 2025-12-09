import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('confirm field and CTA remain visible with keyboard inset', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    const keyboardInset = 320.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: keyboardInset),
          ),
          child: const CreateNewPasswordScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final confirmField = find.byType(TextField).last;
    await tester.tap(confirmField);
    await tester.pumpAndSettle();

    final fieldRect = tester.getRect(confirmField);
    // Find the CTA button by key instead of hardcoded text
    final buttonRect = tester.getRect(
      find.byKey(const ValueKey('create_new_cta_button')),
    );

    final visibleBottom =
        (view.physicalSize.height / view.devicePixelRatio) - keyboardInset;

    expect(buttonRect.top, greaterThanOrEqualTo(fieldRect.bottom));
    expect(fieldRect.bottom <= visibleBottom, isTrue);
    expect(buttonRect.bottom <= visibleBottom, isTrue);
  });
}
