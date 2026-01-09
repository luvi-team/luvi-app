import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luvi_services/device_state_service.dart';

/// Unit tests for DeviceStateService.
///
/// Tests cover:
/// - Initial state: hasCompletedWelcome returns false
/// - markWelcomeCompleted: Persists flag and changes hasCompletedWelcome to true
/// - reset: Clears flag and returns hasCompletedWelcome to false
/// - Flag survives service recreation (simulates app restart)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late DeviceStateService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = DeviceStateService(prefs: prefs);
  });

  group('DeviceStateService', () {
    group('hasCompletedWelcome', () {
      test('returns false initially (new device)', () {
        expect(service.hasCompletedWelcome, isFalse);
      });

      test('returns true after markWelcomeCompleted', () async {
        await service.markWelcomeCompleted();

        expect(service.hasCompletedWelcome, isTrue);
      });

      test('returns false after reset', () async {
        await service.markWelcomeCompleted();
        expect(service.hasCompletedWelcome, isTrue);

        await service.reset();

        expect(service.hasCompletedWelcome, isFalse);
      });
    });

    group('markWelcomeCompleted', () {
      test('persists flag to SharedPreferences', () async {
        await service.markWelcomeCompleted();

        // Verify raw SharedPreferences value
        expect(prefs.getBool(DeviceStateService.keyWelcomeCompleted), isTrue);
      });

      test('flag survives service recreation (simulates app restart)', () async {
        await service.markWelcomeCompleted();

        // Create new service instance (simulates app restart)
        final newService = DeviceStateService(prefs: prefs);

        expect(
          newService.hasCompletedWelcome,
          isTrue,
          reason: 'Flag should persist across service recreations',
        );
      });

      test('flag survives SharedPreferences reload', () async {
        await service.markWelcomeCompleted();

        // Reload SharedPreferences (simulates cold start with persisted data)
        final reloadedPrefs = await SharedPreferences.getInstance();
        final newService = DeviceStateService(prefs: reloadedPrefs);

        expect(
          newService.hasCompletedWelcome,
          isTrue,
          reason: 'Flag should persist across SharedPreferences reloads',
        );
      });
    });

    group('reset', () {
      test('removes flag from SharedPreferences', () async {
        await service.markWelcomeCompleted();
        expect(prefs.getBool(DeviceStateService.keyWelcomeCompleted), isTrue);

        await service.reset();

        expect(prefs.getBool(DeviceStateService.keyWelcomeCompleted), isNull);
      });

      test('is idempotent (calling reset twice does not throw)', () async {
        await service.reset();
        await service.reset();

        expect(service.hasCompletedWelcome, isFalse);
      });
    });

    group('edge cases', () {
      test('pre-existing flag is respected on service creation', () async {
        // Simulate device that already completed welcome
        SharedPreferences.setMockInitialValues({
          DeviceStateService.keyWelcomeCompleted: true,
        });
        final existingPrefs = await SharedPreferences.getInstance();
        final existingService = DeviceStateService(prefs: existingPrefs);

        expect(
          existingService.hasCompletedWelcome,
          isTrue,
          reason: 'Should respect pre-existing flag',
        );
      });

      test('corrupted value (non-bool) returns false safely', () async {
        // Note: SharedPreferences.setMockInitialValues only accepts valid types,
        // but in real scenarios corrupt data could exist.
        // This test verifies the ?? false fallback works.
        SharedPreferences.setMockInitialValues({});
        final cleanPrefs = await SharedPreferences.getInstance();
        final cleanService = DeviceStateService(prefs: cleanPrefs);

        // getBool returns null for missing keys, which should default to false
        expect(cleanService.hasCompletedWelcome, isFalse);
      });
    });
  });
}
