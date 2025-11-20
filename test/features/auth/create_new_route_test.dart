import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;

void main() {
  test('featureRoutes contains /auth/password/new route', () {
    final route = features.featureRoutes.firstWhere(
      (route) => route.path == '/auth/password/new',
    );
    expect(route.name, 'password_new');
  });
}
