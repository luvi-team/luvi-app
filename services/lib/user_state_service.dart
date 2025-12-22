import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_state_service.g.dart';

const _keyHasSeenWelcome = 'has_seen_welcome';
const _keyHasCompletedOnboarding = 'has_completed_onboarding';
const _keyFitnessLevel = 'onboarding_fitness_level';
const _keyAcceptedConsentVersion = 'accepted_consent_version';
// Pre-auth (device-scoped) consent cache for FTUE: Consent happens before auth.
// Cleared after a successful post-auth flush to server SSOT.
const _keyPreAuthAcceptedConsentVersion = 'preauth_accepted_consent_version';
const _keyPreAuthConsentScopes = 'preauth_consent_scopes';
const _keyPreAuthConsentPolicyVersion = 'preauth_consent_policy_version';

enum FitnessLevel {
  beginner,
  occasional,
  fit,
  /// Sentinel value indicating an invalid or unset fitness level.
  /// Not selectable by users; excluded from selection order.
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

  // Account-scope: All persisted keys must be user-scoped to avoid cross-account
  // leakage when multiple users sign in on the same device.
  String? _boundUserId;

  String? get boundUserId => _boundUserId;

  static const List<String> _legacyUnscopedKeys = [
    _keyHasSeenWelcome,
    _keyHasCompletedOnboarding,
    _keyFitnessLevel,
    _keyAcceptedConsentVersion,
  ];

  String? _scopedKey(String baseKey) {
    final uid = _boundUserId;
    if (uid == null || uid.isEmpty) return null;
    return 'u:$uid:$baseKey';
  }

  static String _scopedKeyFor(String userId, String baseKey) =>
      'u:$userId:$baseKey';

  /// Bind this cache instance to a specific authenticated user.
  ///
  /// Security invariant:
  /// - All keys are stored under a user-scoped prefix.
  /// - When the bound user changes (including sign-out), previously bound
  ///   gate keys are cleared so no gate state can bleed into another account.
  Future<void> bindUser(String? userId) async {
    if (_boundUserId == userId) return;

    final previous = _boundUserId;

    // Always remove legacy unscoped keys. We intentionally do NOT migrate them,
    // because they may belong to a different account (cross-account leak risk).
    for (final key in _legacyUnscopedKeys) {
      try {
        if (prefs.containsKey(key)) {
          await prefs.remove(key);
        }
      } catch (_) {
        // Best-effort: cache keys are non-critical and must not crash auth flows.
      }
    }

    // Clear previous user's scoped keys on sign-out / account switch (privacy).
    if (previous != null && previous.isNotEmpty) {
      for (final baseKey in _legacyUnscopedKeys) {
        try {
          await prefs.remove(_scopedKeyFor(previous, baseKey));
        } catch (_) {
          // Best-effort
        }
      }
    }

    _boundUserId = userId;
  }

  bool get hasSeenWelcome =>
      (_scopedKey(_keyHasSeenWelcome) == null)
          ? false
          : (prefs.getBool(_scopedKey(_keyHasSeenWelcome)!) ?? false);

  /// Returns whether the welcome has been seen, or null if the key is absent
  /// (unknown state). Useful for callers that want to treat "unknown"
  /// differently from an explicit false.
  bool? get hasSeenWelcomeOrNull {
    final key = _scopedKey(_keyHasSeenWelcome);
    if (key == null) return null;
    if (!prefs.containsKey(key)) return null;
    return prefs.getBool(key);
  }

  bool get hasCompletedOnboarding =>
      (_scopedKey(_keyHasCompletedOnboarding) == null)
          ? false
          : (prefs.getBool(_scopedKey(_keyHasCompletedOnboarding)!) ?? false);

  /// Returns whether onboarding has been completed, or null if the key is
  /// absent
  /// (unknown state). Useful for callers that want to treat "unknown"
  /// differently from an explicit false.
  bool? get hasCompletedOnboardingOrNull {
    final key = _scopedKey(_keyHasCompletedOnboarding);
    if (key == null) return null;
    if (!prefs.containsKey(key)) return null;
    return prefs.getBool(key);
  }

  FitnessLevel? get fitnessLevel =>
      FitnessLevel.tryParse(
        _scopedKey(_keyFitnessLevel) == null
            ? null
            : prefs.getString(_scopedKey(_keyFitnessLevel)!),
      );

  /// Returns the accepted consent version, or null if not yet accepted.
  int? get acceptedConsentVersionOrNull =>
      _scopedKey(_keyAcceptedConsentVersion) == null
          ? null
          : prefs.getInt(_scopedKey(_keyAcceptedConsentVersion)!);

  /// Device-scoped pre-auth consent (FTUE).
  ///
  /// Used when users accept consent before signing in. After auth, Splash will
  /// flush this to server SSOT (profiles + consent log) and clear it.
  int? get preAuthAcceptedConsentVersionOrNull =>
      prefs.getInt(_keyPreAuthAcceptedConsentVersion);

  List<String>? get preAuthConsentScopesOrNull =>
      prefs.getStringList(_keyPreAuthConsentScopes);

  String? get preAuthConsentPolicyVersionOrNull =>
      prefs.getString(_keyPreAuthConsentPolicyVersion);

