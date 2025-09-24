import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/widgets/login_cta_section.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_forgot_button.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/auth/widgets/social_auth_row.dart';
import 'package:luvi_app/features/auth/widgets/login_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luvi_app/features/state/auth_controller.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    if (_emailController.text != loginState.email) {
      _emailController.text = loginState.email;
    }
    if (_passwordController.text != loginState.password) {
      _passwordController.text = loginState.password;
    }

    final hasValidationError =
        loginState.emailError != null || loginState.passwordError != null;

    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.padding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardInset > 0;

    final fieldScrollPadding = EdgeInsets.only(
      // Reserve unterhalb der Felder: CTA + Social-Block + Footer + safeBottom
      bottom: AuthLayout.inlineCtaReserveLogin + safeBottom,
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
                    const SizedBox(height: Spacing.l + Spacing.xs),
                    const LoginHeader(),
                    const SizedBox(height: Spacing.l + Spacing.xs),
                    LoginEmailField(
                      controller: _emailController,
                      errorText: loginState.emailError,
                      autofocus: true,
                      scrollPadding: fieldScrollPadding,
                      onChanged: (v) {
                        ref.read(loginProvider.notifier).setEmail(v);
                        if (loginState.emailError != null) {
                          ref.read(loginProvider.notifier).clearErrors();
                        }
                      },
                    ),
                    const SizedBox(height: Spacing.s + Spacing.xs),
                    LoginPasswordField(
                      controller: _passwordController,
                      errorText: loginState.passwordError,
                      obscure: _obscurePassword,
                      scrollPadding: fieldScrollPadding,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onChanged: (v) {
                        ref.read(loginProvider.notifier).setPassword(v);
                        if (loginState.passwordError != null) {
                          ref.read(loginProvider.notifier).clearErrors();
                        }
                      },
                    ),
                    const SizedBox(height: Spacing.xs),
                    LoginForgotButton(
                      onPressed: () => context.go('/auth/forgot'),
                    ),
                    SizedBox(height: gapBelowForgot),
                    SocialAuthRow(
                      onGoogle: () {}, // TODO: Google sign-in
                      onApple: () {}, // TODO: Apple sign-in
                      dividerToButtonsGap: socialGap,
                    ),
                    const SizedBox(height: AuthLayout.ctaTopAfterCopy),
                    LoginCtaSection(
                      onSubmit: () async {
                        if (_isLoading) return;
                        // 1) Validate inputs first and show local validation errors
                        final notifier = ref.read(loginProvider.notifier);
                        notifier.validateAndSubmit();
                        final state = ref.read(loginProvider);
                        final hasLocalErrors =
                            state.emailError != null ||
                            state.passwordError != null;
                        if (hasLocalErrors) {
                          return;
                        }

                        setState(() => _isLoading = true);
                        try {
                          // 2) No local errors -> attempt sign-in
                          final repo = ref.read(authRepositoryProvider);
                          await repo.signInWithPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                          // Happy path: Router-Redirect greift automatisch
                          notifier.clearErrors();
                        } on AuthException catch (e) {
                          final msg = e.message.toLowerCase();
                          if (msg.contains('invalid') ||
                              msg.contains('credentials')) {
                            notifier.updateState(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              emailError: 'E-Mail oder Passwort ist falsch.',
                              passwordError: null,
                            );
                          } else if (msg.contains('confirm')) {
                            notifier.updateState(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              emailError:
                                  'Bitte E-Mail bestätigen (Link erneut senden?)',
                              passwordError: null,
                            );
                          } else {
                            notifier.updateState(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              emailError: 'Login derzeit nicht möglich.',
                              passwordError: null,
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      onSignup: () => context.go('/auth/signup'),
                      hasValidationError: hasValidationError,
                      isLoading: _isLoading,
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
}
