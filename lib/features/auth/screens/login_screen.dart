import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/login_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/login_cta_section.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_forgot_button.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/auth/widgets/social_auth_row.dart';
import 'package:luvi_app/features/auth/widgets/login_header.dart';
import 'package:luvi_app/features/auth/widgets/global_error_banner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// LoginScreen with pixel-perfect Figma implementation.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

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
    final s = ref.read(loginProvider);
    if (_emailController.text != s.email) {
      _emailController.value = _emailController.value.copyWith(
        text: s.email,
        selection: TextSelection.collapsed(offset: s.email.length),
      );
    }
    if (_passwordController.text != s.password) {
      _passwordController.value = _passwordController.value.copyWith(
        text: s.password,
        selection: TextSelection.collapsed(offset: s.password.length),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errors = ref.watch(
      loginProvider.select(
        (state) => (state.emailError, state.passwordError, state.globalError),
      ),
    );
    final emailError = errors.$1;
    final passwordError = errors.$2;
    final globalError = errors.$3;
    final submitState = ref.watch(loginSubmitProvider);
    final isLoading = submitState.isLoading;

    final hasValidationError = emailError != null || passwordError != null;

    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.padding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardInset > 0;

    final fieldScrollPadding = EdgeInsets.only(
      // Reserve unterhalb der Felder: CTA + Social-Block + Footer + safeBottom
      bottom: AuthLayout.inlineCtaReserveLoginApprox + safeBottom,
    );
    final gapBelowForgot = isKeyboardVisible
        ? Spacing.m
        : Spacing.l + Spacing.xs;
    final socialGap = isKeyboardVisible ? Spacing.m : Spacing.l + Spacing.xs;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(Spacing.l, 0, Spacing.l, safeBottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LoginHeaderSection(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      emailError: emailError,
                      passwordError: passwordError,
                      obscurePassword: _obscurePassword,
                      fieldScrollPadding: fieldScrollPadding,
                      onEmailChanged: _onEmailChanged,
                      onPasswordChanged: _onPasswordChanged,
                      onToggleObscure: _toggleObscurePassword,
                      onForgotPassword: () => context.go('/auth/forgot'),
                      onSubmit: _handleSubmit,
                    ),
                    _LoginFormSection(
                      gapBelowForgot: gapBelowForgot,
                      socialGap: socialGap,
                      onGoogle: () {},
                      onApple: () {},
                    ),
                    if (globalError != null) ...[
                      const SizedBox(height: Spacing.m),
                      GlobalErrorBanner(message: globalError),
                    ],
                    // TODO(ui): Extract _handleSubmit() to reduce nesting; identical validation/network flow.
                    _LoginCtaSection(
                      isLoading: isLoading,
                      hasValidationError: hasValidationError,
                      onSubmit: () => _handleSubmit(),
                      onSignup: () => context.go('/auth/signup'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onEmailChanged(String value) {
    final notifier = ref.read(loginProvider.notifier);
    notifier.setEmail(value);
    final state = ref.read(loginProvider);
    if (state.globalError != null) {
      notifier.clearGlobalError();
    }
  }

  void _onPasswordChanged(String value) {
    final notifier = ref.read(loginProvider.notifier);
    notifier.setPassword(value);
    final state = ref.read(loginProvider);
    if (state.globalError != null) {
      notifier.clearGlobalError();
    }
  }

  void _toggleObscurePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Future<void> _handleSubmit() async {
    final notifier = ref.read(loginProvider.notifier);
    notifier.validateAndSubmit();
    final state = ref.read(loginProvider);
    final hasLocalErrors =
        state.emailError != null || state.passwordError != null;
    if (hasLocalErrors) {
      return;
    }

    final submitNotifier = ref.read(loginSubmitProvider.notifier);
    try {
      await submitNotifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      notifier.clearGlobalError();
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid') || msg.contains('credentials')) {
        notifier.updateState(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          emailError: 'E-Mail oder Passwort ist falsch.',
          passwordError: null,
          globalError: null,
        );
      } else if (msg.contains('confirm')) {
        notifier.updateState(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          emailError: null,
          passwordError: null,
          globalError: 'Bitte E-Mail bestätigen (Link erneut senden?)',
        );
      } else {
        notifier.updateState(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          emailError: null,
          passwordError: null,
          globalError: 'Login derzeit nicht möglich.',
        );
      }
    }
  }
}

class _LoginHeaderSection extends StatelessWidget {
  const _LoginHeaderSection({
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.obscurePassword,
    required this.fieldScrollPadding,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onToggleObscure,
    required this.onForgotPassword,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;
  final EdgeInsets fieldScrollPadding;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.l + Spacing.xs),
        const LoginHeader(),
        const SizedBox(height: Spacing.l + Spacing.xs),
        LoginEmailField(
          controller: emailController,
          errorText: emailError,
          autofocus: true,
          scrollPadding: fieldScrollPadding,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
        LoginPasswordField(
          controller: passwordController,
          errorText: passwordError,
          obscure: obscurePassword,
          scrollPadding: fieldScrollPadding,
          onToggleObscure: onToggleObscure,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: Spacing.xs),
        LoginForgotButton(onPressed: onForgotPassword),
      ],
    );
  }
}

class _LoginFormSection extends StatelessWidget {
  const _LoginFormSection({
    required this.gapBelowForgot,
    required this.socialGap,
    required this.onGoogle,
    required this.onApple,
  });

  final double gapBelowForgot;
  final double socialGap;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: gapBelowForgot),
        SocialAuthRow(
          onGoogle: onGoogle,
          onApple: onApple,
          dividerToButtonsGap: socialGap,
        ),
      ],
    );
  }
}

class _LoginCtaSection extends StatelessWidget {
  const _LoginCtaSection({
    required this.isLoading,
    required this.hasValidationError,
    required this.onSubmit,
    required this.onSignup,
  });

  final bool isLoading;
  final bool hasValidationError;
  final VoidCallback onSubmit;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AuthLayout.ctaTopAfterCopy),
        LoginCtaSection(
          onSubmit: onSubmit,
          onSignup: onSignup,
          hasValidationError: hasValidationError,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
