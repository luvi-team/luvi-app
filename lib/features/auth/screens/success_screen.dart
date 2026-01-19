import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/navigation/route_query_params.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rainbow_background.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';

/// SuccessScreen with Auth Rebrand v3 design (export-parity).
///
/// Route: /auth/password/success
///
/// Features:
/// - Rainbow background (arcs + stripes)
/// - AuthContentCard with Title + Subtitle (SSOT: auth_success)
/// - Title: "Geschafft!" (Playfair SemiBold 20px)
/// - Subtitle: "Neues Passwort gespeichert." (Figtree Regular 17px)
/// - NO CTA button and NO back button (Requirement)
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
      context.go('${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}');
    } else {
      // User is not logged in → back to auth entry
      context.go(RoutePaths.authSignIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Title style: Playfair SemiBold 20px (SSOT: auth_success.headline)
    const titleStyle = TextStyle(
      fontFamily: FontFamilies.playfairDisplay,
      fontSize: AuthRebrandMetrics.headlineFontSize,
      fontWeight: FontWeight.w600,
      height: AuthRebrandMetrics.headlineLineHeight,
      color: DsColors.authRebrandTextPrimary,
    );

    // Subtitle style: Figtree Regular 17px (SSOT: auth_success.subtitle)
    const subtitleStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: AuthRebrandMetrics.bodyFontSize,
      fontWeight: FontWeight.w400,
      height: AuthRebrandMetrics.bodyLineHeight,
      color: DsColors.authRebrandTextPrimary,
    );

    return Scaffold(
      key: const ValueKey('auth_success_screen'),
      backgroundColor: DsColors.authRebrandBackground,
      body: Stack(
        children: [
          // Rainbow background (containerTop aligned for device consistency)
          Positioned.fill(
            child: AuthRainbowBackground(
              containerTop: MediaQuery.of(context).padding.top +
                  AuthRebrandMetrics.rainbowContainerTopOffset,
            ),
          ),

          // Content - centered AuthContentCard (export-parity layout)
          SafeArea(
            child: Center(
              child: AuthContentCard(
                width: AuthRebrandMetrics.cardWidthForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title: "Geschafft!"
                    Text(
                      l10n.authSuccessPwdTitle,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: Spacing.xs),

                    // Subtitle: "Neues Passwort gespeichert."
                    Text(
                      l10n.authSuccessPwdSubtitle,
                      style: subtitleStyle,
                      textAlign: TextAlign.center,
                    ),

                    // No CTA button - auto-redirect handles navigation
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
