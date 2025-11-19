import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;

void main() {
  test('featureRoutes contains forgot sent success route', () {
    final route = features.featureRoutes.firstWhere(
      (route) => route.path == SuccessScreen.forgotEmailSentRoutePath,
    );

    expect(route.name, SuccessScreen.forgotEmailSentRouteName);
  });
}
