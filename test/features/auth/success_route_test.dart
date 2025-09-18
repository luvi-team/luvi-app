import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/routes.dart' as features;

void main() {
  test('featureRoutes contains /auth/password/success route', () {
    final route = features.featureRoutes.firstWhere(
      (route) => route.path == '/auth/password/success',
    );
    expect(route.name, 'password_success');
  });
}
