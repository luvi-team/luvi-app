import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

void main() {
  testWidgets('LoginScreen shows headline and button', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Willkommen zurück 💜'), findsOneWidget);
    expect(find.text('Anmelden'), findsOneWidget);
  });

  testWidgets('CTA is always enabled and validates on press', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const LoginScreen(),
        ),
      ),
    );

    final button = find.widgetWithText(ElevatedButton, 'Anmelden');

    // Always enabled
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);

    await tester.tap(button);
    await tester.pump();

    expect(find.text('Ups, bitte E-Mail überprüfen'), findsOneWidget);
    expect(find.text('Ups, bitte Passwort überprüfen'), findsOneWidget);
  });
}
