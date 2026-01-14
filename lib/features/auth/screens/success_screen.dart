import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/auth/widgets/glow_checkmark.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rainbow_background.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';

/// SuccessScreen with Auth Rebrand v3 design.
///
/// Route: /auth/password/success
///
/// Features:
/// - Rainbow background (arcs + stripes)
/// - GlowCheckmark icon
/// - Title: "Geschafft!" (Playfair SemiBold 24px)
/// - Subtitle: "Neues Passwort gespeichert."
/// - NO CTA button (removed per design spec)
/// - Auto-redirect after 1.5 seconds:
///   - If authenticated → splash (Guards handle Onboarding vs Home)
///   - If not authenticated → auth entry
class SuccessScreen extends StatefulWidget {
  static const String passwordSavedRoutePath = '/auth/password/success';
  static const String passwordSavedRouteName = 'password_saved';

  /// Auto-redirect delay in milliseconds.
  /// Configurable for testing.
  final int autoRedirectDelayMs;

  const SuccessScreen({
    super.key,
    this.autoRedirectDelayMs = 1500,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRedirect();
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _startAutoRedirect() {
    _redirectTimer = Timer(
      Duration(milliseconds: widget.autoRedirectDelayMs),
      _performRedirect,
    );
  }

  void _performRedirect() {
    if (!mounted) return;

    final isAuthenticated = SupabaseService.isAuthenticated;
    if (isAuthenticated) {
      // User is logged in → go to splash with skipAnimation
      // PostAuth guards will determine Onboarding vs Home
      context.go('${RoutePaths.splash}?skipAnimation=true');
    } else {
      // User is not logged in → back to auth entry
      context.go(RoutePaths.authSignIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Title style: Playfair SemiBold 24px
    final titleStyle = TextStyle(
      fontFamily: FontFamilies.playfairDisplay,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: DsColors.authRebrandTextPrimary,
    );

    // Subtitle style: Figtree Regular 16px
    final subtitleStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: DsColors.authRebrandTextPrimary.withValues(alpha: 0.7),
    );

    return Scaffold(
      key: const ValueKey('auth_success_screen'),
      body: Stack(
        children: [
          // Rainbow background with arcs and stripes
          const Positioned.fill(
            child: AuthRainbowBackground(),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GlowCheckmark centered
                  const GlowCheckmark(),

                  const SizedBox(height: Spacing.xl),

                  // Title
                  Text(
                    l10n.authSuccessPwdTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: Spacing.s),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
                    child: Text(
                      l10n.authSuccessPwdSubtitle,
                      style: subtitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // No CTA button - auto-redirect handles navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
