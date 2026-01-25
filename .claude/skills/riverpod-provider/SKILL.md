---
name: riverpod-provider
description: Use when creating or managing Riverpod state providers in features
---

# Riverpod Provider Skill

## When to Use
- Creating new state providers for screens or features
- Adding async operations with proper loading/error handling
- Implementing form validation state with sync updates
- Managing global services (dependency injection)
- Setting up reactive streams (auth state, real-time data)
- Need to understand provider dependencies (ref.watch vs ref.read)
- Keywords: "provider", "riverpod", "state", "notifier", "AsyncNotifier", "ref.watch", "ref.read", "StateNotifier", "FutureProvider", "StreamProvider", "autoDispose"

## When NOT to Use
- Pure UI widgets without state (use ui-frontend agent)
- One-off stateless logic or helper functions
- Database RLS policy creation (use reqing-ball agent, handled by Codex E)
- Analytics or logging implementation (covered by privacy-audit skill)
- Simple local variables within a single widget

## LUVI Riverpod Architecture

### Provider Categories (5 types)

LUVI uses 5 distinct provider patterns, each serving specific use cases:

| Provider Type | Use Case | autoDispose | Example File |
|--------------|----------|-------------|--------------|
| **@riverpod Code-Generated** | Modern approach with annotations | Auto (default) | consent02_state.dart |
| **AsyncNotifierProvider** | Async operations (API calls, DB queries) | Screen: YES | login_submit_provider.dart |
| **NotifierProvider** | Sync state updates (form validation) | Screen: YES | reset_password_state.dart |
| **StreamProvider** | Reactive streams (auth state, realtime) | Usually NO | auth_controller.dart |
| **Provider (DI)** | Service injection (repositories, utilities) | NO | auth_controller.dart, consent_service.dart |

### autoDispose Decision Matrix

**Critical Rule:** autoDispose determines provider lifecycle - wrong choice causes memory leaks or premature disposal.

| Provider Scope | autoDispose? | Reasoning | Example |
|----------------|--------------|-----------|---------|
| **Screen-scoped state** | ✅ YES | Disposed when screen unmounts, prevents memory leaks | `loginSubmitProvider`, `resetPasswordProvider` |
| **Form validation** | ✅ YES | Form state only lives while screen is active | `resetPasswordProvider` |
| **Global service** | ❌ NO | Service needed across multiple screens | `authRepositoryProvider`, `consentServiceProvider` |
| **Auth session** | ❌ NO | App-wide authentication state | `authSessionProvider` |
| **Shared config** | ❌ NO | Configuration used throughout app | `clockProvider` |

**Pattern:**
```dart
// ✅ Screen-scoped - autoDispose
final loginProvider = AsyncNotifierProvider.autoDispose<...>(...);

// ✅ Global service - NO autoDispose
final authRepositoryProvider = Provider<AuthRepository>(...);
```

### Naming Conventions

**Established LUVI patterns:**

1. **Provider variable:** `{feature}{purpose}Provider`
   - Examples: `loginSubmitProvider`, `consent02Provider`, `authSessionProvider`

2. **Notifier class:** `{Feature}{Purpose}Notifier`
   - Examples: `LoginSubmitNotifier`, `ResetPasswordNotifier`, `Consent02Notifier`

3. **State class:** `{Feature}State`
   - Examples: `LoginState`, `ResetPasswordState`, `Consent02State`

4. **Code-generated:** Generated providers drop "Notifier" suffix
   - Class: `Consent02Notifier` → Provider: `consent02Provider`

## Provider Patterns

### Pattern 1: @riverpod Code-Generated (Modern Approach)

**When to use:** New providers - cleanest syntax, auto-generates provider instance

**File:** [lib/features/consent/state/consent02_state.dart](../../lib/features/consent/state/consent02_state.dart)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'consent02_state.g.dart';

@immutable
class Consent02State {
  final Map<ConsentScope, bool> choices;
  const Consent02State(this.choices);

