import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/router.dart';

void main() {
  test('testAppRoutes contains exactly one /auth/reset route', () {
    final routes = testAppRoutes
        .whereType<GoRoute>()
        .where((route) => route.path == '/auth/reset')
        .toList();

    expect(routes, hasLength(1), reason: 'Expected exactly one /auth/reset route');
    expect(routes.single.name, 'reset');
  });
}
