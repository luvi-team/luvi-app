import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/screens/verification_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_01_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_02_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_02_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_03_screen.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';
import 'package:luvi_app/features/screens/onboarding_02.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';
import 'package:luvi_app/features/screens/onboarding_04.dart';
import 'package:luvi_app/features/screens/onboarding_05.dart';
import 'package:luvi_app/features/screens/onboarding_06.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/features/screens/onboarding_08.dart';
import 'package:luvi_app/features/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/features/cycle/screens/cycle_overview_stub.dart';
import 'package:luvi_app/features/dashboard/screens/workout_detail_stub.dart';
import 'package:luvi_app/features/dashboard/screens/trainings_overview_stub.dart';
import 'package:luvi_app/features/screens/splash/splash_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Root onboarding path without trailing slash to allow exact match checks.
const String _onboardingRootPath = '/onboarding';
// Short "/onboarding/w" prefix covers welcome screens (w1–w3) and keeps URLs
// aligned with existing deep links and analytics dashboards.
const String _welcomeRootPath = '/onboarding/w';
const String _consentRootPath = '/consent';
const String _consentPathPrefix = '$_consentRootPath/';

class OnboardingRoutes {
  static const done = '/onboarding/done';
}

// Route helpers for readability and maintainability. These are pure functions
// so they can be unit-tested easily by passing a location string.
bool _isOnboardingRoute(String location) {
  // Onboarding covers the core steps (o1–o8, success, done),
  // but explicitly excludes the welcome intro screens under /onboarding/w.
  final isOnboardingRoot =
      location == _onboardingRootPath ||
      location.startsWith('$_onboardingRootPath/');
  if (!isOnboardingRoot) return false;
  // Exclude welcome routes to avoid overlap with _isWelcomeRoute
  return !location.startsWith(_welcomeRootPath);
}

bool _isWelcomeRoute(String location) {
  return location.startsWith(_welcomeRootPath);
}

