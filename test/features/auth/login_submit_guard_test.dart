import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/test_config.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/login_submit_provider.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestConfig.ensureInitialized();

  test('submit avoids network; keeps local password error when only password invalid', () async {
    final mockRepo = _MockAuthRepository();
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    addTearDown(container.dispose);

    // Seed form state with valid-looking email.
    final loginNotifier = container.read(loginProvider.notifier);
    loginNotifier.setEmail('user@example.com');
    // Password is passed directly to submit, not stored in state (security).

    // Submit should short-circuit and not hit the repository.
    await container
        .read(loginSubmitProvider.notifier)
        .submit(email: 'user@example.com', password: 'short');

    verifyNever(() => mockRepo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));

    final state = container.read(loginProvider).value!;
    // Email stays valid; password keeps its local validation error.
    expect(state.emailError, isNull);
    expect(state.passwordError, AuthStrings.errPasswordInvalid);
    expect(state.globalError, isNull);
  });

  test('invalid email + password error: early abort, keeps email error, no loading', () async {
    final mockRepo = _MockAuthRepository();
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    addTearDown(container.dispose);

    // Seed invalid email (password is passed directly to submit, not stored in state).
    final loginNotifier = container.read(loginProvider.notifier);
    loginNotifier.setEmail('bad');

    // Listen for loading transitions on the submit provider
    var sawLoading = false;
    final sub = container.listen(loginSubmitProvider, (prev, next) {
      if (next.isLoading) sawLoading = true;
    }, fireImmediately: false);
    addTearDown(sub.close);

    await container
        .read(loginSubmitProvider.notifier)
        .submit(email: 'bad', password: 'short');

    // No network call attempted
    verifyNever(() => mockRepo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));

    // Provider did not enter loading and ended in AsyncData(null)
    expect(sawLoading, isFalse);
    final submitState = container.read(loginSubmitProvider);
    expect(submitState.hasValue, isTrue);

    // Email error remains the local validation error; password error untouched;
    // invalidCredentials must NOT be set in this path.
    final state = container.read(loginProvider).value!;
    expect(state.emailError, AuthStrings.errEmailInvalid);
    expect(state.passwordError, AuthStrings.errPasswordInvalid);
    expect(state.globalError, isNull);
  });

  group('AuthException error.code handling', () {
    test('uses error.code for invalid_credentials when code is present', () async {
      final mockRepo = _MockAuthRepository();
      when(() => mockRepo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException(
        'Some message without patterns',
        code: 'invalid_credentials',
      ));

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final loginNotifier = container.read(loginProvider.notifier);
      loginNotifier.setEmail('user@example.com');

      await container
          .read(loginSubmitProvider.notifier)
          .submit(email: 'user@example.com', password: 'validPassword123');

      final state = container.read(loginProvider).value!;
      expect(state.emailError, AuthStrings.invalidCredentials);
      expect(state.passwordError, AuthStrings.invalidCredentials);
      expect(state.globalError, isNull);
    });

    test('uses error.code for email_not_confirmed when code is present', () async {
      final mockRepo = _MockAuthRepository();
      when(() => mockRepo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException(
        'Some message without patterns',
        code: 'email_not_confirmed',
      ));

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final loginNotifier = container.read(loginProvider.notifier);
      loginNotifier.setEmail('user@example.com');

      await container
          .read(loginSubmitProvider.notifier)
          .submit(email: 'user@example.com', password: 'validPassword123');

      final state = container.read(loginProvider).value!;
      expect(state.emailError, isNull);
      expect(state.passwordError, isNull);
      expect(state.globalError, AuthStrings.errConfirmEmail);
    });

    test('falls back to message matching when code is null', () async {
      final mockRepo = _MockAuthRepository();
      when(() => mockRepo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException(
        'Invalid credentials provided', // Contains 'invalid' and 'credentials'
      ));

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final loginNotifier = container.read(loginProvider.notifier);
      loginNotifier.setEmail('user@example.com');

      await container
          .read(loginSubmitProvider.notifier)
          .submit(email: 'user@example.com', password: 'validPassword123');

      final state = container.read(loginProvider).value!;
      expect(state.emailError, AuthStrings.invalidCredentials);
      expect(state.passwordError, AuthStrings.invalidCredentials);
      expect(state.globalError, isNull);
    });

    test('falls back to message matching for email confirmation when code is null', () async {
      final mockRepo = _MockAuthRepository();
      when(() => mockRepo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException(
        'Please confirm your email', // Contains 'confirm'
      ));

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final loginNotifier = container.read(loginProvider.notifier);
      loginNotifier.setEmail('user@example.com');

      await container
          .read(loginSubmitProvider.notifier)
          .submit(email: 'user@example.com', password: 'validPassword123');

      final state = container.read(loginProvider).value!;
      expect(state.emailError, isNull);
      expect(state.passwordError, isNull);
      expect(state.globalError, AuthStrings.errConfirmEmail);
    });

    test('sets generic error when no patterns match and code is null', () async {
      final mockRepo = _MockAuthRepository();
      when(() => mockRepo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException(
        'Unknown server error', // No matching patterns
      ));

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final loginNotifier = container.read(loginProvider.notifier);
      loginNotifier.setEmail('user@example.com');

      await container
          .read(loginSubmitProvider.notifier)
          .submit(email: 'user@example.com', password: 'validPassword123');

      final state = container.read(loginProvider).value!;
      expect(state.emailError, isNull);
      expect(state.passwordError, isNull);
      expect(state.globalError, AuthStrings.errLoginUnavailable);
    });
  });
}
