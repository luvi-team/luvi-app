import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/login_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/global_error_banner.dart';
import 'package:luvi_app/features/auth/widgets/login_cta_section.dart';
import 'package:luvi_app/features/auth/widgets/login_form_section.dart';
import 'package:luvi_app/features/auth/widgets/login_header_section.dart';
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
    final fieldScrollPadding = EdgeInsets.only(
      // Reserve unterhalb der Felder: CTA + Social-Block + Footer + safeBottom
      bottom: AuthLayout.inlineCtaReserveLoginApprox + safeBottom,
    );
    const gapBelowForgot = Spacing.m;
    const socialGap = Spacing.m;

    return Scaffold(
      key: const ValueKey('auth_login_screen'),
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => _buildScrollableBody(
                  context: context,
                  constraints: constraints,
                  fieldScrollPadding: fieldScrollPadding,
                  safeBottom: safeBottom,
                  gapBelowForgot: gapBelowForgot,
                  socialGap: socialGap,
                  globalError: globalError,
                  emailError: emailError,
                  passwordError: passwordError,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.l,
                0,
                Spacing.l,
                safeBottom,
              ),
              child: LoginCtaSection(
                onSubmit: _handleSubmit,
                onSignup: () => context.goNamed('signup'),
                hasValidationError: hasValidationError,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableBody({
    required BuildContext context,
    required BoxConstraints constraints,
    required EdgeInsets fieldScrollPadding,
    required double safeBottom,
    required double gapBelowForgot,
    required double socialGap,
    required String? globalError,
    required String? emailError,
    required String? passwordError,
  }) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(Spacing.l, 0, Spacing.l, safeBottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoginHeaderSection(
              emailController: _emailController,
              passwordController: _passwordController,
              emailError: emailError,
              passwordError: passwordError,
              obscurePassword: _obscurePassword,
              fieldScrollPadding: fieldScrollPadding,
              onEmailChanged: _onEmailChanged,
              onPasswordChanged: _onPasswordChanged,
              onToggleObscure: _toggleObscurePassword,
              onForgotPassword: () => context.goNamed('forgot'),
              onSubmit: _handleSubmit,
            ),
            LoginFormSection(
              gapBelowForgot: gapBelowForgot,
              socialGap: socialGap,
              onGoogle: () {},
              onApple: () {},
            ),
            if (globalError != null) ...[
              const SizedBox(height: Spacing.m),
              GlobalErrorBanner(
                message: globalError,
                onTap: () =>
                    ref.read(loginProvider.notifier).clearGlobalError(),
              ),
            ],
            const SizedBox(height: AuthLayout.ctaTopAfterCopy),
          ],
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
          globalError: AuthStrings.errConfirmEmail,
        );
      } else {
        notifier.updateState(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          emailError: null,
          passwordError: null,
          globalError: AuthStrings.errLoginUnavailable,
        );
      }
    }
  }
}
