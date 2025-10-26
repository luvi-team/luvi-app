import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/routes.dart' as features;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AuthSignupScreen renders expected UI elements', (tester) async {
    final router = GoRouter(
      routes: features.featureRoutes,
      initialLocation: AuthSignupScreen.routeName,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.buildAppTheme(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth_signup_screen')), findsOneWidget);
    expect(find.text(AuthStrings.signupTitle), findsOneWidget);
    expect(find.text(AuthStrings.signupSubtitle), findsOneWidget);
    expect(find.text(AuthStrings.signupHintFirstName), findsOneWidget);
    expect(find.text(AuthStrings.signupHintLastName), findsOneWidget);
    expect(find.text(AuthStrings.signupHintPhone), findsOneWidget);
    expect(find.text(AuthStrings.emailHint), findsOneWidget);
    expect(find.text(AuthStrings.passwordHint), findsOneWidget);

    final ctaFinder = find.byKey(const ValueKey('signup_cta_button'));
    expect(ctaFinder, findsOneWidget);
    final ctaButton = tester.widget<ElevatedButton>(ctaFinder);
    expect(ctaButton.onPressed, isNotNull);
  });
}
