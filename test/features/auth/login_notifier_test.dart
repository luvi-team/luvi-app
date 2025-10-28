import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  test('validateAndSubmit sets errors for bad inputs', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('badmail');
    notifier.setPassword('123');
    await notifier.validateAndSubmit();

    final state = notifier.debugState();
    expect(state.emailError, isNotNull);
    expect(state.passwordError, isNotNull);
    expect(state.isValid, isFalse);
  });

  test('validateAndSubmit passes for good inputs', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('a@b.com');
    notifier.setPassword('secret6');
    await notifier.validateAndSubmit();

    final state = notifier.debugState();
    expect(state.emailError, isNull);
    expect(state.passwordError, isNull);
  });
}
