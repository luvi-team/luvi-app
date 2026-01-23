import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import '../../support/test_config.dart';

class _FakeServerErrorLoginNotifier extends LoginNotifier {
  // Simulates server error after successful client-side validation
  @override
  Future<bool> validateAndSubmit({required String password}) async {
    bool isValid;
    try {
      isValid = await super.validateAndSubmit(password: password);
      if (!isValid) return false;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
    final current = state.value;
    if (current == null) {
      state = AsyncError(
        StateError('No current state after validation'),
        StackTrace.current,
      );
      return false;
    }
    state = AsyncData(
      current.copyWith(
        globalError: AuthStrings.errLoginUnavailable,
      ),
    );
    return false;
  }
}

void main() {
  TestConfig.ensureInitialized();
  test('validateAndSubmit sets errors for bad inputs', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('badmail');
    await notifier.validateAndSubmit(password: '123');

    final state = notifier.debugState();

    expect(state.emailError, AuthStrings.errEmailInvalid);
    expect(state.passwordError, AuthStrings.errPasswordInvalid);
    expect(state.isValid, isFalse);
  });

  test('validateAndSubmit passes for good inputs', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('ab@b.com');
    await notifier.validateAndSubmit(password: 'secret88');

    final state = notifier.debugState();
    expect(state.emailError, isNull);
    expect(state.passwordError, isNull);
    expect(state.isValid, isTrue);
  });

  test('validateAndSubmit flags empty email', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('');
    await notifier.validateAndSubmit(password: 'secret88');

    final state = notifier.debugState();
    expect(state.emailError, AuthStrings.errEmailEmpty);
    expect(state.passwordError, isNull);
    expect(state.isValid, isFalse);
  });

  test('validateAndSubmit flags empty password', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('user@example.com');
    await notifier.validateAndSubmit(password: '');

    final state = notifier.debugState();
    expect(state.emailError, isNull);
    expect(state.passwordError, AuthStrings.errPasswordEmpty);
    expect(state.isValid, isFalse);
  });

  test('validateAndSubmit flags malformed email without domain', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('test@');
    await notifier.validateAndSubmit(password: 'secret88');

    final state = notifier.debugState();
    expect(state.emailError, AuthStrings.errEmailInvalid);
    expect(state.passwordError, isNull);
    expect(state.isValid, isFalse);
  });

  test('validateAndSubmit invalid for password length 5', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('user@example.com');
    await notifier.validateAndSubmit(password: '12345');

    final state = notifier.debugState();
    expect(state.emailError, isNull);
    expect(state.passwordError, AuthStrings.errPasswordInvalid);
    expect(state.isValid, isFalse);
  });


  test('validateAndSubmit valid for password length 8', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('user@example.com');
    await notifier.validateAndSubmit(password: '12345678');

    final state = notifier.debugState();
    expect(state.emailError, isNull);
    expect(state.passwordError, isNull);
    expect(state.isValid, isTrue);
  });

  test('validateAndSubmit surfaces server global error', () async {
    final container = ProviderContainer(
      overrides: [
        loginProvider.overrideWith(_FakeServerErrorLoginNotifier.new),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(loginProvider.notifier);
    await container.read(loginProvider.future);

    notifier.setEmail('user@example.com');
    final result = await notifier.validateAndSubmit(password: '12345678');

    final state = notifier.debugState();
    expect(state.emailError, isNull);
    expect(state.passwordError, isNull);
    expect(state.globalError, AuthStrings.errLoginUnavailable);
    // Inputs are valid (user can retry), but submission failed (result is false)
    expect(state.isValid, isTrue);
    expect(result, isFalse);
  });
}
