import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if user is authenticated
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Initialize Supabase from environment variables
  static Future<void> initializeFromEnv() async {
    // Prefer SUPABASE_*; gracefully fallback to legacy SUPA_*
    final url = dotenv.env['SUPABASE_URL'] ?? dotenv.env['SUPA_URL'];
    final anon = dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPA_ANON_KEY'];
    if ((url == null || url.isEmpty) || (anon == null || anon.isEmpty)) {
      throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file');
    }
    await Supabase.initialize(url: url, anonKey: anon);
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
