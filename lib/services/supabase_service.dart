import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('SupabaseService has not been initialized');
    }
    return Supabase.instance.client;
  }

  /// Attempt to load environment configuration and initialize Supabase.
  static Future<void> tryInitialize({
    String envFile = '.env.development',
  }) async {
    if (_initialized) return;
    try {
      await dotenv.load(fileName: envFile);
      final url =
          dotenv.maybeGet('SUPABASE_URL') ?? dotenv.maybeGet('SUPA_URL');
      final anon =
          dotenv.maybeGet('SUPABASE_ANON_KEY') ??
          dotenv.maybeGet('SUPA_ANON_KEY');
      if (url != null && url.isNotEmpty && anon != null && anon.isNotEmpty) {
        await Supabase.initialize(url: url, anonKey: anon);
        _initialized = true;
      } else {
        debugPrint('Warning: SUPABASE_URL/ANON_KEY missing in $envFile');
        _initialized = false;
      }
    } catch (e) {
      debugPrint(
        'Warning: Could not load environment or initialize Supabase: $e',
      );
      _initialized = false;
    }
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
      throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file');
    }
  }

  /// Upsert email preferences for the current user
  static Future<Map<String, dynamic>?> upsertEmailPreferences({
    bool? newsletter,
  }) async {
    if (!isAuthenticated) throw Exception('User must be authenticated');
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
    if (!isAuthenticated) throw Exception('User must be authenticated');
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
    if (!isAuthenticated) throw Exception('User must be authenticated');
    final payload = <String, dynamic>{
      'user_id': currentUser!.id,
      'cycle_length': cycleLength,
      'period_duration': periodDuration,
      'last_period': lastPeriod.toIso8601String().split('T').first,
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
    if (!isAuthenticated) throw Exception('User must be authenticated');
    final userId = currentUser!.id;
    return await client
        .from('cycle_data')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }
}
