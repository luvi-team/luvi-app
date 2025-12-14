import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/password_recovery_navigation_driver.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

void main() {
  group('PasswordRecoveryNavigationDriver', () {
    test('navigates when passwordRecovery event is emitted', () async {
      final events = StreamController<supa.AuthChangeEvent>();
      var navigateCount = 0;

      final driver = PasswordRecoveryNavigationDriver(
        authEvents: events.stream,
        onNavigateToCreatePassword: () {
          navigateCount++;
        },
      );

      events.add(supa.AuthChangeEvent.passwordRecovery);
      await Future<void>.delayed(Duration.zero);

      expect(navigateCount, 1);

      await driver.dispose();
      await events.close();
    });

    test('ignores non passwordRecovery events', () async {
      final events = StreamController<supa.AuthChangeEvent>();
      var navigateCount = 0;

      final driver = PasswordRecoveryNavigationDriver(
        authEvents: events.stream,
        onNavigateToCreatePassword: () {
          navigateCount++;
        },
      );

      events
        ..add(supa.AuthChangeEvent.signedIn)
        ..add(supa.AuthChangeEvent.userUpdated);

      await Future<void>.delayed(Duration.zero);

      expect(navigateCount, 0);

      await driver.dispose();
      await events.close();
    });

    test('navigates only once for duplicate passwordRecovery events', () async {
      final events = StreamController<supa.AuthChangeEvent>();
      var navigateCount = 0;

      final driver = PasswordRecoveryNavigationDriver(
        authEvents: events.stream,
        onNavigateToCreatePassword: () {
          navigateCount++;
        },
      );

      // Emit passwordRecovery twice back-to-back
      events
        ..add(supa.AuthChangeEvent.passwordRecovery)
        ..add(supa.AuthChangeEvent.passwordRecovery);

      await Future<void>.delayed(Duration.zero);

      // Should navigate only once despite two events
      expect(navigateCount, 1);

      await driver.dispose();
      await events.close();
    });
  });
}
