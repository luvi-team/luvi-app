import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/router.dart';

void main() {
  test('testAppRoutes contains /auth/password/success route', () {
    final route = testAppRoutes.whereType<GoRoute>().firstWhere(
      (route) => route.path == SuccessScreen.passwordSavedRoutePath,
    );
    expect(route.name, SuccessScreen.passwordSavedRouteName);
  });
}
