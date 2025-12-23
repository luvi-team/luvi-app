import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'init_exception.dart';
import 'init_mode.dart';
import 'logger.dart';

/// Stable error IDs for analytics (Sentry/PostHog).
const String kErrProfilesUpsertConsentGateNoRowReturned =
    'profiles_upsert_consent_gate_no_row_returned';

/// Canonical IDs for fitness levels (matches public.profiles.fitness_level).
const Set<String> kValidFitnessLevelIds = {'beginner', 'occasional', 'fit'};

/// Canonical IDs for goals (matches public.profiles.goals JSONB array).
const Set<String> kValidGoalIds = {
  'fitter',
  'energy',
  'sleep',
  'cycle',
  'longevity',
  'wellbeing',
};

/// Canonical IDs for interests (matches public.profiles.interests JSONB array).
const Set<String> kValidInterestIds = {
  'strength_training',
  'cardio',
  'mobility',
  'nutrition',
  'mindfulness',
  'hormones_cycle',
};

class SupabaseService {
  static bool _initialized = false;
  // A single gate to ensure only the first caller performs initialization and
  // others await the same Future. This avoids non-atomic check-then-assign races.
  static Completer<void>? _initCompleter;
  // Serialize the check + assign of _initCompleter so only one caller
  // creates/assigns the gate at a time. Avoids duplicate initialization
  // under concurrent callers.
  static final _AsyncLock _initLock = _AsyncLock();
  static Object? _initializationError;
  static StackTrace? _initializationStackTrace;
  static SupabaseValidationConfig _validationConfig =
      const SupabaseValidationConfig();
  static SupabaseAuthDeepLinkConfig _authDeepLinkConfig =
      SupabaseAuthDeepLinkConfig.fallback;