  bool get requiredAccepted =>
      kRequiredConsentScopes.every((s) => choices[s] == true);

  // CRITICAL: Always use copyWith for immutability
  Consent02State copyWith({Map<ConsentScope, bool>? choices}) =>
      Consent02State(choices ?? this.choices);
}

@riverpod
class Consent02Notifier extends _$Consent02Notifier {
  @override
  Consent02State build() =>
      Consent02State({for (final s in ConsentScope.values) s: false});

  void toggle(ConsentScope s) => state = state.copyWith(
    choices: {...state.choices, s: !(state.choices[s] ?? false)},
  );
}
```

**Usage in UI:**
```dart
final state = ref.watch(consent02Provider);  // Reactive rebuild
final notifier = ref.read(consent02Provider.notifier);  // One-time read

// In event handler
onPressed: () => notifier.toggle(ConsentScope.analytics);
```

**Code generation:**
```bash
dart run build_runner build
# or watch mode:
dart run build_runner watch
```

### Pattern 2: AsyncNotifierProvider (Async Operations)

**When to use:** API calls, database queries, async submission logic

**File:** [lib/features/auth/state/login_submit_provider.dart](../../lib/features/auth/state/login_submit_provider.dart)

```dart
class LoginSubmitNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({required String email, required String password}) async {
    // CRITICAL: Check isLoading to prevent duplicate submissions
    if (state.isLoading) {
      return;
    }

    state = const AsyncLoading();

    try {
      // SECURITY: Pass password as parameter, not stored in state
      await repository.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
    } on AuthException catch (error) {
      // Handle specific error types
      state = AsyncError(error, StackTrace.current);
    }
  }
}

final loginSubmitProvider =
    AsyncNotifierProvider.autoDispose<LoginSubmitNotifier, void>(
  LoginSubmitNotifier.new,
  name: 'loginSubmitProvider',  // Debugging aid
);
```

**Usage in UI:**
```dart
final submitAsync = ref.watch(loginSubmitProvider);
final isLoading = submitAsync.isLoading;

ElevatedButton(
  onPressed: isLoading ? null : () {
    ref.read(loginSubmitProvider.notifier).submit(
      email: emailController.text,
      password: passwordController.text,
    );
  },
  child: isLoading ? CircularProgressIndicator() : Text('Submit'),
)
```

### Pattern 3: NotifierProvider (Sync State)

**When to use:** Form validation, UI state without async operations

**File:** [lib/features/auth/state/reset_password_state.dart](../../lib/features/auth/state/reset_password_state.dart)

```dart
@immutable
class ResetPasswordState {
  const ResetPasswordState({this.email = '', this.error, this.isValid = false});

  final String email;
  final ResetPasswordError? error;
  final bool isValid;

  factory ResetPasswordState.initial() => const ResetPasswordState();

  // CRITICAL: Sentinel pattern for nullable parameters
  static const Object _sentinel = Object();

  ResetPasswordState copyWith({
    String? email,
    Object? error = _sentinel,  // Allows explicit null assignment
    bool? isValid,
  }) {
    return ResetPasswordState(
      email: email ?? this.email,
      error: identical(error, _sentinel)
          ? this.error
          : error as ResetPasswordError?,
      isValid: isValid ?? this.isValid,
    );
  }
}

class ResetPasswordNotifier extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => ResetPasswordState.initial();

  void setEmail(String value) {
    final trimmed = value.trim();
    final validation = _validateEmail(trimmed);
    state = state.copyWith(
      email: trimmed,
      error: validation,
      isValid: validation == null && trimmed.isNotEmpty,
    );
  }
}

final resetPasswordProvider =
    NotifierProvider.autoDispose<ResetPasswordNotifier, ResetPasswordState>(
  ResetPasswordNotifier.new,
  name: 'resetPasswordProvider',
);
```

**Why sentinel pattern?**
- Distinguishes between "don't change" vs. "set to null"
- Without sentinel: `copyWith(error: null)` would keep old error
- With sentinel: `copyWith(error: null)` explicitly sets error to null

### Pattern 4: StreamProvider (Reactive Streams)

**When to use:** Real-time data, auth state changes, websockets

**File:** [lib/features/auth/state/auth_controller.dart](../../lib/features/auth/state/auth_controller.dart)

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseService.client);
});

final authSessionProvider = StreamProvider<Session?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges().map((e) => e.session);
});
```

