import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/auth/utils/oauth_cancellation.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_bottom_sheet_shell.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_login_sheet.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_register_sheet.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Auth Entry screen with Auth Rebrand v3 design.
///
/// Features:
/// - Beige background (#F9F1E6)
/// - Hero image at bottom
/// - LUVI logo (SVG) with teal dot
/// - "Los geht's" pink CTA → opens Register bottom sheet
/// - "Ich habe bereits einen Account." link → opens Login bottom sheet
///
/// Route: /auth/signin
class AuthSignInScreen extends ConsumerStatefulWidget {
  const AuthSignInScreen({super.key});

  static const String routeName = '/auth/signin';

  @override
  ConsumerState<AuthSignInScreen> createState() => _AuthSignInScreenState();
}

class _AuthSignInScreenState extends ConsumerState<AuthSignInScreen> {
  bool _oauthLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    // Calculate scale factor for responsive positioning
    // Design baseline: 402×874 (AuthRebrandMetrics SSOT from PNG exports)
    final scaleY = size.height / AuthRebrandMetrics.designHeight;

    return Scaffold(
      key: const ValueKey('auth_signin_screen'),
      backgroundColor: DsColors.authRebrandBackground,
      body: Stack(
        children: [
          // Hero image at bottom (decorative, excluded from semantics)
          Positioned(
            key: const ValueKey('auth_entry_hero'),
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              Assets.images.auth.heroAuthEntry,
              fit: BoxFit.fitWidth,
              width: size.width,
              excludeFromSemantics: true,
            ),
          ),

          // LUVI Logo with Teal Dot - fixed size, responsive position
          Positioned(
            left: 0,
            right: 0,
            top: (size.height / 2) +
                (AuthRebrandMetrics.entryLogoCenterYOffset * scaleY) -
                (AuthRebrandMetrics.entryLogoHeight / 2),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Logo - fixed size for brand consistency
                  SvgPicture.asset(
                    Assets.images.auth.logoLuvi,
                    height: AuthRebrandMetrics.entryLogoHeight,
                    semanticsLabel: 'LUVI Logo',
                  ),
                  // Teal Dot - fixed size, positioned relative to logo
                  Positioned(
                    right: AuthRebrandMetrics.entryTealDotRightOffset,
                    top: AuthRebrandMetrics.entryTealDotTopOffset,
                    child: ExcludeSemantics(
                      child: Container(
                        width: AuthRebrandMetrics.entryTealDotSize,
                        height: AuthRebrandMetrics.entryTealDotSize,
                        decoration: const BoxDecoration(
                          color: DsColors.authRebrandTealDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CTA Container - horizontally centered for symmetric margins
          Positioned(
            left: 0,
            right: 0,
            top: AuthRebrandMetrics.entryCtaY * scaleY,
            child: Center(
              child: SizedBox(
                width: AuthRebrandMetrics.entryCtaWidth,
                child: _buildCtaSection(l10n),
              ),
            ),
          ),

          // Loading overlay
          if (_oauthLoading)
            Container(
              color: DsColors.authRebrandBackground.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  color: DsColors.authRebrandCtaPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCtaSection(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary CTA - "Los geht's"
        AuthPrimaryButton(
          key: const ValueKey('auth_entry_cta'),
          label: l10n.authEntryCta,
          width: AuthRebrandMetrics.entryCtaWidth,
          height: AuthRebrandMetrics.entryPrimaryButtonHeight,
          onPressed: _oauthLoading ? null : _showRegisterSheet,
        ),

        const SizedBox(height: AuthRebrandMetrics.entryCtaGap),

        // Login link - "Ich habe bereits einen Account."
        // SSOT: Figma 69690:2191 - Figtree SemiBold 17px, line-height 24px, #000000
        // A11y: TextButton for proper focus/ripple and 44dp touch target
        TextButton(
          onPressed: _oauthLoading ? null : _showLoginSheet,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, Sizes.touchTargetMin), // ✅ 44dp
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Pixel-parity
            padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
            foregroundColor: DsColors.black,
          ),
          child: Text(
            l10n.authEntryExistingAccount,
            style: const TextStyle(
              fontFamily: FontFamilies.figtree,
              fontSize: AuthRebrandMetrics.linkFontSize,
              fontVariations: [FontVariation('wght', 600)], // SemiBold for variable font
              height: AuthRebrandMetrics.bodyLineHeight, // 24/17
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showRegisterSheet() {
    AuthBottomSheetShell.show(
      context: context,
      builder: (context) => AuthRegisterSheet(
        onApplePressed: () => _handleOAuthSignIn(supa.OAuthProvider.apple),
        onGooglePressed: () => _handleOAuthSignIn(supa.OAuthProvider.google),
        onEmailPressed: () => context.push(RoutePaths.signup),
      ),
    );
  }

  void _showLoginSheet() {
    AuthBottomSheetShell.show(
      context: context,
      builder: (context) => AuthLoginSheet(
        onApplePressed: () => _handleOAuthSignIn(supa.OAuthProvider.apple),
        onGooglePressed: () => _handleOAuthSignIn(supa.OAuthProvider.google),
        onEmailPressed: () => context.push(RoutePaths.login),
      ),
    );
  }

  Future<void> _handleOAuthSignIn(supa.OAuthProvider provider) async {
    if (_oauthLoading) return;
    setState(() => _oauthLoading = true);

    try {
      final redirect = AppLinks.oauthRedirectUri;
      await supa.Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? null : redirect,
        authScreenLaunchMode: kIsWeb
            ? supa.LaunchMode.platformDefault
            : supa.LaunchMode.externalApplication,
      );
    } on supa.AuthException catch (error) {
      if (isOAuthUserCancellation(error.message)) {
        return;
      }
      logNonCancellationOAuthError(error.message, provider: provider.name);
      _handleOAuthError(error, StackTrace.current, provider);
    } catch (error, stackTrace) {
      final errorString = error.toString();
      if (isOAuthUserCancellation(errorString)) {
        return;
      }
      logNonCancellationOAuthError(errorString, provider: provider.name);
      _handleOAuthError(error, stackTrace, provider);
    } finally {
      if (mounted) {
        setState(() => _oauthLoading = false);
      }
    }
  }

  String _getProviderErrorMessage(
    AppLocalizations l10n,
    supa.OAuthProvider provider,
  ) {
    switch (provider) {
      case supa.OAuthProvider.apple:
        return l10n.authSignInAppleError;
      case supa.OAuthProvider.google:
        return l10n.authSignInGoogleError;
      default:
        return l10n.authSignInOAuthError;
    }
  }

  void _handleOAuthError(
    Object error,
    StackTrace stackTrace,
    supa.OAuthProvider provider,
  ) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'auth_signin_screen',
      context: ErrorDescription('OAuth sign-in failed: ${provider.name}'),
    ));

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      final errorMessage = _getProviderErrorMessage(l10n, provider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
