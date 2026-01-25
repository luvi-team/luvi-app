import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger.dart';

part 'user_state_service.g.dart';

const _keyHasSeenWelcome = 'has_seen_welcome';
const _keyHasCompletedOnboarding = 'has_completed_onboarding';
const _keyFitnessLevel = 'onboarding_fitness_level';
const _keyAcceptedConsentVersion = 'accepted_consent_version';
const _keyAcceptedConsentScopesJson = 'accepted_consent_scopes_json';

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
    _keyAcceptedConsentScopesJson,
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
  /// - Legacy unscoped keys are ALWAYS removed (even on same-user re-bind).
  Future<void> bindUser(String? userId) async {
    final previous = _boundUserId;

    // 1. Always remove legacy unscoped keys FIRST (before early return check).
    // We intentionally do NOT migrate them, because they may belong to a
    // different account (cross-account leak risk).
    for (final key in _legacyUnscopedKeys) {
      try {
        if (prefs.containsKey(key)) {
          await prefs.remove(key);
        }
      } catch (_) {
        // Best-effort: cache keys are non-critical and must not crash auth flows.
      }
    }

    // 2. Early return if same user (AFTER legacy cleanup).
    if (previous == userId) return;

    // 3. Clear previous user's scoped keys on sign-out / account switch (privacy).
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

  bool get hasSeenWelcome {
    final key = _scopedKey(_keyHasSeenWelcome);
    return key == null ? false : (prefs.getBool(key) ?? false);
  }

  /// Returns whether the welcome has been seen, or null if the key is absent
  /// (unknown state). Useful for callers that want to treat "unknown"
  /// differently from an explicit false.
  bool? get hasSeenWelcomeOrNull {
    final key = _scopedKey(_keyHasSeenWelcome);
    if (key == null) return null;
    if (!prefs.containsKey(key)) return null;
    return prefs.getBool(key);
  }

  bool get hasCompletedOnboarding {
    final key = _scopedKey(_keyHasCompletedOnboarding);
    return key == null ? false : (prefs.getBool(key) ?? false);
  }

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

  FitnessLevel? get fitnessLevel {
    final key = _scopedKey(_keyFitnessLevel);
    return FitnessLevel.tryParse(key == null ? null : prefs.getString(key));
  }

  /// Returns the accepted consent version, or null if not yet accepted.
  int? get acceptedConsentVersionOrNull {
    final key = _scopedKey(_keyAcceptedConsentVersion);
    return key == null ? null : prefs.getInt(key);
  }

  /// Returns the accepted consent scopes, or null if not yet persisted.
  ///
  /// Scopes are stored as a JSON array of scope name strings
  /// (e.g., ["health_processing", "terms", "analytics"]).
  /// Used by [analyticsConsentGateProvider] to determine analytics opt-in status.
  Set<String>? get acceptedConsentScopesOrNull {
    final key = _scopedKey(_keyAcceptedConsentScopesJson);
    if (key == null) return null;
    final json = prefs.getString(key);
    if (json == null) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) {
        log.d(
          'acceptedConsentScopesOrNull: decoded value is not List, key=$key, raw=$json',
          tag: 'UserStateService',
        );
        return null;
      }
      // Single-pass: collect strings and count non-strings
      final result = <String>{};
      var nonStringCount = 0;
      for (final element in decoded) {
        if (element is String) {
          result.add(element);
        } else {
          nonStringCount++;
        }
      }

      // CodeRabbit fix: Corrupted JSON should invalidate ALL consent for audit integrity.
      // Partial recovery could silently lose consent the user gave.
      // TODO(observability): Add metrics counter for corruption events (Sentry/PostHog)
      //   and background sync to repair cache from server SSOT. See: feat-m3-consent-miwf.md
      if (nonStringCount > 0) {
        // Elevated to error level for observability alerting.
        // Analytics may be incorrectly gated until cache is repaired.
        log.e(
          'acceptedConsentScopesOrNull: CORRUPTED - $nonStringCount non-String elements, '
          'invalidating all consent for data integrity. Analytics may be incorrectly gated. '
          'key=$key, raw=$json',
          tag: 'UserStateService',
        );
        return null;
      }
      return result;
    } catch (e) {
      // Corrupted/malformed JSON - fail-safe return null
      log.d(
        'acceptedConsentScopesOrNull: malformed JSON, key=$key, raw=$json, error=$e',
        tag: 'UserStateService',
      );
      return null;
    }
  }

  /// Test-only accessor for the consent scopes storage key.
  ///
  /// Returns the actual SharedPreferences key used for accepted consent scopes,
  /// allowing tests to corrupt/manipulate stored JSON without coupling to
  /// internal key naming conventions.
  @visibleForTesting
  String? get acceptedConsentScopesKeyForTesting =>
      _scopedKey(_keyAcceptedConsentScopesJson);

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
    // Best-effort cleanup: do not fail the primary operation if cleanup fails.
    final fitnessKey = _scopedKey(_keyFitnessLevel);
    if (!value && fitnessKey != null && prefs.containsKey(fitnessKey)) {
      try {
        final removed = await prefs.remove(fitnessKey);
        if (!removed) {
          log.w('Failed to clear fitness level key (best-effort cleanup)',
              tag: 'UserStateService');
        }
      } catch (e, stack) {
        log.w('Exception clearing fitness level key (best-effort cleanup)',
            tag: 'UserStateService', error: e, stack: stack);
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

  /// Persists the accepted consent scopes as a JSON array.
  ///
  /// Scopes are stored by their enum name (e.g., "health_processing", "terms", "analytics").
  /// Used to derive analytics opt-in status via [analyticsConsentGateProvider].
  /// The list is sorted alphabetically for deterministic JSON output.
  Future<void> setAcceptedConsentScopes(Set<String> scopes) async {
    final key = _scopedKey(_keyAcceptedConsentScopesJson);
    if (key == null) {
      throw StateError('UserStateService is not bound to a user');
    }
    final sortedList = scopes.toList()..sort();
    final json = jsonEncode(sortedList);
    final success = await prefs.setString(key, json);
    if (!success) {
      throw StateError('Failed to persist accepted consent scopes');
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
          log.w('Rollback failed during markOnboardingComplete',
              tag: 'UserStateService', error: e);
        }
        throw StateError('Failed to persist fitness level');
      }
    } catch (e) {
      // Rollback on exception as well
      try {
        await prefs.remove(completedKey);
      } catch (rollbackErr) {
        log.w('Rollback failed during markOnboardingComplete',
            tag: 'UserStateService', error: rollbackErr);
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
    await removeKey(_keyAcceptedConsentScopesJson);

    // Also clear scoped keys for the currently bound user (if any).
    final uid = _boundUserId;
    if (uid != null && uid.isNotEmpty) {
      await removeKey(_scopedKeyFor(uid, _keyHasSeenWelcome));
      await removeKey(_scopedKeyFor(uid, _keyHasCompletedOnboarding));
      await removeKey(_scopedKeyFor(uid, _keyFitnessLevel));
      await removeKey(_scopedKeyFor(uid, _keyAcceptedConsentVersion));
      await removeKey(_scopedKeyFor(uid, _keyAcceptedConsentScopesJson));
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