bool _isConsentRoute(String location) {
  return location == _consentRootPath ||
      location.startsWith(_consentPathPrefix);
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
    path: Consent01Screen.routeName,
    name: 'consent01',
    builder: (context, state) => const Consent01Screen(),
  ),
  GoRoute(
    path: Consent02Screen.routeName,
    name: 'consent02',
    builder: (context, state) {
      // Obtain AppLinks via Riverpod to enable DI and testing.
      final container = ProviderScope.containerOf(context, listen: false);
      final appLinks = container.read(appLinksProvider);
      return Consent02Screen(appLinks: appLinks);
    },
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
  GoRoute(
    path: Onboarding03Screen.routeName,
    name: 'onboarding_03',
    builder: (ctx, st) => const Onboarding03Screen(),
  ),
  GoRoute(
    path: Onboarding04Screen.routeName,
    name: 'onboarding_04',
    builder: (ctx, st) => const Onboarding04Screen(),
  ),
  GoRoute(
    path: Onboarding05Screen.routeName,
    name: 'onboarding_05',
    builder: (ctx, st) => const Onboarding05Screen(),
  ),
  GoRoute(
    path: Onboarding06Screen.routeName,
    name: 'onboarding_06',
    builder: (ctx, st) => const Onboarding06Screen(),
  ),
  GoRoute(
    path: Onboarding07Screen.routeName,
    name: 'onboarding_07',
    builder: (ctx, st) => const Onboarding07Screen(),
  ),
  GoRoute(
    path: Onboarding08Screen.routeName,
    name: 'onboarding_08',
    builder: (ctx, st) => const Onboarding08Screen(),
  ),
  GoRoute(
    path: OnboardingSuccessScreen.routeName,
    name: 'onboarding_success',
    redirect: (ctx, st) {
      final extra = st.extra;
      if (extra is FitnessLevel) {
        return null; // ok
      }
      return Onboarding01Screen.routeName;
    },
    builder: (ctx, st) {
      final fitnessLevel = st.extra;
      if (fitnessLevel is! FitnessLevel) {
        // Should never happen due to redirect, but defensive programming
        throw StateError('OnboardingSuccessScreen requires FitnessLevel');
      }
      return OnboardingSuccessScreen(fitnessLevel: fitnessLevel);
    },
  ),
  GoRoute(
    path: OnboardingRoutes.done,
    name: 'onboarding_done',
    builder: (ctx, st) =>
        Center(child: Text(AppLocalizations.of(ctx)!.onboardingComplete)),
  ),
  GoRoute(
    path: AuthEntryScreen.routeName,
    name: 'auth_entry',
    builder: (context, state) => const AuthEntryScreen(),
  ),
  GoRoute(
    path: LoginScreen.routeName,
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: ResetPasswordScreen.routeName,
    name: 'forgot',
    builder: (context, state) => const ResetPasswordScreen(),
  ),
  GoRoute(
    path: SuccessScreen.forgotEmailSentRoutePath,
    name: SuccessScreen.forgotEmailSentRouteName,
    builder: (context, state) =>
        const SuccessScreen(variant: SuccessVariant.forgotEmailSent),
  ),
  GoRoute(
    path: CreateNewPasswordScreen.routeName,
    name: 'password_new',
    builder: (context, state) => const CreateNewPasswordScreen(
      key: ValueKey('auth_create_new_screen'),
    ),
  ),
  GoRoute(
    path: SuccessScreen.passwordSuccessRoutePath,
    name: SuccessScreen.passwordSuccessRouteName,
    builder: (context, state) => const SuccessScreen(),
  ),
  GoRoute(
    path: VerificationScreen.routeName,
    name: 'verify',
    builder: (context, state) {
      final variantParam = state.uri.queryParameters['variant'];
      final variant = variantParam == 'email'
          ? VerificationScreenVariant.emailConfirmation
          : VerificationScreenVariant.resetPassword;
      return VerificationScreen(variant: variant);
    },
  ),
  GoRoute(
    path: AuthSignupScreen.routeName,
    name: 'signup',
    builder: (context, state) => const AuthSignupScreen(),
  ),
  GoRoute(
    path: HeuteScreen.routeName,
    name: 'heute',
    builder: (context, state) => const HeuteScreen(),
  ),
  GoRoute(
    path: CycleOverviewStubScreen.routeName,
    name: 'cycle_overview_stub',
    builder: (context, state) => const CycleOverviewStubScreen(),
  ),
  GoRoute(
    path: WorkoutDetailStubScreen.route,
    name: 'workout_detail_stub',
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? 'unknown';
      return WorkoutDetailStubScreen(workoutId: id);
    },
  ),
  GoRoute(
    path: TrainingsOverviewStubScreen.route,
    name: 'trainings_overview_stub',
    builder: (context, state) => const TrainingsOverviewStubScreen(),
  ),
];

String? supabaseRedirect(BuildContext context, GoRouterState state) {
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

  final isInitialized = SupabaseService.isInitialized;
  final isLoggingIn = state.matchedLocation.startsWith(LoginScreen.routeName);
  final isAuthEntry = state.matchedLocation.startsWith(
    AuthEntryScreen.routeName,
  );
  final isOnboarding = _isOnboardingRoute(state.matchedLocation);
  final isWelcome = _isWelcomeRoute(state.matchedLocation);
  final isConsent = _isConsentRoute(state.matchedLocation);
  final isDashboard = state.matchedLocation.startsWith(HeuteScreen.routeName);
  final isSplash = state.matchedLocation == SplashScreen.routeName;
  final session = isInitialized
      ? SupabaseService.client.auth.currentSession
      : null;

  if (isWelcome || isConsent) {
    return null;
  }

  // Dev-only bypass to allow opening onboarding without auth
  if (allowOnboardingDev && isOnboarding) {
    return null;
  }

  if (allowDashboardDev && !kReleaseMode && isDashboard) {
    return null; // allow dashboard route in dev without auth
  }

  if (isSplash) {
    return null;
  }

  if (session == null) {
    if (isLoggingIn || isAuthEntry) {
      return null;
    }
    return AuthEntryScreen.routeName;
  }
  if (isLoggingIn) {
    return Onboarding01Screen.routeName;
  }
  return null;
}
