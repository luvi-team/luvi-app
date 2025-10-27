import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _initialized = false;
  static Future<void>? _initFuture;
  static Object? _initializationError;
  static StackTrace? _initializationStackTrace;

  static bool get isInitialized => _initialized;
  static Object? get lastInitializationError => _initializationError;
  static StackTrace? get lastInitializationStackTrace =>
      _initializationStackTrace;

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('SupabaseService has not been initialized');
    }
    return Supabase.instance.client;
  }

  /// Attempt to load environment configuration and initialize Supabase.
  static Future<void> tryInitialize({String envFile = '.env.development'}) {
    if (_initialized) return Future.value();
    final existing = _initFuture;
    if (existing != null) return existing;
    _initFuture = _performInitializeAndCache(envFile);
    return _initFuture!;
  }

  static Future<void> _performInitializeAndCache(String envFile) async {
    try {
      await _performInitialize(envFile: envFile);
      _initialized = true;
      _initializationError = null;
      _initializationStackTrace = null;
    } catch (error, stackTrace) {
      _initialized = false;
      _initializationError = error;
      _initializationStackTrace = stackTrace;
      _initFuture = null;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'supabase_service',
          context: ErrorDescription('initializing Supabase'),
        ),
      );
      rethrow;
    }
  }

  static Future<void> _performInitialize({
    required String envFile,
  }) async {
    await _loadEnvironment(envFile);
    final credentials = _resolveCredentials(envFile);
    await _initializeSupabase(credentials);
  }

  /// Check if user is authenticated
  static bool get isAuthenticated =>
      _initialized && client.auth.currentUser != null;

  /// Get current user
  static User? get currentUser => _initialized ? client.auth.currentUser : null;

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
    _ensureAuthenticated();
    final data = <String, dynamic>{'user_id': currentUser!.id};
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
    _ensureAuthenticated();
    final userId = currentUser!.id;
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
    _ensureAuthenticated();
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
    if (age < 10 || age > 100) {
      throw ArgumentError.value(age, 'age', 'must be between 10 and 100');
    }
    final normalizedLastPeriod = lastPeriod.toUtc();
    final nowUtc = DateTime.now().toUtc();
    if (normalizedLastPeriod.isAfter(nowUtc)) {
      throw ArgumentError.value(
        lastPeriod,
        'lastPeriod',
        'cannot be in the future',
      );
    }
    final payload = <String, dynamic>{
      'user_id': currentUser!.id,
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
    _ensureAuthenticated();
    final userId = currentUser!.id;
    return await client
        .from('cycle_data')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  static Future<void> _loadEnvironment(String envFile) async {
    try {
      await dotenv.load(fileName: envFile);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        StateError(
          'Failed to load Supabase environment from "$envFile": $error',
        ),
        stackTrace,
      );
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

  static void _ensureAuthenticated() {
    if (!isAuthenticated) {
      throw StateError('User must be authenticated');
    }
  }

  static String _formatIsoDate(DateTime date) {
    final normalized = date.toUtc();
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _SupabaseCredentials {
  _SupabaseCredentials({required this.url, required this.anonKey});

  final String url;
  final String anonKey;
}
