import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import '../../support/test_config.dart';

class _FakeServerErrorLoginNotifier extends LoginNotifier {
  @override
  Future<void> validateAndSubmit() async {
    await super.validateAndSubmit();
    final current = state.value!;
    state = AsyncData(
      current.copyWith(
        globalError: AuthStrings.errLoginUnavailable,
      ),
    );
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
    notifier.setPassword('123');
    await notifier.validateAndSubmit();

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
    notifier.setPassword('secret88');
    await notifier.validateAndSubmit();

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
    notifier.setPassword('secret88');
    await notifier.validateAndSubmit();

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
    notifier.setPassword('');
    await notifier.validateAndSubmit();

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
    notifier.setPassword('secret88');
    await notifier.validateAndSubmit();

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
    notifier.setPassword('12345');
    await notifier.validateAndSubmit();

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
    notifier.setPassword('12345678');
    await notifier.validateAndSubmit();

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
    notifier.setPassword('12345678');
    await notifier.validateAndSubmit();

    final state = notifier.debugState();
    expect(state.emailError, isNull);
    expect(state.passwordError, isNull);
    expect(state.globalError, AuthStrings.errLoginUnavailable);
    expect(state.isValid, isTrue);
  });
}
