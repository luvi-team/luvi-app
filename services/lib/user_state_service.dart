import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_state_service.g.dart';

const _keyHasSeenWelcome = 'has_seen_welcome';
const _keyHasCompletedOnboarding = 'has_completed_onboarding';

class UserStateService {
  UserStateService({required this.prefs});

  final SharedPreferences prefs;

  bool get hasSeenWelcome => prefs.getBool(_keyHasSeenWelcome) ?? false;

  bool get hasCompletedOnboarding =>
      prefs.getBool(_keyHasCompletedOnboarding) ?? false;

  Future<void> markWelcomeSeen() async {
    await prefs.setBool(_keyHasSeenWelcome, true);
  }

  Future<void> markOnboardingComplete() async {
    await prefs.setBool(_keyHasCompletedOnboarding, true);
  }

  Future<void> reset() async {
    await Future.wait([
      prefs.remove(_keyHasSeenWelcome),
      prefs.remove(_keyHasCompletedOnboarding),
    ]);
  }
}

@riverpod
Future<UserStateService> userStateService(UserStateServiceRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return UserStateService(prefs: prefs);
}
