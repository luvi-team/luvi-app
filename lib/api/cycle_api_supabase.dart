import 'package:supabase_flutter/supabase_flutter.dart';
import 'cycle_api.dart';

class CycleApiSupabase implements CycleApi {
  @override
  Future<Map<String, dynamic>> upsertCycle({
    required DateTime lmpDate,
    required int cycleLengthDays,
    required int periodLengthDays,
  }) async {
    try {
      final row = await Supabase.instance.client
          .from('cycle_data')
          .upsert(
            {
              'lmp_date': lmpDate.toIso8601String().substring(0, 10),
              'cycle_length_days': cycleLengthDays,
              'period_length_days': periodLengthDays,
            },
            onConflict: 'user_id',
          )
          .select('id, created_at')
          .single();
      return row;
    } catch (e) {
      throw Exception('Failed to upsert cycle data: $e');
    }
  }
}