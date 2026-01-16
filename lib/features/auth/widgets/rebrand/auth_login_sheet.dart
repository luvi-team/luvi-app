import 'package:flutter/material.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'auth_oauth_sheet_content.dart';

/// Login bottom sheet content for Auth Rebrand v3.
///
/// Shows Apple/Google OAuth buttons and "Continue with Email" option.
/// Displayed via [AuthBottomSheetShell.show].
///
/// Delegates to [AuthOAuthSheetContent] for the actual layout.
class AuthLoginSheet extends StatelessWidget {
  const AuthLoginSheet({
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
    final l10n = AppLocalizations.of(context)!;

    return AuthOAuthSheetContent(
      headline: l10n.authLoginSheetHeadline,
      onApplePressed: onApplePressed,
      onGooglePressed: onGooglePressed,
      onEmailPressed: onEmailPressed,
    );
  }
}
