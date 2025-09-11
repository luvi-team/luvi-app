abstract class CycleApi {
  Future<Map<String, dynamic>> upsertCycle({
    required DateTime lmpDate,
    required int cycleLengthDays,
    required int periodLengthDays,
  });
}
