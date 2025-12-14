import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;

void main() {
  test('featureRoutes contains /auth/reset route', () {
    final routes = features.featureRoutes.where(
      (route) => route.path == '/auth/reset',
    );
    expect(routes, isNotEmpty, reason: 'Route /auth/reset not found in featureRoutes');
    expect(routes.first.name, 'reset');
  });
}
