import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'init_exception.dart';
import 'init_mode.dart';
import 'logger.dart';

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
        log.w(
          'authConfig ignored: SupabaseService already initialized',
          tag: 'supabase_service',
        );
      } else {
        _authDeepLinkConfig = authConfig;
      }
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
    if (periodDuration <= 0) {
      throw ArgumentError.value(
        periodDuration,
        'periodDuration',
        'must be positive',
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
  const SupabaseValidationConfig({this.minAge = 13, this.maxAge = 100})
      : assert(minAge >= 13, 'minAge must be >= 13.'),
        assert(maxAge <= 150, 'maxAge must be <= 150 (sanity check).'),
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