  static bool get isInitialized => _initialized;
  static Object? get lastInitializationError => _initializationError;
  static StackTrace? get lastInitializationStackTrace =>
      _initializationStackTrace;
  static SupabaseValidationConfig get validationConfig => _validationConfig;

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('SupabaseService has not been initialized');
    }
    return Supabase.instance.client;
  }

  /// Attempt to load environment configuration and initialize Supabase.
  static Future<void> tryInitialize({String envFile = '.env.development'}) {
    if (_initialized) return Future.value();

    // Serialize check+assign so only one caller creates the gate; others
    // will either see the existing gate or wait briefly for this section.
    return _initLock.synchronized<void>(() {
      if (_initialized) return Future.value();

      final existingGate = _initCompleter;
      if (existingGate != null) return existingGate.future;

      // Create the shared gate and kick off initialization exactly once.
      final gate = _initCompleter = Completer<void>();
      _performInitializeAndCache(envFile).then<void>((_) {
        if (!gate.isCompleted) gate.complete();
      }).catchError((Object error, StackTrace stack) async {
        // Clear the shared completer inside the lock to avoid races.
        await _initLock.synchronized<void>(() {
          _initCompleter = null;
          return Future<void>.value();
        });
        // Propagate the error to all awaiters outside the lock.
        if (!gate.isCompleted) {
          gate.completeError(error, stack);
        }
      });
      return gate.future;
    });
  }

  static void configure({
    SupabaseValidationConfig? validationConfig,
    SupabaseAuthDeepLinkConfig? authConfig,
  }) {
    if (validationConfig != null) {
      _validationConfig = validationConfig;
    }
    if (authConfig != null) {
      if (_initialized) {
        throw StateError(
          'authConfig cannot be set after SupabaseService is initialized',
        );
      }
      _authDeepLinkConfig = authConfig;
    }
  }

  @visibleForTesting
  static void resetForTest() {
    _initialized = false;
    _initCompleter = null;
    _initializationError = null;
    _initializationStackTrace = null;
    _validationConfig = const SupabaseValidationConfig();
    // NOTE: Supabase.instance does not expose a public reset. Tests should mock or
    // inject a fake Supabase client instead of reinitializing the singleton.
  }

  static Future<void> _performInitializeAndCache(String envFile) async {
    // Resolve test-mode at the start and short-circuit: in tests we operate
    // without an initialized Supabase singleton and keep [_initialized] false
    // so callers avoid touching `Supabase.instance`.
    final bool isTest = InitModeBridge.resolve() == InitMode.test;
    if (isTest) {
      _initialized = false;
      _initializationError = null;
      _initializationStackTrace = null;
      return;
    }

    try {
      await _performInitialize(envFile: envFile);
      _initialized = true;
      _initializationError = null;
      _initializationStackTrace = null;
    } catch (error, stackTrace) {
      _initialized = false;
      _initializationError = error;
      _initializationStackTrace = stackTrace;
      final wrappedError = SupabaseInitException(
        'Failed to initialize Supabase',
        originalError: error,
      );
      final details = FlutterErrorDetails(
        exception: wrappedError,
        stack: stackTrace,
        library: 'supabase_service',
        context: ErrorDescription('initializing Supabase'),
      );
      FlutterError.reportError(details);
      throw wrappedError;
    }
  }

  static Future<void> _performInitialize({required String envFile}) async {
    // Check if credentials are provided via --dart-define (preferred for security).
    // Only try to load .env file if dart-define values are not available.
    const defineUrl = String.fromEnvironment('SUPABASE_URL');
    const defineAnon = String.fromEnvironment('SUPABASE_ANON_KEY');
    final hasDartDefine = defineUrl.isNotEmpty && defineAnon.isNotEmpty;

    if (!hasDartDefine) {
      // Fallback: try loading from .env file (for legacy/local dev setups)
      await _loadEnvironment(envFile);
    }

    final credentials = _resolveCredentials(envFile);
    await _initializeSupabase(credentials);
  }

  /// Check if user is authenticated
  static bool get isAuthenticated =>
      _initialized && client.auth.currentUser != null;

  /// Get current user
  static User? get currentUser =>
      _initialized ? client.auth.currentUser : null;

  /// Initialize Supabase from environment variables
  static Future<void> initializeFromEnv({
    String envFile = '.env.development',
  }) async {
    await tryInitialize(envFile: envFile);
    if (!_initialized) {
      final error = _initializationError;
      if (error != null) {
        throw StateError('Supabase initialization failed: $error');
      }
      throw StateError('Supabase initialization failed for unknown reasons.');
    }
  }

  /// Upsert email preferences for the current user
  static Future<Map<String, dynamic>?> upsertEmailPreferences({
    bool? newsletter,
  }) async {
    final user = _ensureAuthenticated();
    final data = <String, dynamic>{'user_id': user.id};
    if (newsletter != null) data['newsletter'] = newsletter;
    final row = await client
        .from('email_preferences')
        .upsert(data, onConflict: 'user_id')
        .select()
        .single();
    return row;
  }

  /// Get email preferences for the current user
  static Future<Map<String, dynamic>?> getEmailPreferences() async {
    final user = _ensureAuthenticated();
    final userId = user.id;
    return await client
        .from('email_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  /// Upsert cycle data for the current user
  ///
  /// Timezone handling for [lastPeriod]: this method interprets the provided
  /// DateTime as a calendar date in the user's local timezone and normalizes
  /// it to a UTC date-only value (YYYY-MM-DD). The time-of-day and timezone
  /// offset of the input are ignored to avoid accidental date shifts when
  /// converting between local and UTC.
  static Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  }) async {
    final user = _ensureAuthenticated();
    if (cycleLength <= 0) {
      throw ArgumentError.value(cycleLength, 'cycleLength', 'must be positive');
    }
    if (cycleLength > 60) {
      throw ArgumentError.value(
        cycleLength,
        'cycleLength',
        'must be <= 60',
      );
    }
    if (periodDuration <= 0) {
      throw ArgumentError.value(
        periodDuration,
        'periodDuration',
        'must be positive',
      );
    }
    if (periodDuration > 15) {
      throw ArgumentError.value(
        periodDuration,
        'periodDuration',
        'must be <= 15',
      );
    }
    if (periodDuration > cycleLength) {
      throw ArgumentError.value(
        periodDuration,
        'periodDuration',
        'cannot exceed cycle length',
      );
    }
    final ageConfig = _validationConfig;
    if (age < ageConfig.minAge || age > ageConfig.maxAge) {
      throw ArgumentError.value(
        age,
        'age',
        'must be between ${ageConfig.minAge} and ${ageConfig.maxAge}',
      );
    }
    // Normalize to date-only, preserving the user's local calendar date.
    final lpLocal = lastPeriod.toLocal();
    final lastPeriodDate = DateTime.utc(
      lpLocal.year,
      lpLocal.month,
      lpLocal.day,
    );
    // Compare against today's local calendar date, normalized similarly.
    final nowLocal = DateTime.now();
    final nowDate = DateTime.utc(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
    );
    if (lastPeriodDate.isAfter(nowDate)) {
      throw ArgumentError.value(
        lastPeriod,
        'lastPeriod',
        'cannot be in the future',
      );
    }
    final payload = <String, dynamic>{
      'user_id': user.id,
      'cycle_length': cycleLength,
      'period_duration': periodDuration,
      // Persist as an ISO date (YYYY-MM-DD) based on the normalized
      // date-only value to avoid timezone-induced shifts.
      'last_period': _formatIsoDate(lastPeriodDate),
      'age': age,
    };
    final row = await client
        .from('cycle_data')
        .upsert(payload, onConflict: 'user_id')
        .select()
        .single();
    return row;
  }

  /// Get cycle data for the current user
  static Future<Map<String, dynamic>?> getCycleData() async {
    final user = _ensureAuthenticated();
    final userId = user.id;
    return await client
        .from('cycle_data')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  /// Upsert user profile data from onboarding
  ///
  /// Saves display name, birth date, goals, and interests to profiles table.
  /// Validates all canonical IDs before persisting to prevent invalid data.
  static Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  }) async {
    final user = _ensureAuthenticated();
    if (displayName.trim().isEmpty) {
      throw ArgumentError.value(displayName, 'displayName', 'cannot be empty');
    }
    // Validate age bounds
    final now = DateTime.now();
    final age = now.year -
        birthDate.year -
        ((now.month < birthDate.month ||
                (now.month == birthDate.month && now.day < birthDate.day))
            ? 1
            : 0);
    final ageConfig = _validationConfig;
    if (age < ageConfig.minAge || age > ageConfig.maxAge) {
      throw ArgumentError.value(
        birthDate,
        'birthDate',
        'age must be between ${ageConfig.minAge} and ${ageConfig.maxAge}',
      );
    }

    // Validate canonical IDs to prevent invalid data persistence
    final normalizedFitnessLevel = fitnessLevel.toLowerCase();
    if (!kValidFitnessLevelIds.contains(normalizedFitnessLevel)) {
      throw ArgumentError.value(
        fitnessLevel,
        'fitnessLevel',
        'invalid fitness level ID',
      );
    }
    // Single-pass validation + normalization for goals
    final normalizedGoals = <String>[];
    for (final goal in goals) {
      final normalized = goal.toLowerCase();
      if (!kValidGoalIds.contains(normalized)) {
        throw ArgumentError.value(goal, 'goals', 'invalid goal ID');
      }
      normalizedGoals.add(normalized);
    }

    // Single-pass validation + normalization for interests
    final normalizedInterests = <String>[];
    for (final interest in interests) {
      final normalized = interest.toLowerCase();
      if (!kValidInterestIds.contains(normalized)) {
        throw ArgumentError.value(interest, 'interests', 'invalid interest ID');
      }
      normalizedInterests.add(normalized);
    }

    // Normalize birthDate to UTC date-only
    final bdLocal = birthDate.toLocal();
    final birthDateNormalized =
        DateTime.utc(bdLocal.year, bdLocal.month, bdLocal.day);

    final timestamp = DateTime.now().toUtc().toIso8601String();
    final payload = <String, dynamic>{
      'user_id': user.id,
      'display_name': displayName.trim(),
      'birth_date': _formatIsoDate(birthDateNormalized),
      'fitness_level': normalizedFitnessLevel,
      'goals': normalizedGoals,
      'interests': normalizedInterests,
      'updated_at': timestamp,
    };
    final row = await client
        .from('profiles')
        .upsert(payload, onConflict: 'user_id')
        .select()
        .single();
    return row;
  }

  /// Upsert consent gate state for the current user in `public.profiles`.
  ///
  /// SSOT: This is the server-side source of truth for consent version checks.
  /// SharedPreferences may cache this value but must not be the primary truth.
  ///
  /// This does not touch onboarding completion.
  static Future<Map<String, dynamic>?> upsertConsentGate({
    required int acceptedConsentVersion,
    bool markWelcomeSeen = true,
  }) async {
    final user = _ensureAuthenticated();
    if (acceptedConsentVersion <= 0) {
      throw ArgumentError.value(
        acceptedConsentVersion,
        'acceptedConsentVersion',
        'must be positive',
      );
    }

    // Intentionally do NOT accept a client-provided timestamp for
    // `accepted_consent_at`. This is set server-side via a trigger/migration to
    // avoid relying on device clock.
    final timestamp = DateTime.now().toUtc().toIso8601String();

    final insertPayload = <String, dynamic>{
      'user_id': user.id,
      'accepted_consent_version': acceptedConsentVersion,
      'updated_at': timestamp,
    };

    if (markWelcomeSeen) {
      insertPayload['has_seen_welcome'] = true;
    }

    // Use upsert to handle both insert and update atomically.
    // This avoids race conditions and PGRST116 errors from empty result sets.
    // onConflict: 'user_id' ensures we update if the row exists.
    final result = await client
        .from('profiles')
        .upsert(insertPayload, onConflict: 'user_id')
        .select()
        .maybeSingle();

    // Prevent "silent success" - if upsert returned no row, treat as failure.
    // Caller catches all exceptions and shows warning snackbar.
    if (result == null) {
      throw StateError(kErrProfilesUpsertConsentGateNoRowReturned);
    }
    return result;
  }

  /// Upsert an account-scoped onboarding gate row for the current user in
  /// `public.profiles`.
  ///
  /// MVP policy: only backfill `true` (local true -> remote true). Passing
  /// `false` is treated as a no-op to avoid remotely resetting completion.
  static Future<Map<String, dynamic>?> upsertOnboardingGate({
    required bool hasCompletedOnboarding,
  }) async {
    final user = _ensureAuthenticated();

    if (!hasCompletedOnboarding) {
      return null;
    }

    final timestamp = DateTime.now().toUtc().toIso8601String();
    final insertPayload = <String, dynamic>{
      'user_id': user.id,
      'has_completed_onboarding': true,
      'onboarding_completed_at': timestamp,
      'updated_at': timestamp,
    };
    final updatePayload = Map<String, dynamic>.from(insertPayload)
      ..remove('user_id');

    final updated = await client
        .from('profiles')
        .update(updatePayload)
        .eq('user_id', user.id)
        .select()
        .maybeSingle();

    if (updated == null) {
      throw StateError(
        'Cannot mark onboarding complete: profiles row missing for user.',
      );
    }

    return updated;
  }

  /// Get user profile data
  static Future<Map<String, dynamic>?> getProfile() async {
    final user = _ensureAuthenticated();
    return await client.from('profiles').select().eq('user_id', user.id).maybeSingle();
  }

  static Future<void> _loadEnvironment(String envFile) async {
    try {
      await dotenv.load(fileName: envFile);
    } catch (error, stackTrace) {
      log.e(
        'Failed to load Supabase environment',
        tag: 'supabase_service',
        error: error,
        stack: stackTrace,
      );
      // In tests, don't crash app initialization; proceed with offline UI.
      final isTest = InitModeBridge.resolve() == InitMode.test;
      if (!isTest) {
        throw StateError(
          'Failed to load Supabase environment from "$envFile": $error',
        );
      }
    }
  }

  static _SupabaseCredentials _resolveCredentials(String envFile) {
    // 1) Prefer compile-time --dart-define values (not stored in assets)
    const defineUrl = String.fromEnvironment('SUPABASE_URL');
    const defineAnon = String.fromEnvironment('SUPABASE_ANON_KEY');

    // If dart-define values are available, use them directly (don't access dotenv)
    if (defineUrl.isNotEmpty && defineAnon.isNotEmpty) {
      return _SupabaseCredentials(url: defineUrl, anonKey: defineAnon);
    }

    // 2) Fallback to dotenv (local dev only) with legacy key support
    final envUrl =
        dotenv.maybeGet('SUPABASE_URL') ?? dotenv.maybeGet('SUPA_URL');
    final envAnon = dotenv.maybeGet('SUPABASE_ANON_KEY') ??
        dotenv.maybeGet('SUPA_ANON_KEY');

    final missing = <String>[];
    if (envUrl == null || envUrl.isEmpty) {
      missing.add('SUPABASE_URL/SUPA_URL');
    }
    if (envAnon == null || envAnon.isEmpty) {
      missing.add('SUPABASE_ANON_KEY/SUPA_ANON_KEY');
    }

    if (missing.isNotEmpty) {
      throw StateError('Missing ${missing.join(' and ')} in "$envFile".');
    }

    return _SupabaseCredentials(url: envUrl!, anonKey: envAnon!);
  }

  static Future<void> _initializeSupabase(
    _SupabaseCredentials credentials,
  ) async {
    try {
      await Supabase.initialize(
        url: credentials.url,
        anonKey: credentials.anonKey,
        authOptions: FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          detectSessionInUri: false,
        ),
      );
      log.d(
        'supabase_auth_callback_configured: scheme=${_authDeepLinkConfig.scheme} host=${_authDeepLinkConfig.host}',
        tag: 'supabase_init',
      );
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        StateError('Supabase.initialize failed: $error'),
        stackTrace,
      );
    }
  }

  static User _ensureAuthenticated() {
    if (!_initialized) {
      throw StateError(
        'SupabaseService has not been initialized. Call tryInitialize() before performing authenticated operations.',
      );
    }
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError(
        'SupabaseService requires an authenticated user for this operation.',
      );
    }
    return user;
  }

  static String _formatIsoDate(DateTime date) {
    return date.toUtc().toIso8601String().split('T').first;
  }
}

