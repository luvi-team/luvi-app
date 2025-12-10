import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/widgets/auth_conic_gradient_background.dart';
import 'package:luvi_app/features/auth/widgets/auth_glass_card.dart';
import 'package:luvi_app/features/auth/widgets/auth_outline_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// SignIn entry screen with Apple, Google, and Email login options.
///
/// Figma Node: 69020:1379
/// Route: /auth/signin (replaces /auth/entry)
///
/// Features:
/// - Conic gradient background
/// - Glassmorphism card with headline
/// - Apple Sign In button (iOS/web only)
/// - Google Sign In button
/// - Email login outline button
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

    return Scaffold(
      key: const ValueKey('auth_signin_screen'),
      body: Stack(
        children: [
          // Full-screen conic gradient background
          const Positioned.fill(
            child: AuthConicGradientBackground(),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Glass card with headline
                  AuthGlassCard(
                    key: const ValueKey('auth_glass_card'),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.l,
                        vertical: Spacing.l + Spacing.xs, // 32px
                      ),
                      child: Text(
                        l10n.authSignInHeadline,
                        // Figma: Playfair Display Bold 32px, #9F2B68 (headlineMagenta)
                        // Intentional override: Auth headline requires specific Figma styling
                        style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 40 / 32,
                          color: DsColors.headlineMagenta,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Auth buttons with loading overlay
                  _buildAuthButtons(context, l10n),

                  // Loading indicator during OAuth
                  if (_oauthLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.m),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DsColors.headlineMagenta,
                          semanticsLabel: l10n.authSignInLoading,
                        ),
                      ),
                    ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context, AppLocalizations l10n) {
    final buttons = <Widget>[];

    // Apple Sign In (iOS/web only, per Apple HIG - Apple first)
    final appleSignInSupported = FeatureFlags.enableAppleSignIn &&
        (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS);

    if (appleSignInSupported) {
      buttons.add(
        AnimatedOpacity(
          opacity: _oauthLoading ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: _oauthLoading,
            child: SizedBox(
              key: const ValueKey('signin_apple_button'),
              width: double.infinity,
              height: Sizes.buttonHeightL,
              child: Semantics(
                button: true,
                enabled: !_oauthLoading,
                label: l10n.authSignInApple,
                child: SignInWithAppleButton(
                  style: SignInWithAppleButtonStyle.black,
                  onPressed: () => _handleOAuthSignIn(supa.OAuthProvider.apple),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Google Sign In
    if (FeatureFlags.enableGoogleSignIn) {
      buttons.add(
        AnimatedOpacity(
          opacity: _oauthLoading ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: _oauthLoading,
            child: SizedBox(
              key: const ValueKey('signin_google_button'),
              width: double.infinity,
              height: Sizes.buttonHeightL,
              child: Semantics(
                button: true,
                enabled: !_oauthLoading,
                label: l10n.authSignInGoogle,
                child: SignInButton(
                  Buttons.google,
                  text: l10n.authSignInGoogle,
                  onPressed: () => _handleOAuthSignIn(supa.OAuthProvider.google),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Email login outline button
    buttons.add(
      AnimatedOpacity(
        opacity: _oauthLoading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AuthOutlineButton(
          key: const ValueKey('signin_email_button'),
          text: l10n.authSignInEmail,
          icon: Icons.mail_outline,
          onPressed: _oauthLoading ? null : () => context.push(LoginScreen.routeName),
        ),
      ),
    );

    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(height: 12), // Figma: 12px gap
          buttons[i],
        ],
      ],
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
    } catch (error, stackTrace) {
      // Report error for diagnostics
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'auth_signin_screen',
        context: ErrorDescription('OAuth sign-in failed: ${provider.name}'),
      ));

      // Show provider-specific user-facing error snackbar
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
}