**Usage in UI:**
```dart
final sessionAsync = ref.watch(authSessionProvider);

return sessionAsync.when(
  data: (session) => session != null
      ? AuthenticatedView()
      : UnauthenticatedView(),
  loading: () => LoadingSpinner(),
  error: (error, stack) => ErrorView(error: error),
);
```

**Key difference from AsyncNotifierProvider:**
- StreamProvider: Passive listener, emits values over time
- AsyncNotifierProvider: Active operations (submit, load data once)

### Pattern 5: Provider (Dependency Injection)

**When to use:** Services, repositories, utilities, config

**Files:**
- [lib/features/auth/state/auth_controller.dart](../../lib/features/auth/state/auth_controller.dart)
- [lib/features/consent/state/consent_service.dart](../../lib/features/consent/state/consent_service.dart)

```dart
// Service injection
final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService();
});

// Repository injection with dependency
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseService.client);
});
```

**Usage:**
```dart
final consentService = ref.read(consentServiceProvider);
await consentService.accept(version: 'v1', scopes: ['analytics']);
```

**Why Provider for DI?**
- Makes services testable (can override in tests)
- Single source of truth for service instances
- No `.autoDispose` - services are app-wide singletons

## UI Integration Patterns

### ref.watch vs ref.read

**Critical distinction:** Wrong choice causes bugs or performance issues

```dart
// ✅ ref.watch - Reactive, rebuilds on state change
final state = ref.watch(consent02Provider);
// Use in: build() methods, computed values

// ✅ ref.read - One-time read, no rebuild dependency
onPressed: () {
  ref.read(consent02Provider.notifier).toggle(ConsentScope.analytics);
}
// Use in: Event handlers, callbacks, one-off operations

// ❌ ref.watch in event handler - BAD! Causes warnings
onPressed: () {
  ref.watch(consent02Provider.notifier).toggle(ConsentScope.analytics);
}
```

### AsyncValue Handling

**Pattern:** Use `.when()` for full coverage, `.maybeWhen()` for defaults

```dart
final userAsync = ref.watch(userStateServiceProvider);

// Full coverage with .when()
return userAsync.when(
  data: (user) => Text('Hello ${user.name}'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error: error),
);

// Partial handling with .maybeWhen()
return userAsync.maybeWhen(
  data: (user) => Text('Hello ${user.name}'),
  orElse: () => SizedBox.shrink(), // Loading/error fallback
);

// Check loading state directly
final isLoading = userAsync.isLoading;
final hasError = userAsync.hasError;
```

## Security Patterns

### CRITICAL: Never Store Passwords in State

**Security violation:**
```dart
// ❌ WRONG - Password in state (security breach)
class LoginState {
  final String email;
  final String password;  // FORBIDDEN!
}
```

**Correct pattern:**
```dart
// ✅ CORRECT - Password as method parameter only
Future<void> submit({
  required String email,
  required String password,  // Parameter, never stored
}) async {
  await repository.signInWithPassword(
    email: email,
    password: password,  // Pass directly to API
  );
  // Password immediately goes out of scope
}
```

**From login_submit_provider.dart:24:**
```dart
// SECURITY: Pass password as parameter, not stored in provider state.
await loginNotifier.validateAndSubmit(password: password);
```

## File Location Conventions

### Feature-Specific Providers

**Location:** `lib/features/{feature}/state/`

```
lib/features/auth/state/
├── login_state.dart          # State class + NotifierProvider
├── login_submit_provider.dart # AsyncNotifierProvider for submission
└── auth_controller.dart      # Auth session (StreamProvider)

lib/features/consent/state/
├── consent02_state.dart      # Code-generated with @riverpod
└── consent_service.dart      # Service + Provider DI
```

