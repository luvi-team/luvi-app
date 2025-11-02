import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/state/reset_password_state.dart';

import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('ResetPasswordNotifier email validation', () {
    test('accepts valid email', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(resetPasswordProvider.notifier);

      notifier.setEmail('user@example.com');

      final state = container.read(resetPasswordProvider);
      expect(state.error, isNull);
      expect(state.isValid, isTrue);
    });

    test('flags invalid email (missing domain)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(resetPasswordProvider.notifier);

      notifier.setEmail('user@');

      final state = container.read(resetPasswordProvider);
      expect(state.error, ResetPasswordError.invalidEmail);
      expect(state.isValid, isFalse);
    });

    test('empty email yields no error but is not valid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(resetPasswordProvider.notifier);

      notifier.setEmail('');

      final state = container.read(resetPasswordProvider);
      expect(state.error, isNull);
      expect(state.isValid, isFalse);
    });
  });
}

