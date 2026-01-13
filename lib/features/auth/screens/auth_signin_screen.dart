import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
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

    return Scaffold(
      key: const ValueKey('auth_signin_screen'),
      backgroundColor: DsColors.authRebrandBackground,
      body: Stack(
        children: [
          // Hero image at bottom
          Positioned(
            key: const ValueKey('auth_entry_hero'),
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/auth/hero_auth_entry.png',
              fit: BoxFit.fitWidth,
              width: size.width,
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AuthRebrandMetrics.entryLogoGap),

                // Logo with teal dot
                _buildLogo(),

                const Spacer(),

                // CTA Section
                _buildCtaSection(l10n),

                const SizedBox(height: AuthRebrandMetrics.contentBottomGap),
              ],
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

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo row with SVG and teal dot
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LUVI logo SVG
            SvgPicture.asset(
              'assets/images/auth/logo_luvi.svg',
              height: 80,
              semanticsLabel: 'LUVI Logo',
            ),

            // Teal dot
            const SizedBox(width: Spacing.xxs),
            Container(
              width: AuthRebrandMetrics.entryTealDotSize,
              height: AuthRebrandMetrics.entryTealDotSize,
              decoration: const BoxDecoration(
                color: DsColors.authRebrandTealDot,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
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
          onPressed: _oauthLoading ? null : _showRegisterSheet,
        ),

        const SizedBox(height: Spacing.m),

        // Login link - "Ich habe bereits einen Account."
        Semantics(
          button: true,
          label: l10n.authEntryExistingAccount,
          child: GestureDetector(
            onTap: _oauthLoading ? null : _showLoginSheet,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.m,
                vertical: Spacing.xs,
              ),
              child: Text(
                l10n.authEntryExistingAccount,
                style: const TextStyle(
                  fontFamily: FontFamilies.figtree,
                  fontSize: AuthRebrandMetrics.linkFontSize,
                  fontWeight: FontWeight.w600,
                  color: DsColors.authRebrandTextPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
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
