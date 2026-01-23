import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/timing.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/features/auth/state/reset_password_state.dart';
import 'package:luvi_app/features/auth/utils/auth_navigation_helpers.dart';
import 'package:luvi_app/features/auth/state/reset_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_scaffold.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_field.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_styles.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  ProviderSubscription<AsyncValue<void>>? _submitSubscription;
  bool _didSetupSubmitListener = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Setup submit error listener here (not initState) because it accesses
    // context-dependent APIs (ScaffoldMessenger, AppLocalizations).
    if (!_didSetupSubmitListener) {
      _didSetupSubmitListener = true;
      _submitSubscription = ref.listenManual<AsyncValue<void>>(
        resetSubmitProvider,
        (prev, next) {
          if (!mounted) return;
          if (next.hasError && !next.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.authResetErrorGeneric),
                backgroundColor: DsColors.authRebrandError,
                duration: Timing.snackBarBrief,
              ),
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _submitSubscription?.close();
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
    final canSubmit = state.isValid && !submitState.isLoading;

    // NOTE: Submit error listener in didChangeDependencies for safe context access

    return AuthRebrandScaffold(
      scaffoldKey: const ValueKey('auth_reset_screen'),
      compactKeyboard: true, // Fewer fields = compact padding
      onBack: () => handleAuthBackNavigation(context),
      child: _buildFormCard(
        l10n: l10n,
        state: state,
        errorText: errorText,
        hasError: hasError,
        canSubmit: canSubmit,
        isLoading: submitState.isLoading,
      ),
    );
  }

  Widget _buildFormCard({
    required AppLocalizations l10n,
    required ResetPasswordState state,
    required String? errorText,
    required bool hasError,
    required bool canSubmit,
    required bool isLoading,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthContentCard(
          width: AuthRebrandMetrics.cardWidthForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.authResetTitle,
                style: AuthRebrandTextStyles.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.authResetPasswordSubtitle,
                style: AuthRebrandTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.m),
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
              AuthPrimaryButton(
                key: const ValueKey('reset_cta'),
                label: l10n.authResetCtaShort,
                onPressed: canSubmit ? () => _submitReset(state.email, l10n) : null,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitReset(String email, AppLocalizations l10n) async {
    try {
      await ref.read(resetSubmitProvider.notifier).submit(
            email,
            onSuccess: () {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.authResetEmailSent),
                  duration: Timing.snackBarBrief,
                ),
              );
              context.go(RoutePaths.authSignIn);
            },
          );
    } catch (e, st) {
      // Errors surfaced via submitState listener in didChangeDependencies.
      // Catch prevents unhandled exception in async callback.
      if (e is AuthException) {
        // Log AuthException at debug level for observability (aids debugging new Supabase codes)
        log.d(
          'reset_password_auth_exception: code=${e.code ?? "null"}, message=${sanitizeError(e) ?? "[redacted]"}',
          tag: 'reset_password',
        );
      } else {
        // Unexpected errors: log at warning level
        log.w('reset_password_unexpected', error: e, stack: st);
      }
    }
  }
}

String? _errorTextFor(ResetPasswordError? error, AppLocalizations l10n) {
  if (error == null) return null;

  switch (error) {
    case ResetPasswordError.invalidEmail:
      return l10n.authErrEmailInvalid;
  }
}
