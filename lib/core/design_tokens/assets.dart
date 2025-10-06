// ignore_for_file: constant_identifier_names

/// Centralized asset paths for Dashboard (typo-safe, single source of truth).
class Assets {
  static const icons = _Icons();
  static const images = _Images();
}

class _Icons {
  const _Icons();

  // Top bar
  final String search = 'assets/icons/dashboard/icon.search.svg';
  final String notifications = 'assets/icons/dashboard/icon.notifications.svg';
  final String play = 'assets/icons/dashboard/icon.play.svg';

  // Categories
  final String catTraining = 'assets/icons/dashboard/icon.category.training.svg';
  final String catNutrition = 'assets/icons/dashboard/icon.category.nutrition.svg';
  final String catRegeneration = 'assets/icons/dashboard/icon.category.regeneration.svg';
  final String catMindfulness = 'assets/icons/dashboard/icon.category.mindfulness.svg';

  // Bottom nav (5-tab design)
  final String navToday = 'assets/icons/dashboard/nav.today.svg';
  final String navCycle = 'assets/icons/dashboard/nav.cycle.svg';
  final String navSync = 'assets/icons/dashboard/nav.sync.svg';
  final String navPulse = 'assets/icons/dashboard/nav.pulse.svg';
  final String navProfile = 'assets/icons/dashboard/nav.profile.svg';

  // Hero
  final String heroTraining = 'assets/icons/dashboard/icon.hero.training.svg';

  // Optional/extras
  final String cycleOutline = 'assets/icons/dashboard/icon.nav.cycle-outline.svg';
}

class _Images {
  const _Images();

  final String recoBeinePo = 'assets/images/dashboard/reco.beine_po.png';
  final String recoRueckenSchulter = 'assets/images/dashboard/reco.ruecken_schulter.png';
  final String recoGanzkoerper = 'assets/images/dashboard/reco.ganzkoerper.png';
}
