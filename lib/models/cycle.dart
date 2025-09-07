class CycleInfo {
  final DateTime lastPeriod;
  final int cycleLength; // days
  final int periodDuration; // days

  const CycleInfo({
    required this.lastPeriod,
    required this.cycleLength,
    required this.periodDuration,
  });

  String phaseOn(DateTime d) {
    final start = DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day);
    final day = d.difference(start).inDays % cycleLength;
    
    if (day < periodDuration) return "Menstruation";
    if (day < periodDuration + 6) return "Follikel";
    if (day >= cycleLength - 14 && day < cycleLength - 10) return "Ovulationsfenster";
    return "Luteal";
  }
}