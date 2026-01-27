/// Onboarding flow routes (O1-O8) with consent guard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_02.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_03_fitness.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_04_goals.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_cycle_intro.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/router/route_builders/route_guards.dart';

/// Builds onboarding routes (O1-O8) with consent guard.
List<RouteBase> buildOnboardingRoutes() {
  return [
    GoRoute(
      path: RoutePaths.onboarding01,
      name: 'onboarding_01',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) => const Onboarding01Screen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding02,
      name: 'onboarding_02',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) => const Onboarding02Screen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding03Fitness,
      name: 'onboarding_03_fitness',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) => const Onboarding03FitnessScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding04Goals,
      name: 'onboarding_04_goals',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) => const Onboarding04GoalsScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding05Interests,
      name: 'onboarding_05_interests',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) => const Onboarding05InterestsScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding06CycleIntro,
      name: 'onboarding_06_cycle_intro',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) => const Onboarding06CycleIntroScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding06Period,
      name: Onboarding06PeriodScreen.navName,
      redirect: onboardingConsentGuard,
      builder: (ctx, st) => const Onboarding06PeriodScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding07Duration,
      name: 'onboarding_07_duration',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) {
        final periodStart = st.extra is DateTime ? st.extra as DateTime : null;
        return Onboarding07DurationScreen(periodStartDate: periodStart);
      },
    ),
    GoRoute(
      path: RoutePaths.onboardingSuccess,
      name: 'onboarding_success',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) => const OnboardingSuccessScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboardingDone,
      name: 'onboarding_done',
      redirect: onboardingConsentGuard,
      builder: (ctx, st) =>
          Center(child: Text(AppLocalizations.of(ctx)!.onboardingComplete)),
    ),
  ];
}
