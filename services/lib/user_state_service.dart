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
    try {
      return FitnessLevel.values.byName(raw);
    } on ArgumentError {
      return null;
    }
  }
}

class UserStateService {
  UserStateService({required this.prefs});

  final SharedPreferences prefs;

  bool get hasSeenWelcome => prefs.getBool(_keyHasSeenWelcome) ?? false;

  /// Returns whether the welcome has been seen, or null if the key is absent
  /// (unknown state). Useful for callers that want to treat "unknown"
  /// differently from an explicit false.
  bool? get hasSeenWelcomeOrNull {
    if (!prefs.containsKey(_keyHasSeenWelcome)) return null;
    return prefs.getBool(_keyHasSeenWelcome);
  }

  bool get hasCompletedOnboarding =>
      prefs.getBool(_keyHasCompletedOnboarding) ?? false;

  FitnessLevel? get fitnessLevel =>
      FitnessLevel.tryParse(prefs.getString(_keyFitnessLevel));

  Future<void> markWelcomeSeen() async {
    final success = await prefs.setBool(_keyHasSeenWelcome, true);
    if (success != true) {
      throw StateError('Failed to persist welcome seen flag');
    }
  }

  Future<void> markOnboardingComplete({
    required FitnessLevel fitnessLevel,
  }) async {
    // Persist fitness level first, then the completion flag. If the second
    // write fails, attempt to roll back the first to avoid inconsistent state.
    final wroteLevel = await prefs.setString(_keyFitnessLevel, fitnessLevel.name);
    if (wroteLevel != true) {
      throw StateError('Failed to persist fitness level');
    }
    final wroteFlag = await prefs.setBool(_keyHasCompletedOnboarding, true);
    if (wroteFlag != true) {
      // Rollback: best-effort removal of fitness level
      try {
        final removed = await prefs.remove(_keyFitnessLevel);
        if (removed != true) {
          throw StateError('Rollback failed: could not remove fitness level key');
        }
      } catch (rollbackError) {
        // Rollback failed; we're in an inconsistent state
        throw StateError(
          'Failed to persist onboarding completion flag and rollback failed: $rollbackError'
        );
      }
      throw StateError('Failed to persist onboarding completion flag');
    }
  }

  Future<void> setFitnessLevel(FitnessLevel level) async {
    final success = await prefs.setString(_keyFitnessLevel, level.name);
    if (success != true) {
      throw StateError('Failed to persist fitness level');
    }
  }

  Future<void> reset() async {
    // Perform removals sequentially to avoid masking failures that can occur
    // when running in parallel. This is best-effort: if any removal fails,
    // previously removed keys are not rolled back (SharedPreferences has no
    // transactional API). We attempt all removals and then throw with the
    // list of failed keys so the caller can decide to retry or surface an
    // error to the user.
    final failures = <String>[];
    Future<void> removeKey(String key) async {
      try {
        final ok = await prefs.remove(key);
        if (ok != true) {
          failures.add(key);
        }
      } catch (_) {
        failures.add(key);
      }
    }

    await removeKey(_keyHasSeenWelcome);
    await removeKey(_keyHasCompletedOnboarding);
    await removeKey(_keyFitnessLevel);

    if (failures.isNotEmpty) {
      throw StateError(
        'Failed to clear user state keys: ${failures.join(', ')}',
      );
    }
  }
}

@riverpod
Future<UserStateService> userStateService(Ref ref) async {
  final link = ref.keepAlive();
  ref.onDispose(link.close);
  final prefs = await SharedPreferences.getInstance();
  return UserStateService(prefs: prefs);
}
