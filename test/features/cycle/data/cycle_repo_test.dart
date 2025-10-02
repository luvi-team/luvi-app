import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/cycle/data/cycle_api.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';
import 'package:luvi_app/features/cycle/data/cycle_repo.dart';

class FakeCycleApi implements CycleApi {
  int callCount = 0;
  Map<String, dynamic>? lastPayload;

  @override
  Future<Map<String, dynamic>> upsertCycle({
    required DateTime lmpDate,
    required int cycleLengthDays,
    required int periodLengthDays,
  }) async {
    callCount++;
    lastPayload = {
      'lmpDate': lmpDate,
      'cycleLengthDays': cycleLengthDays,
      'periodLengthDays': periodLengthDays,
    };
    return {'id': 'fake-id', 'created_at': '2025-01-01T00:00:00Z'};
  }
}

void main() {
  group('CycleRepo consent gate', () {
    test('Case 1: Consent false → api not called, result null', () async {
      final fakeApi = FakeCycleApi();
      final repo = CycleRepo(api: fakeApi, hasConsent: () async => false);

      final info = CycleInfo(
        lastPeriod: DateTime(2025, 1, 1),
        cycleLength: 28,
        periodDuration: 5,
      );

      final result = await repo.saveIfConsented(info);

      expect(fakeApi.callCount, 0);
      expect(result, isNull);
    });

    test(
      'Case 2: Consent true → api called once, fields mapped, result fake-id',
      () async {
        final fakeApi = FakeCycleApi();
        final repo = CycleRepo(api: fakeApi, hasConsent: () async => true);

        final info = CycleInfo(
          lastPeriod: DateTime(2025, 1, 1),
          cycleLength: 28,
          periodDuration: 5,
        );

        final result = await repo.saveIfConsented(info);

        expect(fakeApi.callCount, 1);
        expect(fakeApi.lastPayload, isNotNull);
        expect(fakeApi.lastPayload!['lmpDate'], DateTime(2025, 1, 1));
        expect(fakeApi.lastPayload!['cycleLengthDays'], 28);
        expect(fakeApi.lastPayload!['periodLengthDays'], 5);
        expect(result, 'fake-id');
      },
    );
  });
}
