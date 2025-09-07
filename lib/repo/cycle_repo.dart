import '../api/cycle_api.dart';
import '../models/cycle.dart';

typedef ConsentCheck = Future<bool> Function();

class CycleRepo {
  final CycleApi api;
  final ConsentCheck hasConsent;

  CycleRepo({required this.api, required this.hasConsent});

  Future<String?> saveIfConsented(CycleInfo info) async {
    if (!await hasConsent()) return null; // Gate: keine Persistenz
    final row = await api.upsertCycle(
      lmpDate: info.lastPeriod,
      cycleLengthDays: info.cycleLength,
      periodLengthDays: info.periodDuration,
    );
    return row['id'] as String?;
  }
}