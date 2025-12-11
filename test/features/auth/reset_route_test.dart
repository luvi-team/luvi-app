import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;

void main() {
  test('featureRoutes contains /auth/reset route', () {
    final route = features.featureRoutes.firstWhere(
      (route) => route.path == '/auth/reset',
      orElse: () => throw AssertionError('Route /auth/reset not found in featureRoutes'),
    );
    expect(route.name, 'reset');
  });
}
