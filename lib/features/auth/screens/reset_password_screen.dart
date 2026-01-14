import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/timing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/state/reset_password_state.dart';
import 'package:luvi_app/features/auth/state/reset_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_back_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rainbow_background.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_field.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Reset password screen with Auth Rebrand v3 design (export-parity).
///
/// Features:
/// - Rainbow background with arcs and stripes
/// - Content card with headline, subtitle, and email field
/// - Subtitle: "E-Mail Adresse eingeben und erhalte einen Link zum Zurücksetzen."
/// - Pink CTA button "Zurücksetzen"
///
/// Route: /auth/reset
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
    final state = ref.read(resetPasswordProvider);
    if (state.email.isNotEmpty) {
      _emailController.text = state.email;
    }

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

    final state = ref.watch(resetPasswordProvider);
    final submitState = ref.watch(resetSubmitProvider);
    final errorText = _errorTextFor(state.error, l10n);
    final hasError = errorText != null;

    // Listen for submit errors and show snackbar (must be in build)
    ref.listen<AsyncValue<void>>(resetSubmitProvider, (prev, next) {
      if (!mounted) return;
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authResetErrorGeneric),
            backgroundColor: DsColors.authRebrandError,
            duration: Timing.snackBarBrief,
          ),
        );
      }
    });

    return Scaffold(
      key: const ValueKey('auth_reset_screen'),
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
                            router.go(AuthSignInScreen.routeName);
                          }
                        },
                        semanticsLabel: l10n.authBackSemantic,
                      ),
                    ),
                  ),

                  const SizedBox(height: AuthRebrandMetrics.contentTopGap),

                  // Content card (SSOT: form screens use 364px width)
                  AuthContentCard(
                    width: AuthRebrandMetrics.cardWidthForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Headline
                        Text(
                          l10n.authResetTitle,
                          style: const TextStyle(
                            fontFamily: FontFamilies.playfairDisplay,
                            fontSize: AuthRebrandMetrics.headlineFontSize,
                            fontWeight: FontWeight.w600,
                            height: AuthRebrandMetrics.headlineLineHeight,
                            color: DsColors.authRebrandTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Spacing.xs),

                        // Subtitle (SSOT: auth_password_reset.subtitle)
                        Text(
                          l10n.authResetPasswordSubtitle,
                          style: const TextStyle(
                            fontFamily: FontFamilies.figtree,
                            fontSize: AuthRebrandMetrics.bodyFontSize,
                            fontWeight: FontWeight.w400,
                            height: AuthRebrandMetrics.bodyLineHeight,
                            color: DsColors.authRebrandTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Spacing.m),

                        // Email field - IMPORTANT: Placeholder is "Deine E-Mail Adresse"
                        AuthRebrandTextField(
                          key: const ValueKey('reset_email_field'),
                          controller: _emailController,
                          hintText: l10n.authEmailPlaceholderLong,
                          errorText: errorText,
                          hasError: hasError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) =>
                              ref.read(resetPasswordProvider.notifier).setEmail(value),
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        ),

                        const SizedBox(height: Spacing.l),

                        // CTA button
                        AuthPrimaryButton(
                          key: const ValueKey('reset_cta'),
                          label: l10n.authResetCtaShort,
                          onPressed: state.isValid && !submitState.isLoading
                              ? () async {
                                  await ref.read(resetSubmitProvider.notifier).submit(
                                        state.email,
                                        onSuccess: () async {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(l10n.authResetEmailSent),
                                              duration: Timing.snackBarBrief,
                                            ),
                                          );
                                          await Future<void>.delayed(Timing.snackBarBrief);
                                          if (!context.mounted) return;
                                          context.go(AuthSignInScreen.routeName);
                                        },
                                      );
                                }
                              : null,
                          isLoading: submitState.isLoading,
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

String? _errorTextFor(ResetPasswordError? error, AppLocalizations l10n) {
  if (error == null) return null;

  switch (error) {
    case ResetPasswordError.invalidEmail:
      return l10n.authErrEmailInvalid;
  }
}
