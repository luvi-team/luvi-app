// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// Centralized asset paths for Dashboard (typo-safe, single source of truth).
const String _kWelcomeHero01 = 'assets/images/welcome/welcome_01.png';
const String _kWelcomeHero02 = 'assets/images/welcome/welcome_02.png';
const String _kWelcomeHero03 = 'assets/images/welcome/welcome_03.png';
const String _kWelcomeWave = 'assets/images/welcome/welcome_wave.svg';

class Assets {
  static const icons = _Icons();
  static const images = _Images();
  static const animations = _Animations();

  // Legacy constants kept for migration from `Assets.<name>`.
  // Deprecated: prefer `Assets.images.<name>` in new code. Planned removal in
  // v3.6 (2026-03); when updating affected widgets, replace
  // `Assets.<name>` → `Assets.images.<name>` and drop the legacy import.
  @Deprecated(
    'Use Assets.images.welcomeWave instead; update call sites to Assets.images.welcomeWave. Removal in v3.6 (2026-03).',
  )
  static const String welcomeWave = _kWelcomeWave;
  @Deprecated(
    'Use Assets.images.welcomeHero01 instead; update call sites to Assets.images.welcomeHero01. Removal in v3.6 (2026-03).',
  )
  static const String welcomeHero01 = _kWelcomeHero01;
  @Deprecated(
    'Use Assets.images.welcomeHero02 instead; update call sites to Assets.images.welcomeHero02. Removal in v3.6 (2026-03).',
  )
  static const String welcomeHero02 = _kWelcomeHero02;
  @Deprecated(
    'Use Assets.images.welcomeHero03 instead; update call sites to Assets.images.welcomeHero03. Removal in v3.6 (2026-03).',
  )
  static const String welcomeHero03 = _kWelcomeHero03;

  /// Default error builder for dashboard `Image.asset` widgets.
  /// Renders a neutral placeholder so layout stays stable when assets fail.
  static ImageErrorWidgetBuilder get defaultImageErrorBuilder =>
      (BuildContext context, Object error, StackTrace? stackTrace) {
        final placeholderColor = Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3);
        return ColoredBox(color: placeholderColor);
      };
}

class _Icons {
  const _Icons();

  final _DashboardStatIcons dashboard = const _DashboardStatIcons();

  // Top bar
  final String search = 'assets/icons/dashboard/icon.search.svg';
  final String notifications = 'assets/icons/dashboard/icon.notifications.svg';
  final String play = 'assets/icons/dashboard/icon.play.svg';

  // Categories
  final String catTraining =
      'assets/icons/dashboard/icon.category.training.svg';
  final String catNutrition =
      'assets/icons/dashboard/icon.category.nutrition.svg';
  final String catRegeneration =
      'assets/icons/dashboard/icon.category.regeneration.svg';
  final String catMindfulness =
      'assets/icons/dashboard/icon.category.mindfulness.svg';

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
  final String cycleOutline =
      'assets/icons/dashboard/icon.nav.cycle-outline.svg';
}

class _Images {
  const _Images();

  final String recoBeinePo = 'assets/images/dashboard/reco.beine_po.png';
  final String recoRueckenSchulter =
      'assets/images/dashboard/reco.ruecken_schulter.png';
  final String recoGanzkoerper = 'assets/images/dashboard/reco.ganzkoerper.png';
  final String recoErnaehrungstagebuch =
      'assets/images/dashboard/reco.ernahrungstagebuch.png';
  final String recoHautpflege =
      'assets/images/dashboard/reco.hautpflege.png';

  // Hero background (Luvi‑Sync preview)
  final String heroSync01 = 'assets/images/dashboard/hero_sync_01.png';
  // Nutrition & Regeneration Cards (Phase 10)
  final String strawberry = 'assets/images/dashboard/strawberry.png';
  final String roteruebe = 'assets/images/dashboard/roteruebe.png';
  final String meditation = 'assets/images/dashboard/meditation.png';
  final String stretching = 'assets/images/dashboard/stretching.png';

  // Onboarding Success Screen trophy (A11y fallback when reduceMotion is true)
  // PNG format keeps static illustration crisp when animation is disabled
  final String onboardingSuccessTrophy =
      'assets/images/onboarding/onboarding_success_trophy.png';

  // Welcome/Consent hero assets
  final String welcomeHero01 = _kWelcomeHero01;
  final String welcomeHero02 = _kWelcomeHero02;
  final String welcomeHero03 = _kWelcomeHero03;
  final String welcomeWave = _kWelcomeWave;
}

class _Animations {
  const _Animations();

  /// Trophy + celebration combined animation (Lottie JSON, 100f @50fps, 2s).
  final String onboardingSuccessCelebration =
      'assets/animations/onboarding_success_celebration.json';

  /// Splash screen animation for app launch (Lottie JSON, 250f @100fps, 2.5s).
  final String splashScreen = 'assets/animations/splash_screen.json';
}

class _DashboardStatIcons {
  const _DashboardStatIcons();

  final String heart = 'assets/icons/dashboard/heart_fill.svg';
  final String kcal = 'assets/icons/dashboard/kcal.svg';
  final String run = 'assets/icons/dashboard/run.svg';
  final String time = 'assets/icons/dashboard/time.svg';
  final String heartRateGlyph = 'assets/icons/dashboard/Heart Rate Icon.svg';
}
