import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/widgets/auth_linear_gradient_background.dart';
import 'package:luvi_app/features/auth/widgets/auth_shell.dart';
import 'package:luvi_app/features/auth/widgets/field_error_text.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SignupScreen with Figma Auth UI v2 design.
///
/// Note: No Figma spec exists - design based on LoginScreen layout.
/// Route: /auth/signup
///
/// Features:
/// - Linear gradient background (same as Login)
/// - Back button navigation
/// - Email + Password form (simplified from 5 fields to 2)
/// - Pink CTA button (56px height)
/// - "Schon dabei? Anmelden" link
class AuthSignupScreen extends ConsumerStatefulWidget {
  const AuthSignupScreen({super.key});

  static const String routeName = '/auth/signup';

  @override
  ConsumerState<AuthSignupScreen> createState() => _AuthSignupScreenState();
}

class _AuthSignupScreenState extends ConsumerState<AuthSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.authSignupMissingFields;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;
      // Show success message and navigate to login
      // Note: VerificationScreen was removed per Auth v2 refactoring plan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.authSignupSuccess),
        ),
      );
      context.go(LoginScreen.routeName);
    } on AuthException catch (error, stackTrace) {
      log.e(
        'signup_failed_auth',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      final message = error.message;
      setState(() {
        _errorMessage = message.isNotEmpty
            ? message
            : AppLocalizations.of(context)!.authSignupGenericError;
      });
    } catch (error, stackTrace) {
      log.e(
        'signup_failed',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.authSignupGenericError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;

    final hasError = _errorMessage != null;
    final canSubmit = !_isSubmitting;

    // Figma: Title style - Playfair Display Bold, 24px (same as Login)
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );

    // Link style for "Already have account?"
    final linkStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 24 / 16,
      color: theme.colorScheme.onSurface,
    );

    final linkActionStyle = linkStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: tokens.cardBorderSelected,
      decoration: TextDecoration.underline,
    );

    return Scaffold(
      key: const ValueKey('auth_signup_screen'),
      resizeToAvoidBottomInset: true,
      body: AuthShell(
        background: const AuthLinearGradientBackground(),
        showBackButton: true,
        onBackPressed: () {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gap after back button
            const SizedBox(height: AuthLayout.backButtonToTitle),

            // Title: "Konto erstellen"
            Text(
              l10n.authSignupTitle,
              style: titleStyle,
            ),

            // Gap between title and inputs
            const SizedBox(height: Spacing.l + Spacing.xs), // 32px

            // Email field
            LoginEmailField(
              key: const ValueKey('signup_email_field'),
              controller: _emailController,
              errorText: null,
              autofocus: true,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),

            // Gap between inputs = 20px
            const SizedBox(height: Spacing.goalCardVertical),

            // Password field
            LoginPasswordField(
              key: const ValueKey('signup_password_field'),
              controller: _passwordController,
              errorText: null,
              obscure: _obscurePassword,
              onToggleObscure: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              onSubmitted: (_) {
                if (canSubmit) _handleSignup();
              },
            ),

            // Error message
            if (hasError) ...[
              const SizedBox(height: Spacing.xs),
              FieldErrorText(_errorMessage!),
            ],

            // Gap before CTA
            const SizedBox(height: Spacing.l + Spacing.m), // 40px

            // CTA Button - Figma: h=56px
            SizedBox(
              width: double.infinity,
              height: Sizes.buttonHeightL,
              child: WelcomeButton(
                key: const ValueKey('signup_cta_button'),
                onPressed: canSubmit ? _handleSignup : null,
                isLoading: _isSubmitting,
                label: l10n.authSignupCta,
                loadingKey: const ValueKey('signup_cta_loading'),
                labelKey: const ValueKey('signup_cta_label'),
              ),
            ),

            // Gap before login link
            const SizedBox(height: Spacing.l),

            // "Schon dabei? Anmelden" link - centered
            Center(
              child: TextButton(
                key: const ValueKey('signup_login_link'),
                onPressed: () => context.push(LoginScreen.routeName),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(
                    Sizes.touchTargetMin,
                    Sizes.touchTargetMin,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.authSignupAlreadyMember,
                        style: linkStyle,
                      ),
                      TextSpan(
                        text: l10n.authSignupLoginLink,
                        style: linkActionStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom padding
            const SizedBox(height: Spacing.l),
          ],
        ),
      ),
    );
  }
}
