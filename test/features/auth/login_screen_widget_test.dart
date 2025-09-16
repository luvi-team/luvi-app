import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/data/auth_repository.dart';
import 'package:luvi_app/features/state/auth_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    // Register fallback values if needed in the future
  });

  testWidgets('Login shows error on invalid credentials', (tester) async {
    // Make the test device large enough to avoid overflow/scrolling issues
    final view = tester.view;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final mockRepo = _MockAuthRepository();
    when(() => mockRepo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(AuthException('invalid credentials'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const LoginScreen(),
        ),
      ),
    );

    // Enter email and password
    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    await tester.enterText(emailField, 'user@example.com');
    await tester.enterText(passwordField, 'wrongpw');

    // Tap the CTA button
    final loginButton = find.widgetWithText(ElevatedButton, 'Anmelden');
    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Expect error message from invalid credentials handling
    expect(find.text('E-Mail oder Passwort ist falsch.'), findsOneWidget);

    // Button should remain enabled (loading reset)
    final btn = tester.widget<ElevatedButton>(loginButton);
    expect(btn.onPressed, isNotNull);
  });
}
