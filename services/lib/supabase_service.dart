import 'dart:async';

import 'package:flutter/material.dart';
import 'logger.dart';
import 'init_mode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _initialized = false;
  // A single gate to ensure only the first caller performs initialization and
  // others await the same Future. This avoids non-atomic check-then-assign races.
  static Completer<void>? _initCompleter;
  static Object? _initializationError;
  static StackTrace? _initializationStackTrace;
  static SupabaseValidationConfig _validationConfig =
      const SupabaseValidationConfig();

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

    // Fast-path if an initialization is already in-flight; return the shared Future.
    final existingGate = _initCompleter;
    if (existingGate != null) return existingGate.future;

    // Create the gate synchronously to avoid races; only the first caller gets here.
    final gate = _initCompleter = Completer<void>();

    // Kick off initialization and complete the shared gate accordingly.
    _performInitializeAndCache(envFile).then((_) {
      if (!gate.isCompleted) gate.complete();
    }).catchError((Object error, StackTrace stack) {
      // Allow subsequent retries after a failure by clearing the gate.
      _initCompleter = null;
      if (!gate.isCompleted) gate.completeError(error, stack);
    });

    return gate.future;
  }

  static void configure({SupabaseValidationConfig? validationConfig}) {
    if (validationConfig != null) {
      _validationConfig = validationConfig;
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
    try {
      await _performInitialize(envFile: envFile);
      // In tests, treat initialization as skipped/offline.
      final isTest = InitModeBridge.resolve() == InitMode.test;
      _initialized = !isTest;
      _initializationError = null;
      _initializationStackTrace = null;
    } catch (error, stackTrace) {
      _initialized = false;
      _initializationError = error;
      _initializationStackTrace = stackTrace;
      // Do not keep a failed future; allow retry via clearing the gate in tryInitialize's catch handler
      final isTest = InitModeBridge.resolve() == InitMode.test;
      if (!isTest) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'supabase_service',
            context: ErrorDescription('initializing Supabase'),
          ),
        );
      }
      if (!isTest) {
        rethrow;
      }
    }
  }

  static Future<void> _performInitialize({required String envFile}) async {
    // In tests, skip environment loading and network initialization entirely.
    if (InitModeBridge.resolve() == InitMode.test) {
      return;
    }
    await _loadEnvironment(envFile);
    final credentials = _resolveCredentials(envFile);
    await _initializeSupabase(credentials);
  }

  /// Check if user is authenticated
  static bool get isAuthenticated =>
      _initialized && Supabase.instance.client.auth.currentUser != null;

  /// Get current user
  static User? get currentUser =>
      _initialized ? Supabase.instance.client.auth.currentUser : null;

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
    final normalizedLastPeriod = lastPeriod.toUtc();
    final nowUtc = DateTime.now().toUtc();
    // Compare dates only to avoid clock skew issues with "today"
    final lastPeriodDate = DateTime.utc(
      normalizedLastPeriod.year,
      normalizedLastPeriod.month,
      normalizedLastPeriod.day,
    );
    final nowDate = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
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
      'last_period': _formatIsoDate(normalizedLastPeriod),
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
      log.e('Failed to load Supabase environment', tag: 'supabase_service',
          error: error, stack: stackTrace);
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
    final url = dotenv.maybeGet('SUPABASE_URL') ?? dotenv.maybeGet('SUPA_URL');
    final anon =
        dotenv.maybeGet('SUPABASE_ANON_KEY') ??
        dotenv.maybeGet('SUPA_ANON_KEY');

    final missing = <String>[];
    if (url == null || url.isEmpty) {
      missing.add('SUPABASE_URL/SUPA_URL');
    }
    if (anon == null || anon.isEmpty) {
      missing.add('SUPABASE_ANON_KEY/SUPA_ANON_KEY');
    }

    if (missing.isNotEmpty) {
      throw StateError('Missing ${missing.join(' and ')} in "$envFile".');
    }

    return _SupabaseCredentials(url: url!, anonKey: anon!);
  }

  static Future<void> _initializeSupabase(
    _SupabaseCredentials credentials,
  ) async {
    try {
      await Supabase.initialize(
        url: credentials.url,
        anonKey: credentials.anonKey,
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
class SupabaseValidationConfig {
  const SupabaseValidationConfig({this.minAge = 10, this.maxAge = 100})
    : assert(minAge > 0, 'minAge must be positive.'),
      assert(maxAge >= minAge, 'maxAge must be >= minAge.');

  final int minAge;
  final int maxAge;
}
