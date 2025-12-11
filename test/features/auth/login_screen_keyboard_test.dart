import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../support/test_config.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Auth-Flow Bugfix Tests: Verify keyboard behavior on Auth screens.
///
/// These tests verify that:
/// 1. Email fields do NOT autofocus (keyboard doesn't open automatically)
/// 2. Users must explicitly tap the field to open the keyboard
void main() {
  TestConfig.ensureInitialized();
  late _MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = _MockAuthRepository();
    when(
      () => mockRepo.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(AuthException('invalid credentials'));
  });

  group('Keyboard autofocus behavior', () {
    testWidgets('LoginScreen email field does NOT autofocus', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(
            theme: AppTheme.buildAppTheme(),
            home: const LoginScreen(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );

      // LoginEmailField is a wrapper widget (Column > Container > TextField)
      // → find.descendant is needed to find the inner TextField
      final emailFieldWrapper = find.byKey(const ValueKey('login_email_field'));
      expect(emailFieldWrapper, findsOneWidget);

      final textField = tester.widget<TextField>(
        find.descendant(of: emailFieldWrapper, matching: find.byType(TextField)),
      );

      // Auth-Flow Bugfix: Verify autofocus is false
      expect(
        textField.autofocus,
        isFalse,
        reason: 'Email field should NOT autofocus to prevent keyboard auto-opening',
      );
    });

    testWidgets('AuthSignupScreen email field does NOT autofocus', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(
            theme: AppTheme.buildAppTheme(),
            home: const AuthSignupScreen(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );

      // SignupScreen email field
      final emailFieldWrapper = find.byKey(const ValueKey('signup_email_field'));
      expect(emailFieldWrapper, findsOneWidget);

      final textField = tester.widget<TextField>(
        find.descendant(of: emailFieldWrapper, matching: find.byType(TextField)),
      );

      // Auth-Flow Bugfix: Verify autofocus is false
      expect(
        textField.autofocus,
        isFalse,
        reason: 'Email field should NOT autofocus to prevent keyboard auto-opening',
      );
    });
  });
}
