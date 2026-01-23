import 'package:flutter/material.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'auth_oauth_sheet_content.dart';

/// Register bottom sheet content for Auth Rebrand v3.
///
/// Shows Apple/Google OAuth buttons and "Continue with Email" option.
/// Displayed via [AuthBottomSheetShell.show].
///
/// Delegates to [AuthOAuthSheetContent] for the actual layout.
class AuthRegisterSheet extends StatelessWidget {
  const AuthRegisterSheet({
    super.key,
    required this.onApplePressed,
    required this.onGooglePressed,
    required this.onEmailPressed,
  });

  /// Callback when Apple sign-in is pressed
  final VoidCallback onApplePressed;

  /// Callback when Google sign-in is pressed
  final VoidCallback onGooglePressed;

  /// Callback when Email sign-in is pressed
  final VoidCallback onEmailPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Throw to surface in crash reporting - this is a configuration bug.
      throw StateError(
        'AppLocalizations not found in context for AuthRegisterSheet. '
        'Ensure MaterialApp has localizationsDelegates configured.',
      );
    }

    return AuthOAuthSheetContent(
      headline: l10n.authRegisterHeadline,
      onApplePressed: onApplePressed,
      onGooglePressed: onGooglePressed,
      onEmailPressed: onEmailPressed,
    );
  }
}