### Shared/Core Providers

**Location:** `lib/core/{domain}/`

```
lib/core/services/
└── clock_provider.dart       # Global services

lib/core/auth/
└── auth_controller.dart      # App-wide auth state
```

## Common Mistakes

| Mistake | Severity | Fix | Example File |
|---------|----------|-----|--------------|
| Missing autoDispose on screen state | High | Add `.autoDispose` to provider | `resetPasswordProvider` line 67 (correct example) |
| Using ref.watch in event handler | High | Use `ref.read` instead | Common anti-pattern, causes warnings |
| Forgetting isLoading check | Medium | `if (state.isLoading) return;` | `login_submit_provider.dart:16` (correct example) |
| Storing password in state | **Critical** | Pass as parameter only | `login_submit_provider.dart:24` comment |
| Missing copyWith immutability | High | Always use copyWith for state updates | `consent02_state.dart:26` (correct example) |
| Not handling AsyncValue.error | Medium | Use `.when()` or `.maybeWhen()` | See AsyncValue handling above |
| Hardcoded initial state | Low | Use factory constructor | `reset_password_state.dart:15` (correct example) |

## Workflow Steps

1. **Identify need for state management**
   - New screen with form → NotifierProvider
   - API submission → AsyncNotifierProvider
   - Real-time data → StreamProvider
   - Service injection → Provider

2. **Choose provider type** (refer to categories table)

3. **Determine autoDispose**
   - Screen-scoped = YES (`.autoDispose`)
   - Global service = NO

4. **Create state class** (if needed)
   - Immutable (`@immutable`)
   - copyWith method (use sentinel for nullable fields)
   - Factory constructor for initial state

5. **Implement Notifier**
   - @riverpod (modern) or manual provider definition
   - Override `build()` method
   - Add state mutation methods

6. **UI integration**
   - `ref.watch(provider)` in build() for reactive state
   - `ref.read(provider.notifier)` in event handlers

7. **Handle AsyncValue** (if async)
   - Use `.when()` for loading/error/data states
   - Check `.isLoading` before operations

8. **Add widget tests**
   - Override providers with test values
   - Verify state changes
   - Test async operations

## Quick Reference: File Locations

### Example Providers

**Code-Generated:**
- [lib/features/consent/state/consent02_state.dart](../../lib/features/consent/state/consent02_state.dart)

**AsyncNotifier:**
- [lib/features/auth/state/login_submit_provider.dart](../../lib/features/auth/state/login_submit_provider.dart)

**Notifier:**
- [lib/features/auth/state/reset_password_state.dart](../../lib/features/auth/state/reset_password_state.dart)

**StreamProvider:**
- [lib/features/auth/state/auth_controller.dart](../../lib/features/auth/state/auth_controller.dart)

**Provider DI:**
- [lib/features/consent/state/consent_service.dart](../../lib/features/consent/state/consent_service.dart)

### Documentation

- **Riverpod Official:** [pub.dev/packages/flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- **Code Generation:** [pub.dev/packages/riverpod_annotation](https://pub.dev/packages/riverpod_annotation)
- **LUVI Pattern:** CLAUDE.md (Archon-first workflow)

## Reference Files (SSOT)

**Primary Sources:**
- CLAUDE.md - Provider patterns, Archon-first workflow
- consent02_state.dart - @riverpod code-generation pattern
- login_submit_provider.dart - AsyncNotifier with error handling, isLoading check
- reset_password_state.dart - Sync state with validation, sentinel pattern
- auth_controller.dart - StreamProvider for auth state, Provider DI

**Related:**
- ui-frontend agent - Screen implementation patterns
- privacy-audit skill - Security patterns (no passwords in state)
- consent-flow skill - Real-world provider usage example

## External References

- [Riverpod Documentation](https://riverpod.dev)
- [Code Generation Guide](https://riverpod.dev/docs/concepts/about_code_generation)
- [AsyncValue API](https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html)
