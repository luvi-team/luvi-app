import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'cycle.dart';

/// Enumerates the distinct phases within the menstrual cycle.
enum Phase {
  menstruation,
  follicular,
  ovulation,
  luteal,
}

extension PhaseLabel on Phase {
  /// Localized label used across dashboard surfaces.
  String get label {
    switch (this) {
      case Phase.menstruation:
        return 'Menstruation';
      case Phase.follicular:
        return 'Follikelphase';
      case Phase.ovulation:
        return 'Ovulationsfenster';
      case Phase.luteal:
        return 'Lutealphase';
    }
  }
}

extension PhaseColorTokens on Phase {
  /// Maps the phase to the corresponding cycle color token.
  Color mapToColorTokens(CyclePhaseTokens tokens) {
    switch (this) {
      case Phase.menstruation:
        return tokens.menstruation;
      case Phase.follicular:
        return tokens.follicularDark;
      case Phase.ovulation:
        return tokens.ovulation;
      case Phase.luteal:
        return tokens.luteal;
    }
  }
}

const Map<String, Phase> _legacyLabelToPhase = <String, Phase>{
  'menstruation': Phase.menstruation,
  'follikel': Phase.follicular,
  'ovulationsfenster': Phase.ovulation,
  'luteal': Phase.luteal,
};

/// Maps the existing CycleInfo legacy labels to the new [Phase] enum.
Phase phaseFromLegacyLabel(String legacyLabel) {
  final key = legacyLabel.trim().toLowerCase();
  return _legacyLabelToPhase[key] ?? Phase.follicular;
}

extension CycleInfoPhaseAdapter on CycleInfo {
  /// Returns the Phase enum for a given [date] while preserving legacy logic.
  Phase phaseFor(DateTime date) => phaseFromLegacyLabel(phaseOn(date));
}
