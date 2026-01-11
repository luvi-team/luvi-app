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

      test('missing key (null) returns false safely', () async {
        // This test verifies the ?? false fallback works when
        // hasCompletedWelcome key is not set in SharedPreferences.
        SharedPreferences.setMockInitialValues({});
        final cleanPrefs = await SharedPreferences.getInstance();
        final cleanService = DeviceStateService(prefs: cleanPrefs);

        // getBool returns null for missing keys, which should default to false
        expect(cleanService.hasCompletedWelcome, isFalse);
      });
    });
  });
}
