import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;

void main() {
  test('featureRoutes contains exactly one /auth/reset route', () {
    final routes = features.featureRoutes
        .where((route) => route.path == '/auth/reset')
        .toList();

    expect(routes, hasLength(1), reason: 'Expected exactly one /auth/reset route');
    expect(routes.single.name, 'reset');
  });
}
