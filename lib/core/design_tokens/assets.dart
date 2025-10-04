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

  // Bottom nav
  final String navFlower = 'assets/icons/dashboard/icon.nav.flower.svg';
  final String navSocial = 'assets/icons/dashboard/icon.nav.social.svg';
  final String navAccount = 'assets/icons/dashboard/icon.nav.account.svg';

  // Optional/extras
  final String navChart = 'assets/icons/dashboard/icon.nav.chart.svg';
  final String cycleOutline = 'assets/icons/dashboard/icon.nav.cycle-outline.svg';
}

class _Images {
  const _Images();

  final String recoBeinePo = 'assets/images/dashboard/reco.beine_po.png';
  final String recoRueckenSchulter = 'assets/images/dashboard/reco.ruecken_schulter.png';
  final String recoGanzkoerper = 'assets/images/dashboard/reco.ganzkoerper.png';
}
