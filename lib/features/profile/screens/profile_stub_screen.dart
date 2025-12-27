import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/user_state_service.dart';

/// Minimal profile stub screen with logout functionality for QA/MVP.
///
/// This is a temporary screen that will be replaced with a full profile
/// implementation later. Its primary purpose is to provide a logout option.
class ProfileStubScreen extends ConsumerWidget {
  static const String routeName = '/profil';

  const ProfileStubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onPressed: () => _handleSignOut(context, ref),
          child: Text(l10n.splashGateSignOutCta),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    bool serverFailed = false;

    try {
      await SupabaseService.client.auth.signOut();
    } catch (e, st) {
      serverFailed = true;
      log.w('sign out failed', tag: 'profile', error: sanitizeError(e), stack: st);
    }

    // Always clear local state (even if server signOut failed)
    try {
      final userState = await ref.read(userStateServiceProvider.future);
      await userState.bindUser(null); // Clears all user-scoped state
    } catch (e, st) {
      // Best-effort local cleanup - log for diagnosis but don't block flow
      log.w('profile cleanup failed', tag: 'ProfileStub', error: sanitizeError(e), stack: st);
    }

    if (!context.mounted) return;

    // Cache messenger and l10n BEFORE navigation (while context is valid)
    final messenger = ScaffoldMessenger.of(context);
    final l10n = serverFailed ? AppLocalizations.of(context)! : null;

    // Navigate to auth screen
    context.goNamed(RouteNames.authSignIn);

    // Show warning snackbar AFTER navigation (using cached messenger)
    // MaterialApp's ScaffoldMessenger persists across route changes
    if (serverFailed && l10n != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.signOutFailed)),
      );
    }
  }
}
