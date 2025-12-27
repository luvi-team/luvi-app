/// Router composition layer - allowed to import features.
///
/// This file lives outside lib/core/ to maintain the guardrail:
/// "lib/core/** must never import lib/features/**"
///
/// Entry points (main.dart, main_auth_entry.dart) use [createRouter] or
/// [routerProvider] to obtain a configured GoRouter instance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core imports (always allowed)
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/navigation/routes.dart' as routes;
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';

// Feature Screen imports (allowed here, NOT in core)
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_blocking_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_intro_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_02_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_03_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_04_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_05_screen.dart';
import 'package:luvi_app/features/cycle/screens/cycle_overview_stub.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/dashboard/screens/trainings_overview_stub.dart';
import 'package:luvi_app/features/dashboard/screens/workout_detail_stub.dart';
import 'package:luvi_app/features/legal/screens/legal_viewer.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_02.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_03_fitness.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_04_goals.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_cycle_intro.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/profile/screens/profile_stub_screen.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';

/// Creates a GoRouter instance with all app routes.
///
/// [ref] is required for Riverpod provider access in route guards.
/// [enableRedirects] controls whether global auth redirects are active.
///   Set to false for preview/dev entry points.
/// [initialLocation] overrides the starting route (defaults to splash).
/// [refreshListenable] optional listenable for router refresh (auth changes).
/// [observers] optional list of navigator observers.
GoRouter createRouter(
  WidgetRef ref, {
  bool enableRedirects = true,
  String? initialLocation,
  Listenable? refreshListenable,
  List<NavigatorObserver>? observers,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? RoutePaths.splash,
    redirect: enableRedirects ? routes.supabaseRedirect : null,
    refreshListenable: refreshListenable,
    observers: observers ?? const [],
    routes: _buildRoutes(ref),
  );
}

