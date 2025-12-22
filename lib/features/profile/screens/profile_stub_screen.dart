import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';

/// Minimal profile stub screen with logout functionality for QA/MVP.
///
/// This is a temporary screen that will be replaced with a full profile
/// implementation later. Its primary purpose is to provide a logout option.
class ProfileStubScreen extends StatelessWidget {
  static const String routeName = '/profil';

  const ProfileStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardNavProfile)),
      body: Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: DsColors.welcomeButtonBg,
            side: const BorderSide(color: DsColors.welcomeButtonBg),
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.welcomeButtonPaddingVertical,
              horizontal: Sizes.welcomeButtonPaddingVertical * 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.radiusWelcomeButton),
            ),
          ),
          onPressed: () => _handleSignOut(context),
          child: Text(l10n.splashGateSignOutCta),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (e, st) {
      log.w('sign out failed', tag: 'profile', error: sanitizeError(e), stack: st);
    }
    if (context.mounted) {
      context.goNamed(RouteNames.authSignIn);
    }
  }
}
