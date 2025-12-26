import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session;
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_intro_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_blocking_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_02_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_03_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_04_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_05_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_02.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_03_fitness.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_04_goals.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_cycle_intro.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/cycle/screens/cycle_overview_stub.dart';
import 'package:luvi_app/features/profile/screens/profile_stub_screen.dart';
import 'package:luvi_app/features/dashboard/screens/workout_detail_stub.dart';
import 'package:luvi_app/features/dashboard/screens/trainings_overview_stub.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/core/logging/logger.dart';

// Root onboarding path without trailing slash to allow exact match checks.
const String _onboardingRootPath = '/onboarding';
// Short "/onboarding/w" prefix covers welcome screens (w1–w5) and keeps URLs
// aligned with existing deep links and analytics dashboards.
const String _welcomeRootPath = '/onboarding/w';
const String _consentRootPath = '/consent';
const String _consentPathPrefix = '$_consentRootPath/';

class OnboardingRoutes {
  static const done = '/onboarding/done';
}
// Route helpers for readability and maintainability. These are pure functions
// so they can be unit-tested easily by passing a location string.
bool isOnboardingRoute(String location) {
  // Onboarding covers the core steps (o1–o8, success, done),
  // but explicitly excludes the welcome intro screens under /onboarding/w.
  final isOnboardingRoot =
      location == _onboardingRootPath ||
      location.startsWith('$_onboardingRootPath/');
  if (!isOnboardingRoot) return false;
  // Exclude welcome routes to avoid overlap with isWelcomeRoute
  return !location.startsWith(_welcomeRootPath);
}

bool isWelcomeRoute(String location) {
  return location.startsWith(_welcomeRootPath);
}

bool isConsentRoute(String location) {
  return location == _consentRootPath ||
      location.startsWith(_consentPathPrefix);
}

/// Determines if access to Home should be blocked due to incomplete onboarding.
///
/// Fail-safe approach: When state is unknown (service not loaded), redirect to
/// Splash with skipAnimation to let the gate logic decide properly.
///
/// Returns:
/// - `/splash?skipAnimation=true` if state is unknown (fail-safe)
/// - Onboarding01 route if hasCompletedOnboarding is explicitly false
/// - null (allow) if hasCompletedOnboarding is true
@visibleForTesting
String? homeGuardRedirect({
  required bool isStateKnown,
  required bool? hasCompletedOnboarding,
}) {
  // Fail-safe: If state unknown, delegate to Splash (no visible animation).
  // Splash will re-check all gates properly.
  if (!isStateKnown) {
    return '${SplashScreen.routeName}?skipAnimation=true';
  }
  // State is known - apply gate logic
  if (hasCompletedOnboarding == false) {
    return Onboarding01Screen.routeName;
  }
  return null;
}

/// Defense-in-Depth: Home guard with consent version check.
///
/// Unlike [homeGuardRedirect], this also validates that the user has accepted
/// the current consent version. This prevents bypassing consent via deep link
/// or saved route to /heute.
///
/// Gate priority (matches Splash logic):
/// 1. State unknown → Splash (fail-safe)
/// 2. Consent outdated/missing → ConsentWelcome01
/// 3. Onboarding incomplete → Onboarding01
/// 4. All gates passed → null (allow)
@visibleForTesting
String? homeGuardRedirectWithConsent({
  required bool isStateKnown,
  required bool? hasCompletedOnboarding,
  required int? acceptedConsentVersion,
  required int currentConsentVersion,
}) {
  // Fail-safe: If state unknown, delegate to Splash (no visible animation).
  if (!isStateKnown) {
    return '${SplashScreen.routeName}?skipAnimation=true';
  }

  // Defense-in-Depth: Check consent version FIRST (matches Splash gate order)
  final needsConsent = acceptedConsentVersion == null ||
      acceptedConsentVersion < currentConsentVersion;
  if (needsConsent) {
    return ConsentWelcome01Screen.routeName;
  }

  // Then check onboarding
  if (hasCompletedOnboarding == false) {
    return Onboarding01Screen.routeName;
  }

  return null;
}

