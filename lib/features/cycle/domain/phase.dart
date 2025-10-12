import 'package:flutter/material.dart';

import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import 'cycle.dart';

/// Enumerates the distinct phases within the menstrual cycle.
enum Phase { menstruation, follicular, ovulation, luteal, unknown }

extension PhaseLabel on Phase {
  /// Localized label used across dashboard surfaces.
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return localizationKey;
    }
    switch (this) {
      case Phase.menstruation:
        return l10n.cyclePhaseMenstruation;
      case Phase.follicular:
        return l10n.cyclePhaseFollicular;
      case Phase.ovulation:
        return l10n.cyclePhaseOvulation;
      case Phase.luteal:
        return l10n.cyclePhaseLuteal;
      case Phase.unknown:
        return 'Unknown phase';
    }
  }

  /// Stable identifier for fixtures/tests when localization context is unavailable.
  String get localizationKey {
    switch (this) {
      case Phase.menstruation:
        return 'cyclePhaseMenstruation';
      case Phase.follicular:
        return 'cyclePhaseFollicular';
      case Phase.ovulation:
        return 'cyclePhaseOvulation';
      case Phase.luteal:
        return 'cyclePhaseLuteal';
      case Phase.unknown:
        return 'cyclePhaseUnknown';
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
      case Phase.unknown:
        return tokens.follicularDark;
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
  final phase = _legacyLabelToPhase[key];
  if (phase == null) {
    debugPrint(
      'Warning: phaseFromLegacyLabel received unknown legacy label "$legacyLabel" (normalized: "$key")',
    );
    return Phase.unknown;
  }
  return phase;
}

extension CycleInfoPhaseAdapter on CycleInfo {
  /// Returns the Phase enum for a given [date] while preserving legacy logic.
  Phase phaseFor(DateTime date) => phaseFromLegacyLabel(phaseOn(date));
}
