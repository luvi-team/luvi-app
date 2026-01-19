import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/auth/utils/auth_navigation_helpers.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/login_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_error_banner.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_scaffold.dart';
import 'package:luvi_app/features/auth/widgets/password_visibility_toggle_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_field.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_styles.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Login screen with Auth Rebrand v3 design.
///
/// Features:
/// - Rainbow background with arcs and stripes
/// - Content card with headline and form
/// - Email + Password fields with error states
/// - Pink CTA button
/// - "Passwort vergessen?" link
/// - "Neu bei LUVI? Hier starten" link
///
/// Route: /auth/login
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/auth/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final loginNotifier = ref.read(loginProvider.notifier);
    final initialState = loginNotifier.currentState;
    // Prefill email from state (allowed - not sensitive)
    if (_emailController.text != initialState.email) {
      _emailController.value = _emailController.value.copyWith(
        text: initialState.email,
        selection: TextSelection.collapsed(offset: initialState.email.length),
      );
    }
    // SECURITY: Don't prefill password from state - password should only
    // live in TextEditingController, not be persisted in provider state.
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final loginAsync = ref.watch(loginProvider);
    final loginState = loginAsync.value ?? LoginState.initial();
    final submitState = ref.watch(loginSubmitProvider);
    final isLoading = submitState.isLoading;

    return AuthRebrandScaffold(
      scaffoldKey: const ValueKey('auth_login_screen'),
      onBack: () => handleAuthBackNavigation(context),
      child: _buildContent(l10n: l10n, loginState: loginState, isLoading: isLoading),
    );
  }

  Widget _buildContent({
    required AppLocalizations l10n,
    required LoginState loginState,
    required bool isLoading,
  }) {
    final globalError = loginState.globalError;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (globalError != null) AuthErrorBanner(message: globalError),
        _buildFormCard(l10n: l10n, loginState: loginState, isLoading: isLoading),
      ],
    );
  }

  Widget _buildFormCard({
    required AppLocalizations l10n,
    required LoginState loginState,
    required bool isLoading,
  }) {
    final hasEmailError = loginState.emailError != null;
    final hasPasswordError = loginState.passwordError != null;

    return AuthContentCard(
      width: AuthRebrandMetrics.cardWidthForm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.authLoginTitle,
            style: AuthRebrandTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.m),
          AuthRebrandTextField(
            key: const ValueKey('login_email_field'),
            controller: _emailController,
            hintText: l10n.authEmailPlaceholderLong,
            errorText: hasEmailError ? l10n.authErrorEmailCheck : null,
            hasError: hasEmailError,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: _onEmailChanged,
          ),
          const SizedBox(height: AuthRebrandMetrics.cardInputGap),
          AuthRebrandTextField(
            key: const ValueKey('login_password_field'),
            controller: _passwordController,
            hintText: l10n.authPasswordPlaceholder,
            errorText: hasPasswordError ? l10n.authErrorPasswordCheck : null,
            hasError: hasPasswordError,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onChanged: _onPasswordChanged,
            onSubmitted: (_) => _submit(),
            suffixIcon: PasswordVisibilityToggleButton(
              obscured: _obscurePassword,
              onPressed: _toggleObscurePassword,
              color: DsColors.grayscale500,
              size: AuthRebrandMetrics.passwordToggleIconSize,
            ),
          ),
          const SizedBox(height: Spacing.m),
          AuthPrimaryButton(
            key: const ValueKey('login_cta_button'),
            loadingKey: const ValueKey('login_cta_loading'),
            label: l10n.authEntryCta,
            onPressed: isLoading ? null : _submit,
            isLoading: isLoading,
          ),
          const SizedBox(height: Spacing.m),
          _buildForgotLink(l10n),
        ],
      ),
    );
  }

  Widget _buildForgotLink(AppLocalizations l10n) {
    // A11y: TextButton for proper focus/ripple and 44dp touch target
    return TextButton(
      key: const ValueKey('login_forgot_link'),
      onPressed: () => context.push(ResetPasswordScreen.routeName),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, Sizes.touchTargetMin), // ✅ 44dp
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Pixel-parity
        padding: EdgeInsets.zero,
        foregroundColor: DsColors.grayscale500,
      ),
      child: Text(
        l10n.authLoginForgot,
        style: TextStyle(
          fontFamily: FontFamilies.figtree,
          fontSize: AuthRebrandMetrics.dividerTextFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _onEmailChanged(String value) {
    final notifier = ref.read(loginProvider.notifier);
    notifier.setEmail(value);
    final state = ref.read(loginProvider).value;
    if (state?.globalError != null) {
      notifier.clearGlobalError();
    }
  }

  void _onPasswordChanged(String value) {
    // SECURITY: Don't store password in provider state.
    // Password is read directly from controller at submit time.
    final notifier = ref.read(loginProvider.notifier);
    final state = ref.read(loginProvider).value;
    if (state?.globalError != null) {
      notifier.clearGlobalError();
    }
    // Clear password error when user starts typing
    if (state?.passwordError != null) {
      notifier.updateState(passwordError: null);
    }
  }

  void _toggleObscurePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _submit() {
    final submitNotifier = ref.read(loginSubmitProvider.notifier);
    if (ref.read(loginSubmitProvider).isLoading) return;
    submitNotifier.submit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}
