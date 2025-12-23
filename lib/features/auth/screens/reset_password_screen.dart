import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/state/reset_password_state.dart';
import 'package:luvi_app/features/auth/state/reset_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/auth_linear_gradient_background.dart';
import 'package:luvi_app/features/auth/widgets/auth_shell.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// ResetPasswordScreen with Figma Auth UI v2 design.
///
/// Figma Node: 68919:8822
/// Route: /auth/reset
///
/// Features:
/// - Linear gradient background
/// - Back button navigation
/// - Title + Subtitle explaining the process
/// - Email field only
/// - Pink CTA button (56px height)
class ResetPasswordScreen extends ConsumerStatefulWidget {
  static const String routeName = '/auth/reset';

  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  ProviderSubscription<ResetPasswordState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current state value
    final state = ref.read(resetPasswordProvider);
    if (state.email.isNotEmpty) {
      _emailController.text = state.email;
    }

    // Listen for external state changes and sync controller
    // This avoids controller mutation inside build()
    _stateSubscription = ref.listenManual(resetPasswordProvider, (prev, next) {
      if (!mounted) return;
      if (_emailController.text != next.email) {
        _emailController.value = _emailController.value.copyWith(
          text: next.email,
          selection: TextSelection.collapsed(offset: next.email.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.close();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final state = ref.watch(resetPasswordProvider);
    final submitState = ref.watch(resetSubmitProvider);

    // Map specific error types to localized messages for extensibility
    final errorText = _errorTextFor(state.error, l10n);

    // Figma: Title style - Playfair Display Bold, 24px
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: AuthTypography.titleFontSize,
      height: AuthTypography.titleLineHeight,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );

    // Figma: Subtitle style - Figtree Regular, 16px, line-height 24px
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: Sizes.authSubtitleFontSize,
      height: Sizes.authSubtitleLineHeight,
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      key: const ValueKey('auth_reset_screen'),
      resizeToAvoidBottomInset: true,
      body: AuthShell(
        background: const AuthLinearGradientBackground(),
        showBackButton: true,
        onBackPressed: () {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            router.go(AuthSignInScreen.routeName);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gap after back button
            const SizedBox(height: AuthLayout.backButtonToTitle),

            // Title: "Passwort vergessen?"
            Text(
              l10n.authResetTitle,
              key: const ValueKey('reset_title'),
              style: titleStyle,
            ),

            // Figma: Gap = 8px between title and subtitle
            const SizedBox(height: Spacing.xs),

            // Subtitle explaining the process
            Text(
              l10n.authResetSubtitle,
              style: subtitleStyle,
            ),

            // Gap between subtitle and input (32px)
            const SizedBox(height: AuthLayout.ctaTopAfterCopy),

            // Email field
            LoginEmailField(
              key: const ValueKey('reset_email_field'),
              controller: _emailController,
              errorText: errorText,
              autofocus: false,
              onChanged: (value) =>
                  ref.read(resetPasswordProvider.notifier).setEmail(value),
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              textInputAction: TextInputAction.done,
            ),

            // Gap before CTA (40px)
            const SizedBox(height: AuthLayout.inputToCta),

            // CTA Button - Figma: h=56px
            SizedBox(
              width: double.infinity,
              height: Sizes.buttonHeightL,
              child: WelcomeButton(
                key: const ValueKey('reset_cta'),
                onPressed: state.isValid && !submitState.isLoading
                    ? () async {
                        await ref.read(resetSubmitProvider.notifier).submit(
                              state.email,
                              onSuccess: () async {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.authResetEmailSent),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                // Brief delay to ensure user sees feedback before navigation
                                await Future<void>.delayed(const Duration(milliseconds: 300));
                                if (!context.mounted) return;
                                context.go(AuthSignInScreen.routeName);
                              },
                            );
                      }
                    : null,
                isLoading: submitState.isLoading,
                label: l10n.authResetCta,
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

/// Maps [ResetPasswordError] to localized user-facing messages.
///
/// Explicit switch ensures compile-time exhaustiveness check when new
/// error types are added to [ResetPasswordError].
String? _errorTextFor(ResetPasswordError? error, AppLocalizations l10n) {
  if (error == null) return null;

  switch (error) {
    case ResetPasswordError.invalidEmail:
      return l10n.authErrEmailInvalid;
  }
}
