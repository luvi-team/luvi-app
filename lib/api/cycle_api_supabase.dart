import 'package:supabase_flutter/supabase_flutter.dart';
import 'cycle_api.dart';

class CycleApiSupabase implements CycleApi {
  final SupabaseClient _client;
  CycleApiSupabase([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Map<String, dynamic>> upsertCycle({
    required DateTime lmpDate,
    required int cycleLengthDays,
    required int periodLengthDays,
  }) async {
    try {
      // Nur YYYY-MM-DD senden (DATE)
      final String ymd = DateTime(lmpDate.year, lmpDate.month, lmpDate.day)
          .toIso8601String()
          .substring(0, 10);

      final payload = <String, dynamic>{
        'last_period': ymd,
        'cycle_length': cycleLengthDays,
        'period_duration': periodLengthDays,
      };

      final row = await _client
          .from('cycle_data')
          .upsert(payload, onConflict: 'user_id')
          .select(
            'id, user_id, last_period, cycle_length, period_duration, created_at',
          )
          .single();

      return row;
    } on PostgrestException catch (e) {
      throw Exception('cycle_data upsert failed: ${e.message}');
    }
  }
}