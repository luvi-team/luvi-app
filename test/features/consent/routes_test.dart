// test/features/consent/routes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/routes.dart';

void main() {
  test('welcome01 route is stable', () {
    expect(ConsentRoutes.welcome01Route, '/consent/welcome-01');
  });

  test('welcome02 route is stable', () {
    expect(ConsentRoutes.welcome02Route, '/consent/welcome-02');
  });

  test('welcome03 route is stable', () {
    expect(ConsentRoutes.welcome03Route, '/consent/welcome-03');
  });
}
