import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'device_state_service.g.dart';

/// Device-local state that persists across user sessions.
///
/// Unlike [UserStateService], this service is NOT user-scoped.
/// The welcome flag survives logout and account switches.
///
/// Use case: Show welcome screens only once per device, regardless of
/// which user is logged in.
class DeviceStateService {
  DeviceStateService({required this.prefs});

  final SharedPreferences prefs;

  static const _keyWelcomeCompleted = 'device:welcome_completed_v1';

  /// Exposed for test assertions. Do not use in production code.
  @visibleForTesting
  static const keyWelcomeCompleted = _keyWelcomeCompleted;

  /// Whether the user has completed the welcome flow on this device.
  ///
  /// Returns `false` if not set (new device/fresh install).
  bool get hasCompletedWelcome => prefs.getBool(_keyWelcomeCompleted) ?? false;

  /// Mark the welcome flow as completed on this device.
  ///
  /// This flag persists across logout and account switches.
  /// Throws [StateError] if persistence fails.
  Future<void> markWelcomeCompleted() async {
    try {
      final success = await prefs.setBool(_keyWelcomeCompleted, true);
      if (!success) {
        throw StateError('Failed to persist welcome completion flag');
      }
    } catch (e) {
      if (e is StateError) rethrow;
      throw StateError(
        'SharedPreferences error while persisting welcome flag: $e',
      );
    }
  }

  /// Reset device state (for testing purposes).
  Future<void> reset() async {
    await prefs.remove(_keyWelcomeCompleted);
  }
}

@riverpod
Future<DeviceStateService> deviceStateService(Ref ref) async {
  final link = ref.keepAlive();
  ref.onDispose(link.close);
  final prefs = await SharedPreferences.getInstance();
  return DeviceStateService(prefs: prefs);
}
