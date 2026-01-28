// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// Centralized asset paths for the app (typo-safe, single source of truth).
// Note: welcome_01.png removed – Screen 1 now uses video
const String _kWelcomeHero02 = 'assets/images/welcome/welcome_02.png';
const String _kWelcomeWave = 'assets/images/welcome/welcome_wave.svg';
const String _kWelcomeVideo01 = 'assets/videos/welcome/welcome_01.mp4';
const String _kWelcomeVideo03 = 'assets/videos/welcome/welcome_03.mp4';
const String _kWelcomeFallback01 = 'assets/images/welcome/welcome_01_fallback.png';
const String _kWelcomeFallback03 = 'assets/images/welcome/welcome_03_fallback.png';
const String _kSplashVideo = 'assets/videos/splash/splash_screen.mp4';
const String _kSplashFallback = 'assets/images/splash/splash_fallback.png';

class Assets {
  static const icons = _Icons();
  static const images = _Images();
  static const videos = _Videos();
  static const animations = _Animations();
  static const consentImages = _ConsentImages();

  /// Default error builder for dashboard `Image.asset` widgets.
  /// Renders a neutral placeholder so layout stays stable when assets fail.
  static ImageErrorWidgetBuilder get defaultImageErrorBuilder =>
      (BuildContext context, Object error, StackTrace? stackTrace) {
        final placeholderColor = Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
        return ColoredBox(color: placeholderColor);
      };
}

class _Icons {
  const _Icons();

  final _DashboardStatIcons dashboard = const _DashboardStatIcons();
  final _OnboardingIcons onboarding = const _OnboardingIcons();

  // Auth/Social icons
  final String googleG = 'assets/icons/google_g.svg';
  final String authBackChevron = 'assets/icons/auth/auth_back_chevron.svg';

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

  // Auth images (Auth Rebrand v3)
  final _AuthImages auth = const _AuthImages();

  final String recoBeinePo = 'assets/images/dashboard/reco.beine_po.png';
  final String recoRueckenSchulter =
      'assets/images/dashboard/reco.ruecken_schulter.png';
  final String recoGanzkoerper = 'assets/images/dashboard/reco.ganzkoerper.png';
  final String recoErnaehrungstagebuch =
      'assets/images/dashboard/reco.ernahrungstagebuch.png';
  final String recoHautpflege = 'assets/images/dashboard/reco.hautpflege.png';

  // Hero background (Luvi‑Sync preview)
  final String heroSync01 = 'assets/images/dashboard/hero_sync_01.png';
  // Nutrition & Regeneration Cards (Phase 10)
  final String strawberry = 'assets/images/dashboard/strawberry.png';
  final String roteruebe = 'assets/images/dashboard/roteruebe.png';
  final String meditation = 'assets/images/dashboard/meditation.png';
  final String stretching = 'assets/images/dashboard/stretching.png';

  // Onboarding Success Screen content preview cards
  final String onboardingContentCard1 =
      'assets/images/onboarding/content_card_1.png';
  final String onboardingContentCard2 =
      'assets/images/onboarding/content_card_2.png';
  final String onboardingContentCard3 =
      'assets/images/onboarding/content_card_3.png';

  // Welcome hero assets (images only; videos in _Videos)
  // Note: W1 + W3 use video; W2 uses static image
  final String welcomeHero02 = _kWelcomeHero02;
  final String welcomeWave = _kWelcomeWave;

  /// Fallback poster for Welcome Screen 1 video (A11y + error state)
  final String welcomeFallback01 = _kWelcomeFallback01;

  /// Fallback poster for Welcome Screen 3 video (A11y + error state)
  final String welcomeFallback03 = _kWelcomeFallback03;

  // Consent Screen Assets - use Assets.consentImages for shield assets

  /// Fallback poster for Splash Screen video (A11y + error state + reduce-motion)
  final String splashFallback = _kSplashFallback;
}

class _Videos {
  const _Videos();

  /// Welcome Screen 1 – autoplay loop video
  final String welcomeVideo01 = _kWelcomeVideo01;

  /// Welcome Screen 3 – autoplay loop video
  final String welcomeVideo03 = _kWelcomeVideo03;

  /// Splash screen video – autoplay once, no loop
  final String splashScreen = _kSplashVideo;
}

class _Animations {
  const _Animations();

  /// Onboarding Intro animation (Lottie JSON, 600f @100fps, ~6s).
  /// Shows Luvienne portrait with motion/shapes intro.
  final String onboardingIntro =
      'assets/animations/Onboarding/onboarding_01_intro.json';

  /// Onboarding Rainbow animation (Lottie JSON, 100f @100fps, ~1s).
  /// Shows rainbow effect after intro before navigation.
  final String onboardingRainbow =
      'assets/animations/Onboarding/onboarding_01_rainbow.json';

  /// Trophy + celebration combined animation (Lottie JSON, 100f @50fps, 2s).
  final String onboardingSuccessCelebration =
      'assets/animations/onboarding_success_celebration.json';

  /// Splash screen animation for app launch (Lottie JSON, 250f @100fps, 2.5s).
  ///
  /// @deprecated Use [Assets.videos.splashScreen] instead.
  /// This Lottie animation is replaced by MP4 video for rebrand.
  /// Will be removed in a future release.
  @Deprecated('Use Assets.videos.splashScreen instead')
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

class _OnboardingIcons {
  const _OnboardingIcons();

  final String muscle = 'assets/icons/onboarding/ic_muscle.svg';
  final String energy = 'assets/icons/onboarding/ic_energy.svg';
  final String sleep = 'assets/icons/onboarding/ic_sleep.svg';
  final String calendar = 'assets/icons/onboarding/ic_calendar.svg';
  final String run = 'assets/icons/onboarding/ic_run.svg';
  final String happy = 'assets/icons/onboarding/ic_happy.svg';
}

class _ConsentImages {
  const _ConsentImages();

  final String consentShield = 'assets/images/consent/consent_shield.png';
}

class _AuthImages {
  const _AuthImages();

  final String heroAuthEntry = 'assets/images/auth/hero_auth_entry.png';
  final String logoLuvi = 'assets/images/auth/logo_luvi.svg';
}
