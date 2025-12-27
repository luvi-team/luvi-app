import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';

/// SSOT Gate Test: Ensures route constants match documentation.
///
/// Canonical sources:
/// - docs/engineering/auth_ui_v2_mapping.md
/// - docs/engineering/auth_refactoring_plan.md
///
/// These tests act as a reconciliation gate to catch route mismatches
/// between code and SSOT documentation. If this test fails, verify
/// route constants align with the canonical source docs above.
void main() {
  group('SSOT Route Constants - Auth Flow', () {
    test('ResetPasswordScreen uses canonical route /auth/reset', () {
      expect(ResetPasswordScreen.routeName, '/auth/reset');
    });

    test('SuccessScreen uses canonical route /auth/password/success', () {
      expect(SuccessScreen.passwordSavedRoutePath, '/auth/password/success');
    });

    test('CreateNewPasswordScreen uses canonical route /auth/password/new', () {
      expect(CreateNewPasswordScreen.routeName, '/auth/password/new');
    });
  });
}
