import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/router.dart';

void main() {
  test('testAppRoutes contains /auth/password/new route', () {
    final route = testAppRoutes.whereType<GoRoute>().firstWhere(
      (route) => route.path == '/auth/password/new',
    );
    expect(route.name, 'password_new');
  });
}