/// Builds all application routes.
///
/// Kept as a separate function for testability and clarity.
/// Note: The [ref] parameter is kept for API consistency but routes access
/// providers via ProviderScope.containerOf(context) in builders.
List<RouteBase> _buildRoutes([WidgetRef? ref]) {
  return [
    // ─────────────────────────────────────────────────────────────────────
    // Splash
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Consent Welcome (W1-W5)
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.consentWelcome01,
      name: 'welcome1',
      builder: (context, state) => const ConsentWelcome01Screen(),
    ),
    GoRoute(
      path: RoutePaths.consentWelcome02,
      name: 'welcome2',
      builder: (context, state) => const ConsentWelcome02Screen(),
    ),
    GoRoute(
      path: RoutePaths.consentWelcome03,
      name: 'welcome3',
      builder: (context, state) => const ConsentWelcome03Screen(),
    ),
    GoRoute(
      path: RoutePaths.consentWelcome04,
      name: 'welcome4',
      builder: (context, state) => const ConsentWelcome04Screen(),
    ),
    GoRoute(
      path: RoutePaths.consentWelcome05,
      name: 'welcome5',
      builder: (context, state) => const ConsentWelcome05Screen(),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Consent Flow (C1-C3)
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.consentIntro,
      name: 'consent_intro',
      builder: (context, state) => const ConsentIntroScreen(),
    ),
    GoRoute(
      path: RoutePaths.consentOptions,
      name: 'consent_options',
      builder: (context, state) => const ConsentOptionsScreen(),
    ),
    GoRoute(
      path: RoutePaths.consentBlocking,
      name: 'consent_blocking',
      builder: (context, state) => const ConsentBlockingScreen(),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Onboarding (O1-O8)
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.onboarding01,
      name: 'onboarding_01',
      builder: (ctx, st) => const Onboarding01Screen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding02,
      name: 'onboarding_02',
      builder: (ctx, st) => const Onboarding02Screen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding03Fitness,
      name: 'onboarding_03_fitness',
      builder: (ctx, st) => const Onboarding03FitnessScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding04Goals,
      name: 'onboarding_04_goals',
      builder: (ctx, st) => const Onboarding04GoalsScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding05Interests,
      name: 'onboarding_05_interests',
      builder: (ctx, st) => const Onboarding05InterestsScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding06CycleIntro,
      name: 'onboarding_06_cycle_intro',
      builder: (ctx, st) => const Onboarding06CycleIntroScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding06Period,
      name: Onboarding06PeriodScreen.navName,
      builder: (ctx, st) => const Onboarding06PeriodScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding07Duration,
      name: 'onboarding_07_duration',
      builder: (ctx, st) {
        final periodStart = st.extra is DateTime ? st.extra as DateTime : null;
        return Onboarding07DurationScreen(periodStartDate: periodStart);
      },
    ),
    GoRoute(
      path: RoutePaths.onboardingSuccess,
      name: 'onboarding_success',
      builder: (ctx, st) => const OnboardingSuccessScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboardingDone,
      name: 'onboarding_done',
      builder: (ctx, st) =>
          Center(child: Text(AppLocalizations.of(ctx)!.onboardingComplete)),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Auth
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.authSignIn,
      name: RouteNames.authSignIn,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AuthSignInScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: RoutePaths.resetPassword,
      name: 'reset',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    // Legacy redirect: /auth/forgot → /auth/reset (backward compatibility)
    GoRoute(
      path: RoutePaths.authForgot,
      redirect: (context, state) => RoutePaths.resetPassword,
    ),
    GoRoute(
      path: RoutePaths.createNewPassword,
      name: 'password_new',
      builder: (context, state) => const CreateNewPasswordScreen(
        key: ValueKey('auth_create_new_screen'),
      ),
    ),
    GoRoute(
      path: RoutePaths.passwordSaved,
      name: SuccessScreen.passwordSavedRouteName,
      builder: (context, state) => const SuccessScreen(),
    ),
    GoRoute(
      path: RoutePaths.signup,
      name: 'signup',
      builder: (context, state) => const AuthSignupScreen(),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Dashboard
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.heute,
      name: 'heute',
      redirect: (context, state) {
        // Defense-in-Depth: Ensure consent AND onboarding are complete.
        final container = ProviderScope.containerOf(context, listen: false);
        final asyncValue = container.read(userStateServiceProvider);
        // While loading, redirect to splash to prevent flicker
        if (asyncValue.isLoading) return RoutePaths.splash;
        final service = asyncValue.whenOrNull(data: (s) => s);
        final hasCompletedOnboarding = service?.hasCompletedOnboardingOrNull;
        final acceptedConsentVersion = service?.acceptedConsentVersionOrNull;
        final isStateKnown = service != null && hasCompletedOnboarding != null;
        return routes.homeGuardRedirectWithConsent(
          isStateKnown: isStateKnown,
          hasCompletedOnboarding: hasCompletedOnboarding,
          acceptedConsentVersion: acceptedConsentVersion,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );
      },
      builder: (context, state) => const HeuteScreen(),
    ),
    GoRoute(
      path: RoutePaths.workoutDetail,
      name: 'workout_detail_stub',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        if (id == 'unknown') {
          return Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context)!.errorInvalidWorkoutId),
            ),
          );
        }
        return WorkoutDetailStubScreen(workoutId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.trainingsOverview,
      name: 'trainings_overview_stub',
      builder: (context, state) => const TrainingsOverviewStubScreen(),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Cycle
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.cycleOverview,
      name: 'cycle_overview_stub',
      builder: (context, state) => const CycleOverviewStubScreen(),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Profile
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.profile,
      name: RouteNames.profile,
      builder: (context, state) => const ProfileStubScreen(),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Legal (In-App Fallback)
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.legalPrivacy,
      name: 'legal_privacy',
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return LegalViewer.asset(
          'assets/legal/privacy.md',
          title: l10n?.privacyPolicyTitle ?? 'Privacy Policy',
          appLinks: const ProdAppLinks(),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.legalTerms,
      name: 'legal_terms',
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return LegalViewer.asset(
          'assets/legal/terms.md',
          title: l10n?.termsOfServiceTitle ?? 'Terms of Service',
          appLinks: const ProdAppLinks(),
        );
      },
    ),
  ];
}

/// Returns the list of all application routes.
///
/// Use this when you need the raw route list without creating a full router.
/// Main.dart uses this to integrate with its own router orchestration.
List<RouteBase> buildAppRoutes(WidgetRef ref) => _buildRoutes(ref);

/// Returns all application routes for testing purposes.
///
/// This is equivalent to [buildAppRoutes] but doesn't require a [WidgetRef].
/// Routes that need provider access use ProviderScope.containerOf(context)
/// in their builders, which works when tests wrap widgets in [ProviderScope].
///
/// Usage in tests:
/// ```dart
/// final router = GoRouter(
///   routes: testAppRoutes,
///   initialLocation: '/auth/login',
/// );
/// ```
@visibleForTesting
List<RouteBase> get testAppRoutes => _buildRoutes();

/// Provider for GoRouter instance.
///
/// Use this in widgets that need router access via Riverpod.
/// For main.dart where ConsumerStatefulWidget is used, prefer [createRouter].
final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  throw UnimplementedError(
    'routerProvider must be overridden in ProviderScope. '
    'Use createRouter() in main.dart instead.',
  );
});
