import 'package:flutter_test/flutter_test.dart';
import '../../support/test_config.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';

void main() {
  TestConfig.ensureInitialized();
  test('validateAndSubmit sets errors for bad inputs', () {
    final n = LoginNotifier();
    n.setEmail('badmail');
    n.setPassword('123');
    n.validateAndSubmit();
    expect(n.state.emailError, isNotNull);
    expect(n.state.passwordError, isNotNull);
    expect(n.state.isValid, isFalse);
  });

  test('validateAndSubmit passes for good inputs', () {
    final n = LoginNotifier();
    n.setEmail('a@b.com');
    n.setPassword('secret6');
    n.validateAndSubmit();
    expect(n.state.emailError, isNull);
    expect(n.state.passwordError, isNull);
  });
}