final List<GoRoute> featureRoutes = [
  GoRoute(
    path: SplashScreen.routeName,
    name: 'splash',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: ConsentWelcome01Screen.routeName,
    name: 'welcome1',
    builder: (context, state) => const ConsentWelcome01Screen(),
  ),
  GoRoute(
    path: ConsentWelcome02Screen.routeName,
    name: 'welcome2',
    builder: (context, state) => const ConsentWelcome02Screen(),
  ),
  GoRoute(
    path: ConsentWelcome03Screen.routeName,
    name: 'welcome3',
    builder: (context, state) => const ConsentWelcome03Screen(),
  ),
  GoRoute(
    path: ConsentWelcome04Screen.routeName,
    name: 'welcome4',
    builder: (context, state) => const ConsentWelcome04Screen(),
  ),
  GoRoute(
    path: ConsentWelcome05Screen.routeName,
    name: 'welcome5',
    builder: (context, state) => const ConsentWelcome05Screen(),
  ),
  // C1 - Consent Intro Screen (Route: /consent/02 - mapped from W5 for backwards compatibility)
  GoRoute(
    path: ConsentIntroScreen.routeName,
    name: 'consent_intro',
    builder: (context, state) => const ConsentIntroScreen(),
  ),
  // C2 - Consent Options Screen
  GoRoute(
    path: ConsentOptionsScreen.routeName,
    name: 'consent_options',
    builder: (context, state) {
      // Obtain AppLinks via Riverpod to enable DI and testing.
      final container = ProviderScope.containerOf(context, listen: false);
      final appLinks = container.read(appLinksProvider);
      return ConsentOptionsScreen(appLinks: appLinks);
    },
  ),
  // C3 - Consent Blocking Screen
  GoRoute(
    path: ConsentBlockingScreen.routeName,
    name: 'consent_blocking',
    builder: (context, state) => const ConsentBlockingScreen(),
  ),
  GoRoute(
    path: Onboarding01Screen.routeName,
    name: 'onboarding_01',
    builder: (ctx, st) => const Onboarding01Screen(),
  ),
  GoRoute(
    path: Onboarding02Screen.routeName,
    name: 'onboarding_02',
    builder: (ctx, st) => const Onboarding02Screen(),
  ),
  // Onboarding screens (refactored flow)
  GoRoute(
    path: Onboarding03FitnessScreen.routeName,
    name: 'onboarding_03_fitness',
    builder: (ctx, st) => const Onboarding03FitnessScreen(),
  ),
  GoRoute(
    path: Onboarding04GoalsScreen.routeName,
    name: 'onboarding_04_goals',
    builder: (ctx, st) => const Onboarding04GoalsScreen(),
  ),
  GoRoute(
    path: Onboarding05InterestsScreen.routeName,
    name: 'onboarding_05_interests',
    builder: (ctx, st) => const Onboarding05InterestsScreen(),
  ),
  // O6: Cycle Intro Screen (NEU - zwischen O5 und O7)
  GoRoute(
    path: Onboarding06CycleIntroScreen.routeName,
    name: 'onboarding_06_cycle_intro',
    builder: (ctx, st) => const Onboarding06CycleIntroScreen(),
  ),
  GoRoute(
    path: Onboarding06PeriodScreen.routeName,
    name: Onboarding06PeriodScreen.navName,
    builder: (ctx, st) => const Onboarding06PeriodScreen(),
  ),
  GoRoute(
    path: Onboarding07DurationScreen.routeName,
    name: 'onboarding_07_duration',
    builder: (ctx, st) {
      // Defensiver Cast: Verhindert Crash bei falschem extra-Typ
      final periodStart = st.extra is DateTime ? st.extra as DateTime : null;
      return Onboarding07DurationScreen(periodStartDate: periodStart);
    },
  ),
  GoRoute(
    path: OnboardingSuccessScreen.routeName,
    name: 'onboarding_success',
    builder: (ctx, st) => const OnboardingSuccessScreen(),
  ),
  GoRoute(
    path: OnboardingRoutes.done,
    name: 'onboarding_done',
    builder: (ctx, st) =>
        Center(child: Text(AppLocalizations.of(ctx)!.onboardingComplete)),
  ),
  GoRoute(
    path: AuthSignInScreen.routeName,
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
    path: LoginScreen.routeName,
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
    path: ResetPasswordScreen.routeName,
    name: 'reset',
    builder: (context, state) => const ResetPasswordScreen(),
  ),
  // Legacy redirect: /auth/forgot → /auth/reset (backward compatibility)
  GoRoute(
    path: '/auth/forgot',
    redirect: (context, state) => ResetPasswordScreen.routeName,
  ),
  GoRoute(
    path: CreateNewPasswordScreen.routeName,
    name: 'password_new',
    builder: (context, state) => const CreateNewPasswordScreen(
      key: ValueKey('auth_create_new_screen'),
    ),
  ),
  GoRoute(
    path: SuccessScreen.passwordSavedRoutePath,
    name: SuccessScreen.passwordSavedRouteName,
    builder: (context, state) => const SuccessScreen(),
  ),
  GoRoute(
    path: AuthSignupScreen.routeName,
    name: 'signup',
    builder: (context, state) => const AuthSignupScreen(),
  ),
  GoRoute(
    path: HeuteScreen.routeName,
    name: 'heute',
    redirect: (context, state) {
      // Defense-in-Depth: Ensure consent AND onboarding are complete.
      // This prevents bypassing gates via deep link or saved route.
      final container = ProviderScope.containerOf(context, listen: false);
      final asyncValue = container.read(userStateServiceProvider);
      // Extract value if loaded, null otherwise (loading/error states).
      // NOTE: AsyncLoading/AsyncError → null → isStateKnown=false → redirect
      // to Splash. This is intentional: during loading, we delegate to Splash
      // which handles the loading screen properly.
      final service = asyncValue.whenOrNull(data: (s) => s);
      final hasCompletedOnboarding = service?.hasCompletedOnboardingOrNull;
      final acceptedConsentVersion = service?.acceptedConsentVersionOrNull;
      // State is known when service loaded AND onboarding state determined.
      // Consent-null is semantically meaningful ("needs consent") and handled
      // by homeGuardRedirectWithConsent directly - no Splash hop needed.
      final isStateKnown =
          service != null &&
          hasCompletedOnboarding != null;
      return homeGuardRedirectWithConsent(
        isStateKnown: isStateKnown,
        hasCompletedOnboarding: hasCompletedOnboarding,
        acceptedConsentVersion: acceptedConsentVersion,
        currentConsentVersion: ConsentConfig.currentVersionInt,
      );
    },
    builder: (context, state) => const HeuteScreen(),
  ),
  GoRoute(
    path: CycleOverviewStubScreen.routeName,
    name: 'cycle_overview_stub',
    builder: (context, state) => const CycleOverviewStubScreen(),
  ),
  GoRoute(
    path: ProfileStubScreen.routeName,
    name: RouteNames.profile,
    builder: (context, state) => const ProfileStubScreen(),
  ),
  GoRoute(
    path: WorkoutDetailStubScreen.route,
    name: 'workout_detail_stub',
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? 'unknown';
      if (id == 'unknown') {
        // Redirect to a safe fallback or show an error state
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
    path: TrainingsOverviewStubScreen.route,
    name: 'trainings_overview_stub',
    builder: (context, state) => const TrainingsOverviewStubScreen(),
  ),
];

/// Redirect-Guard für GoRouter - delegiert an [supabaseRedirectWithSession].
String? supabaseRedirect(BuildContext context, GoRouterState state) =>
    supabaseRedirectWithSession(context, state);

/// Testbare Version des Redirect-Guards mit optionalen Overrides.
///
/// In Production wird [sessionOverride] und [isInitializedOverride] ignoriert.
/// In Tests können diese Parameter genutzt werden, um verschiedene
/// Session-Szenarien zu simulieren ohne Supabase-Client zu mocken.
@visibleForTesting
String? supabaseRedirectWithSession(
  BuildContext context,
  GoRouterState state, {
  Session? sessionOverride,
  bool? isInitializedOverride,
}) {
  // Dev-only bypass to allow opening the dashboard without auth during development
  const allowDashboardDev = bool.fromEnvironment(
    'ALLOW_DASHBOARD_DEV',
    defaultValue: false,
  );
  const allowOnboardingDev = bool.fromEnvironment(
    'ALLOW_ONBOARDING_DEV',
    defaultValue: false,
  );
  // Enable via --dart-define=ALLOW_ONBOARDING_DEV=true (false by default).

  final isInitialized = isInitializedOverride ?? SupabaseService.isInitialized;
  final isLoggingIn = state.matchedLocation.startsWith(LoginScreen.routeName);
  final isAuthSignIn = state.matchedLocation.startsWith(
    AuthSignInScreen.routeName,
  );
  // Auth-Flow Bugfix: Signup und Reset-Routen ohne Session erlauben
  final isSigningUp = state.matchedLocation.startsWith(AuthSignupScreen.routeName);
  final isResettingPassword = state.matchedLocation.startsWith(ResetPasswordScreen.routeName);
  final isOnboarding = isOnboardingRoute(state.matchedLocation);
  final isWelcome = isWelcomeRoute(state.matchedLocation);
  final isConsent = isConsentRoute(state.matchedLocation);
  final isDashboard = state.matchedLocation.startsWith(HeuteScreen.routeName);
  final isSplash = state.matchedLocation == SplashScreen.routeName;
  final isPasswordRecoveryRoute =
      state.matchedLocation.startsWith(CreateNewPasswordScreen.routeName);
  final isPasswordSuccessRoute = state.matchedLocation
      .startsWith(SuccessScreen.passwordSavedRoutePath);
  // Session access with defensive try-catch for resilience
  Session? session;
  if (sessionOverride != null) {
    session = sessionOverride;
  } else if (isInitialized) {
    try {
      session = SupabaseService.client.auth.currentSession;
    } catch (e, stack) {
      // Log unexpected session access failure for observability
      log.w(
        'auth_redirect_session_access_failed',
        tag: 'navigation',
        error: e.runtimeType.toString(),
        stack: stack,
      );
      session = null;
    }
  }

  if (isPasswordRecoveryRoute || isPasswordSuccessRoute) {
    return null;
  }

  if (isWelcome || isConsent) {
    return null;
  }

  // Dev-only bypass to allow opening onboarding without auth
  if (allowOnboardingDev && !kReleaseMode && isOnboarding) {
    return null;
  }

  if (allowDashboardDev && !kReleaseMode && isDashboard) {
    return null; // allow dashboard route in dev without auth
  }

  if (isSplash) {
    return null;
  }

  if (session == null) {
    // Auth-Flow Bugfix: Alle Auth-Screens ohne Session erlauben
    if (isLoggingIn || isAuthSignIn || isSigningUp || isResettingPassword) {
      return null;
    }
    return AuthSignInScreen.routeName;
  }
  // Auth-Flow Bugfix: Nach Login (E-Mail ODER OAuth) mit Session → zu Splash
  // Splash macht die First-Time/Returning-User-Logik async und korrekt
  // Hinweis: session ist hier garantiert != null (oben bereits geprüft)
  // UX-Fix: skipAnimation=true verhindert erneute Splash-Animation nach Login
  if (isLoggingIn || isAuthSignIn) {
    return '${SplashScreen.routeName}?skipAnimation=true';
  }
  return null;
}
