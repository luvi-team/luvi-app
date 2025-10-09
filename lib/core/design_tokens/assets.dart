// ignore_for_file: constant_identifier_names

/// Centralized asset paths for Dashboard (typo-safe, single source of truth).
class Assets {
  static const icons = _Icons();
  static const images = _Images();
}

class _Icons {
  const _Icons();

  final _DashboardStatIcons dashboard = const _DashboardStatIcons();

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

  // Hero/Sync badge (exported from Figma). Note: current asset is a PNG with a
  // filename that includes ".svg"; we treat it as a generic image path and
  // render with Image.asset. When a tight SVG is available, switch to that
  // path and the UI will render via SvgPicture automatically.
  final String syncBadge = 'assets/icons/dashboard/navhero.sync.png';

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

  // Hero background (Luvi‑Sync preview)
  final String heroSync01 = 'assets/images/dashboard/hero_sync_01.png';
}

class _DashboardStatIcons {
  const _DashboardStatIcons();

  final String heart = 'assets/icons/dashboard/heart_fill.svg';
  final String kcal = 'assets/icons/dashboard/kcal.svg';
  final String run = 'assets/icons/dashboard/run.svg';
}
