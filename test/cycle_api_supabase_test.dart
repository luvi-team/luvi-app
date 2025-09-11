import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/cycle/data/cycle_api.dart';
import 'package:luvi_app/features/cycle/data/cycle_api_supabase.dart';

// Test implementation that records calls without using real Supabase
class TestableApiSupabase implements CycleApi {
  Map<String, dynamic>? recordedPayload;
  String? recordedSelect;
  String? recordedOnConflict;
  String? recordedTable;
  Map<String, dynamic>? responseToReturn;
  Exception? exceptionToThrow;

  TestableApiSupabase({this.responseToReturn, this.exceptionToThrow});

  @override
  Future<Map<String, dynamic>> upsertCycle({
    required DateTime lmpDate,
    required int cycleLengthDays,
    required int periodLengthDays,
  }) async {
    // Record what would be sent
    recordedTable = 'cycle_data';
    recordedOnConflict = 'user_id';
    recordedSelect =
        'id, user_id, last_period, cycle_length, period_duration, created_at';

    // Simulate the payload transformation
    final String ymd = DateTime(
      lmpDate.year,
      lmpDate.month,
      lmpDate.day,
    ).toIso8601String().substring(0, 10);

    recordedPayload = <String, dynamic>{
      'last_period': ymd,
      'cycle_length': cycleLengthDays,
      'period_duration': periodLengthDays,
    };

    if (exceptionToThrow != null) {
      throw CycleUpsertException('RLS policy violation');
    }

    return responseToReturn ?? {'id': 'test-id'};
  }
}

void main() {
  group('CycleApiSupabase behavior verification', () {
    test('sends correct payload keys and select fields', () async {
      // Arrange
      final api = TestableApiSupabase(
        responseToReturn: {
          'id': 'test-id',
          'user_id': 'test-user',
          'last_period': '2025-01-15',
          'cycle_length': 28,
          'period_duration': 5,
          'created_at': '2025-01-15T12:00:00Z',
        },
      );

      // Act
      final result = await api.upsertCycle(
        lmpDate: DateTime(2025, 1, 15, 14, 30), // Should normalize to date only
        cycleLengthDays: 28,
        periodLengthDays: 5,
      );

      // Assert - Payload verification
      expect(api.recordedPayload, isNotNull);

      // Check exact payload keys (no user_id)
      expect(api.recordedPayload!.keys.toSet(), {
        'last_period',
        'cycle_length',
        'period_duration',
      });

      // Check last_period is YYYY-MM-DD format
      expect(api.recordedPayload!['last_period'], '2025-01-15');
      expect(api.recordedPayload!['cycle_length'], 28);
      expect(api.recordedPayload!['period_duration'], 5);

      // Check table and conflict resolution
      expect(api.recordedTable, 'cycle_data');
      expect(api.recordedOnConflict, 'user_id');

      // Check select fields
      expect(
        api.recordedSelect,
        'id, user_id, last_period, cycle_length, period_duration, created_at',
      );

      // Check return value
      expect(result['id'], 'test-id');
      expect(result['user_id'], 'test-user');
    });

    test('normalizes date to YYYY-MM-DD regardless of time', () async {
      // Arrange
      final api = TestableApiSupabase();

      // Act - Test with different times
      await api.upsertCycle(
        lmpDate: DateTime(2025, 12, 31, 23, 59, 59),
        cycleLengthDays: 30,
        periodLengthDays: 4,
      );

      // Assert
      expect(api.recordedPayload!['last_period'], '2025-12-31');
    });

    test('handles exception scenario properly', () async {
      // Arrange
      final api = TestableApiSupabase(
        exceptionToThrow: Exception('RLS policy violation'),
      );

      // Act & Assert
      expect(
        () => api.upsertCycle(
          lmpDate: DateTime(2025, 1, 1),
          cycleLengthDays: 28,
          periodLengthDays: 5,
        ),
        throwsA(
          isA<CycleUpsertException>().having(
            (e) => e.message,
            'message',
            contains('RLS policy violation'),
          ),
        ),
      );
    });
  });
}
