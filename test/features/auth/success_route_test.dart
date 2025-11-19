import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/routes.dart' as features;

void main() {
  test('featureRoutes contains /auth/password/success route', () {
    final route = features.featureRoutes.firstWhere(
      (route) => route.path == SuccessScreen.passwordSavedRoutePath,
    );
    expect(route.name, SuccessScreen.passwordSavedRouteName);
  });
}
