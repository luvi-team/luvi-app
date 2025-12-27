import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';

void main() {
  group('RoutePaths SSOT', () {
    test('splash path starts with /', () {
      expect(RoutePaths.splash, startsWith('/'));
    });

    test('auth paths all start with /auth/', () {
      expect(RoutePaths.authSignIn, startsWith('/auth/'));
      expect(RoutePaths.login, startsWith('/auth/'));
      expect(RoutePaths.signup, startsWith('/auth/'));
      expect(RoutePaths.resetPassword, startsWith('/auth/'));
      expect(RoutePaths.createNewPassword, startsWith('/auth/'));
      expect(RoutePaths.passwordSaved, startsWith('/auth/'));
    });

    test('consent welcome paths follow pattern /onboarding/wN', () {
      expect(RoutePaths.consentWelcome01, equals('/onboarding/w1'));
      expect(RoutePaths.consentWelcome02, equals('/onboarding/w2'));
      expect(RoutePaths.consentWelcome03, equals('/onboarding/w3'));
      expect(RoutePaths.consentWelcome04, equals('/onboarding/w4'));
      expect(RoutePaths.consentWelcome05, equals('/onboarding/w5'));
    });

    test('consent flow paths all start with /consent/', () {
      expect(RoutePaths.consentIntro, startsWith('/consent/'));
      expect(RoutePaths.consentOptions, startsWith('/consent/'));
      expect(RoutePaths.consentBlocking, startsWith('/consent/'));
    });

    test('onboarding paths all start with /onboarding/', () {
      expect(RoutePaths.onboarding01, startsWith('/onboarding/'));
      expect(RoutePaths.onboarding02, startsWith('/onboarding/'));
      expect(RoutePaths.onboarding03Fitness, startsWith('/onboarding/'));
      expect(RoutePaths.onboarding04Goals, startsWith('/onboarding/'));
      expect(RoutePaths.onboarding05Interests, startsWith('/onboarding/'));
      expect(RoutePaths.onboarding06CycleIntro, startsWith('/onboarding/'));
      expect(RoutePaths.onboarding06Period, startsWith('/onboarding/'));
      expect(RoutePaths.onboarding07Duration, startsWith('/onboarding/'));
      expect(RoutePaths.onboardingSuccess, startsWith('/onboarding/'));
      expect(RoutePaths.onboardingDone, startsWith('/onboarding/'));
    });

    test('workoutDetail contains :id parameter', () {
      expect(RoutePaths.workoutDetail, contains(':id'));
    });

    test('workoutDetail can be parameterized', () {
      final path = RoutePaths.workoutDetail.replaceFirst(':id', 'workout-123');
      expect(path, equals('/workout/workout-123'));
    });

    test('legal paths all start with /legal/', () {
      expect(RoutePaths.legalPrivacy, startsWith('/legal/'));
      expect(RoutePaths.legalTerms, startsWith('/legal/'));
    });

    test('all paths are unique', () {
      final paths = [
        RoutePaths.splash,
        RoutePaths.authSignIn,
        RoutePaths.login,
        RoutePaths.signup,
        RoutePaths.resetPassword,
        RoutePaths.authForgot,
        RoutePaths.createNewPassword,
        RoutePaths.passwordSaved,
        RoutePaths.consentWelcome01,
        RoutePaths.consentWelcome02,
        RoutePaths.consentWelcome03,
        RoutePaths.consentWelcome04,
        RoutePaths.consentWelcome05,
        RoutePaths.consentIntro,
        RoutePaths.consentOptions,
        RoutePaths.consentBlocking,
        RoutePaths.onboarding01,
        RoutePaths.onboarding02,
        RoutePaths.onboarding03Fitness,
        RoutePaths.onboarding04Goals,
        RoutePaths.onboarding05Interests,
        RoutePaths.onboarding06CycleIntro,
        RoutePaths.onboarding06Period,
        RoutePaths.onboarding07Duration,
        RoutePaths.onboardingSuccess,
        RoutePaths.onboardingDone,
        RoutePaths.heute,
        RoutePaths.workoutDetail,
        RoutePaths.trainingsOverview,
        RoutePaths.luviSync,
        RoutePaths.cycleOverview,
        RoutePaths.profile,
        RoutePaths.legalPrivacy,
        RoutePaths.legalTerms,
      ];

      final uniquePaths = paths.toSet();
      expect(
        uniquePaths.length,
        equals(paths.length),
        reason: 'All route paths must be unique',
      );
    });
  });
}
