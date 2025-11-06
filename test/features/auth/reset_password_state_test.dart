import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/state/reset_password_state.dart';

import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('ResetPasswordNotifier email validation', () {
    late ProviderContainer container;
    late ResetPasswordNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      notifier = container.read(resetPasswordProvider.notifier);
    });

    test('accepts valid email', () {
      notifier.setEmail('user@example.com');

      final state = container.read(resetPasswordProvider);
      expect(state.error, isNull);
      expect(state.isValid, isTrue);
    });

    test('flags invalid email (missing domain)', () {
      notifier.setEmail('user@');

      final state = container.read(resetPasswordProvider);
      expect(state.error, ResetPasswordError.invalidEmail);
      expect(state.isValid, isFalse);
    });

    test('empty email yields no error but is not valid', () {
      notifier.setEmail('');

      final state = container.read(resetPasswordProvider);
      expect(state.error, isNull);
      expect(state.isValid, isFalse);
    });
  });
}