  Future<void> setPreAuthConsent({
    required int acceptedConsentVersion,
    required String policyVersion,
    required List<String> scopes,
  }) async {
    if (acceptedConsentVersion <= 0) {
      throw ArgumentError.value(
        acceptedConsentVersion,
        'acceptedConsentVersion',
        'must be positive',
      );
    }
    if (policyVersion.trim().isEmpty) {
      throw ArgumentError.value(policyVersion, 'policyVersion', 'cannot be empty');
    }
    if (scopes.isEmpty) {
      throw ArgumentError.value(scopes, 'scopes', 'must be non-empty');
    }
    final ok1 = await prefs.setInt(
      _keyPreAuthAcceptedConsentVersion,
      acceptedConsentVersion,
    );
    final ok2 = await prefs.setString(
      _keyPreAuthConsentPolicyVersion,
      policyVersion,
    );
    final ok3 = await prefs.setStringList(_keyPreAuthConsentScopes, scopes);
    if (!ok1 || !ok2 || !ok3) {
      throw StateError('Failed to persist pre-auth consent cache');
    }
  }

  Future<void> clearPreAuthConsent() async {
    try {
      await prefs.remove(_keyPreAuthAcceptedConsentVersion);
    } catch (_) {}
    try {
      await prefs.remove(_keyPreAuthConsentPolicyVersion);
    } catch (_) {}
    try {
      await prefs.remove(_keyPreAuthConsentScopes);
    } catch (_) {}
  }

  Future<void> setHasCompletedOnboarding(bool value) async {
    final key = _scopedKey(_keyHasCompletedOnboarding);
    if (key == null) {
      throw StateError('UserStateService is not bound to a user');
    }

    final success = await prefs.setBool(key, value);
    if (!success) {
      throw StateError('Failed to persist onboarding completion flag');
    }

    // Optional consistency: if onboarding is explicitly false, also clear the
    // fitness level key so callers don't observe stale onboarding state.
    final fitnessKey = _scopedKey(_keyFitnessLevel);
    if (!value && fitnessKey != null && prefs.containsKey(fitnessKey)) {
      final removed = await prefs.remove(fitnessKey);
      if (!removed) {
        throw StateError('Failed to clear onboarding fitness level');
      }
    }
  }

  Future<void> setAcceptedConsentVersion(int version) async {
    final key = _scopedKey(_keyAcceptedConsentVersion);
    if (key == null) {
      throw StateError('UserStateService is not bound to a user');
    }
    final success = await prefs.setInt(key, version);
    if (!success) {
      throw StateError('Failed to persist accepted consent version');
    }
  }

  Future<void> markWelcomeSeen() async {
    final key = _scopedKey(_keyHasSeenWelcome);
    if (key == null) {
      throw StateError('UserStateService is not bound to a user');
    }
    final success = await prefs.setBool(key, true);
    if (!success) {
      throw StateError('Failed to persist welcome seen flag');
    }
  }

  Future<void> markOnboardingComplete({
    required FitnessLevel fitnessLevel,
  }) async {
    final completedKey = _scopedKey(_keyHasCompletedOnboarding);
    final fitnessKey = _scopedKey(_keyFitnessLevel);
    if (completedKey == null || fitnessKey == null) {
      throw StateError('UserStateService is not bound to a user');
    }

    // Write completion flag first, then persist fitness level. If the second
    // write fails, best-effort rollback the flag to avoid a partially
    // completed onboarding state.
    final wroteFlag = await prefs.setBool(completedKey, true);
    if (!wroteFlag) {
      throw StateError('Failed to persist onboarding completion flag');
    }

    try {
      final wroteLevel = await prefs.setString(fitnessKey, fitnessLevel.name);
      if (!wroteLevel) {
        // Best-effort rollback; ignore rollback failure and surface original error
        try {
          await prefs.remove(completedKey);
        } catch (e) {
          // Best-effort log without depending on Flutter; keep service pure Dart.
          // ignore: avoid_print
          print(
            '[UserStateService] Rollback failed during markOnboardingComplete: $e',
          );
        }
        throw StateError('Failed to persist fitness level');
      }
    } catch (e) {
      // Rollback on exception as well
      try {
        await prefs.remove(completedKey);
      } catch (rollbackErr) {
        // Best-effort log without depending on Flutter; keep service pure Dart.
        // ignore: avoid_print
        print(
          '[UserStateService] Rollback failed during markOnboardingComplete: $rollbackErr',
        );
      }
      // Rethrow original error (preserve type if StateError, otherwise wrap)
      if (e is StateError) {
        rethrow;
      } else {
        throw StateError('Failed to persist fitness level: $e');
      }
    }
  }

  Future<void> setFitnessLevel(FitnessLevel level) async {
    final key = _scopedKey(_keyFitnessLevel);
    if (key == null) {
      throw StateError('UserStateService is not bound to a user');
    }
    final success = await prefs.setString(key, level.name);
    if (!success) {
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
        if (!ok) {
          failures.add(key);
        }
      } on Exception {
        failures.add(key);
      }
    }

    await removeKey(_keyHasSeenWelcome);
    await removeKey(_keyHasCompletedOnboarding);
    await removeKey(_keyFitnessLevel);
    await removeKey(_keyAcceptedConsentVersion);

    // Also clear scoped keys for the currently bound user (if any).
    final uid = _boundUserId;
    if (uid != null && uid.isNotEmpty) {
      await removeKey(_scopedKeyFor(uid, _keyHasSeenWelcome));
      await removeKey(_scopedKeyFor(uid, _keyHasCompletedOnboarding));
      await removeKey(_scopedKeyFor(uid, _keyFitnessLevel));
      await removeKey(_scopedKeyFor(uid, _keyAcceptedConsentVersion));
    }

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