class _SupabaseCredentials {
  _SupabaseCredentials({required this.url, required this.anonKey});

  final String url;
  final String anonKey;
}

@immutable
class SupabaseAuthDeepLinkConfig {
  const SupabaseAuthDeepLinkConfig._internal(this.uri);

  static final SupabaseAuthDeepLinkConfig fallback =
      SupabaseAuthDeepLinkConfig._internal(
    Uri(scheme: 'luvi', host: 'auth-callback'),
  );

  factory SupabaseAuthDeepLinkConfig.fromUri(Uri uri) {
    // Use uri.scheme.isEmpty instead of !uri.hasScheme because
    // Uri.hasScheme can be true for an explicitly empty scheme string.
    if (uri.scheme.isEmpty || uri.host.isEmpty) {
      throw ArgumentError(
        'Supabase auth callback URI must include a scheme and host.',
      );
    }
    return SupabaseAuthDeepLinkConfig._internal(uri);
  }

  final Uri uri;

  String get host => uri.host;
  String get scheme => uri.scheme;
  String get url => uri.toString();
}

@immutable
class SupabaseValidationConfig {
  const SupabaseValidationConfig({this.minAge = 16, this.maxAge = 120})
      : assert(minAge >= 16, 'minAge must be >= 16.'),
        assert(maxAge <= 120, 'maxAge must be <= 120.'),
        assert(maxAge >= minAge, 'maxAge must be >= minAge.');

  final int minAge;
  final int maxAge;
}

/// Minimal async lock to serialize critical sections without external deps.
class _AsyncLock {
  Future<void> _tail = Future<void>.value();

  Future<T> synchronized<T>(FutureOr<T> Function() action) {
    final next = _tail.then((_) => Future<T>.sync(action));
    // Ensure subsequent callers chain after this action completes (success or error).
    _tail = next.then((_) {}, onError: (_) {});
    return next;
  }
}
