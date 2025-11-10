import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_state_service.g.dart';

const _keyHasSeenWelcome = 'has_seen_welcome';
const _keyHasCompletedOnboarding = 'has_completed_onboarding';
const _keyFitnessLevel = 'onboarding_fitness_level';

enum FitnessLevel {
  beginner,
  occasional,
  fit,
  unknown;

  static const List<FitnessLevel> _selectionOrder = [
    FitnessLevel.beginner,
    FitnessLevel.occasional,
    FitnessLevel.fit,
    FitnessLevel.unknown,
  ];

  static FitnessLevel fromSelectionIndex(int index) {
    if (index < 0 || index >= _selectionOrder.length) {
      throw RangeError.range(
        index,
        0,
        _selectionOrder.length - 1,
        'index',
        'Invalid fitness level selection index.',
      );
    }
    return _selectionOrder[index];
  }

  static int? selectionIndexFor(FitnessLevel? level) {
    if (level == null) return null;
    final index = _selectionOrder.indexOf(level);
    return index >= 0 ? index : null;
  }

  static FitnessLevel? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final level in FitnessLevel.values) {
      if (level.name == raw) {
        return level;
      }
    }
    return null;
  }
}

class UserStateService {
  UserStateService({required this.prefs});

  final SharedPreferences prefs;

  bool get hasSeenWelcome => prefs.getBool(_keyHasSeenWelcome) ?? false;

  bool get hasCompletedOnboarding =>
      prefs.getBool(_keyHasCompletedOnboarding) ?? false;

  FitnessLevel? get fitnessLevel =>
      FitnessLevel.tryParse(prefs.getString(_keyFitnessLevel));

  Future<void> markWelcomeSeen() async {
    await prefs.setBool(_keyHasSeenWelcome, true);
  }

  Future<void> markOnboardingComplete({
    required FitnessLevel fitnessLevel,
  }) async {
    await Future.wait([
      prefs.setBool(_keyHasCompletedOnboarding, true),
      prefs.setString(_keyFitnessLevel, fitnessLevel.name),
    ]);
  }

  Future<void> setFitnessLevel(FitnessLevel level) async {
    await prefs.setString(_keyFitnessLevel, level.name);
  }

  Future<void> reset() async {
    await Future.wait([
      prefs.remove(_keyHasSeenWelcome),
      prefs.remove(_keyHasCompletedOnboarding),
      prefs.remove(_keyFitnessLevel),
    ]);
  }
}

@riverpod
Future<UserStateService> userStateService(Ref ref) async {
  final link = ref.keepAlive();
  ref.onDispose(link.close);
  final prefs = await SharedPreferences.getInstance();
  return UserStateService(prefs: prefs);
}
