import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/timing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_back_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rainbow_background.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_field.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Signup screen with Auth Rebrand v3 design.
///
/// Features:
/// - Rainbow background with arcs and stripes
/// - Content card with headline and form
/// - Email + Password fields
/// - Pink CTA button
/// - "Schon dabei? Anmelden" link
///
/// Route: /auth/signup
class AuthSignupScreen extends ConsumerStatefulWidget {
  const AuthSignupScreen({super.key});

  static const String routeName = '/auth/signup';

  @override
  ConsumerState<AuthSignupScreen> createState() => _AuthSignupScreenState();
}

class _AuthSignupScreenState extends ConsumerState<AuthSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Timer? _signupNavTimer;

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _emailError = false;
  bool _passwordError = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signupNavTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final l10n = AppLocalizations.of(context)!;

    // Validate fields
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _emailError = email.isEmpty;
        _passwordError = password.isEmpty;
        _errorMessage = l10n.authSignupMissingFields;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _emailError = false;
      _passwordError = false;
    });

    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authSignupSuccess),
          duration: Timing.snackBarBrief,
        ),
      );

      _signupNavTimer?.cancel();
      _signupNavTimer = Timer(Timing.snackBarBrief, () {
        if (!mounted) return;
        context.go(LoginScreen.routeName);
      });
    } on AuthException catch (error, stackTrace) {
      log.e(
        'signup_failed_auth',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;

      // Map error codes to user-friendly messages
      final message = _mapAuthError(error, l10n);
      setState(() {
        _errorMessage = message;
        _emailError = true;
      });
    } catch (error, stackTrace) {
      log.e(
        'signup_failed',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = l10n.authSignupGenericError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _mapAuthError(AuthException error, AppLocalizations l10n) {
    // Map common Supabase auth errors to user-friendly messages
    final message = error.message.toLowerCase();
    if (message.contains('email') && message.contains('invalid')) {
      return l10n.authErrEmailInvalid;
    }
    if (message.contains('password') && message.contains('short')) {
      return l10n.authErrPasswordTooShort;
    }
    if (message.contains('already') || message.contains('exists')) {
      return l10n.authErrConfirmEmail;
    }
    return l10n.authSignupGenericError;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: const ValueKey('auth_signup_screen'),
      backgroundColor: DsColors.authRebrandBackground,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Rainbow background
          const Positioned.fill(
            child: AuthRainbowBackground(),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AuthRebrandMetrics.backButtonLeft,
                        top: AuthRebrandMetrics.backButtonTop,
                      ),
                      child: AuthBackButton(
                        onPressed: () {
                          final router = GoRouter.of(context);
                          if (router.canPop()) {
                            router.pop();
                          } else {
                            context.go(AuthSignInScreen.routeName);
                          }
                        },
                        semanticsLabel: l10n.authBackSemantic,
                      ),
                    ),
                  ),

                  const SizedBox(height: AuthRebrandMetrics.contentTopGap),

                  // Global error banner (consistent with LoginScreen)
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                      child: Container(
                        padding: const EdgeInsets.all(Spacing.s),
                        margin: const EdgeInsets.only(bottom: Spacing.m),
                        decoration: BoxDecoration(
                          color: DsColors.authRebrandError.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Sizes.radiusS),
                          border: Border.all(
                            color: DsColors.authRebrandError,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontFamily: FontFamilies.figtree,
                            fontSize: AuthRebrandMetrics.errorTextFontSize,
                            color: DsColors.authRebrandError,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Content card (SSOT: form screens use 364px width)
                  AuthContentCard(
                    width: AuthRebrandMetrics.cardWidthForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Headline
                        Text(
                          l10n.authRegisterEmailTitle,
                          style: const TextStyle(
                            fontFamily: FontFamilies.playfairDisplay,
                            fontSize: AuthRebrandMetrics.headlineFontSize,
                            fontWeight: FontWeight.w600,
                            height: AuthRebrandMetrics.headlineLineHeight,
                            color: DsColors.authRebrandTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Spacing.l),

                        // Email field
                        AuthRebrandTextField(
                          key: const ValueKey('signup_email_field'),
                          controller: _emailController,
                          hintText: l10n.authEmailPlaceholderLong,
                          errorText: _emailError ? l10n.authErrorEmailCheck : null,
                          hasError: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_errorMessage != null || _emailError) {
                              setState(() {
                                _errorMessage = null;
                                _emailError = false;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: AuthRebrandMetrics.cardInputGap),

                        // Password field
                        AuthRebrandTextField(
                          key: const ValueKey('signup_password_field'),
                          controller: _passwordController,
                          hintText: l10n.authPasswordPlaceholder,
                          errorText: _passwordError ? l10n.authErrorPasswordCheck : null,
                          hasError: _passwordError,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            if (_errorMessage != null || _passwordError) {
                              setState(() {
                                _errorMessage = null;
                                _passwordError = false;
                              });
                            }
                          },
                          onSubmitted: (_) {
                            if (!_isSubmitting) _handleSignup();
                          },
                          suffixIcon: Semantics(
                            button: true,
                            label: _obscurePassword
                                ? l10n.authShowPassword
                                : l10n.authHidePassword,
                            child: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: DsColors.grayscale500,
                                size: AuthRebrandMetrics.passwordToggleIconSize,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: Spacing.l),

                        // CTA button (no login link per SSOT)
                        AuthPrimaryButton(
                          key: const ValueKey('signup_cta_button'),
                          loadingKey: const ValueKey('signup_cta_loading'),
                          label: l10n.authEntryCta,
                          onPressed: _isSubmitting ? null : _handleSignup,
                          isLoading: _isSubmitting,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AuthRebrandMetrics.contentBottomGap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
