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

const String _onboardingRootPath = '/onboarding/';
// Short "/onboarding/w" prefix covers welcome screens (w1–w3) and keeps URLs
// aligned with existing deep links and analytics dashboards.
const String _welcomeRootPath = '/onboarding/w';
const String _consentRootPath = '/consent/';

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
    builder: (context, state) => const Consent02Screen(),
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
    builder: (ctx, st) => const OnboardingSuccessScreen(),
  ),
  GoRoute(
    path: '/onboarding/done',
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
    path: SuccessScreen.forgotEmailSentRouteName,
    name: 'forgot_sent',
    builder: (context, state) =>
        const SuccessScreen(variant: SuccessVariant.forgotEmailSent),
  ),
  GoRoute(
    path: CreateNewPasswordScreen.routeName,
    name: 'password_new',
    builder: (context, state) => const CreateNewPasswordScreen(),
  ),
  GoRoute(
    path: SuccessScreen.passwordSuccessRouteName,
    name: 'password_success',
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

  final isInitialized = SupabaseService.isInitialized;
  final isLoggingIn = state.matchedLocation.startsWith(LoginScreen.routeName);
  final isAuthEntry = state.matchedLocation.startsWith(
    AuthEntryScreen.routeName,
  );
  final isOnboarding = state.matchedLocation.startsWith(_onboardingRootPath);
  final isWelcome = state.matchedLocation.startsWith(_welcomeRootPath);
  final isConsent = state.matchedLocation.startsWith(_consentRootPath);
  final isDashboard = state.matchedLocation.startsWith(HeuteScreen.routeName);
  final isSplash = state.matchedLocation == SplashScreen.routeName;
  final session = isInitialized
      ? SupabaseService.client.auth.currentSession
      : null;

  if (isWelcome || isConsent) {
    return null;
  }

  // Dev-only bypass to allow opening onboarding without auth
  if (!kReleaseMode && isOnboarding) {
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
