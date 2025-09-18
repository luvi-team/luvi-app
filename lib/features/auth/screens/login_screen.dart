import 'dart:math' as math;

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
import 'package:luvi_app/features/widgets/login_header.dart';
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
  final _topKey = GlobalKey();
  bool _shouldScroll = false;
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
    final keyboardOffset = math.max(keyboardInset - safeBottom, 0.0);

    final topSection = _buildTopSection(context, loginState);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardOffset),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isKeyboardVisible = keyboardInset > 0;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                final topBox =
                    _topKey.currentContext?.findRenderObject() as RenderBox?;
                if (!mounted || topBox == null) {
                  return;
                }
                final needsScroll =
                    topBox.size.height > constraints.maxHeight + 0.5;
                if (needsScroll != _shouldScroll) {
                  setState(() => _shouldScroll = needsScroll);
                }
              });

              final shouldAllowScroll = _shouldScroll || isKeyboardVisible;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        AuthLayout.horizontalPadding,
                        0,
                        AuthLayout.horizontalPadding,
                        AuthLayout.ctaBottomInset + safeBottom,
                      ),
                      physics: shouldAllowScroll
                          ? const ClampingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      shrinkWrap: !shouldAllowScroll,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      primary: false,
                      children: [topSection],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AuthLayout.horizontalPadding,
              AuthLayout.ctaTopAfterCopy,
              AuthLayout.horizontalPadding,
              Spacing.s,
            ),
            child: LoginCtaSection(
              onSubmit: () async {
                if (_isLoading) return;
                // 1) Validate inputs first and show local validation errors
                final notifier = ref.read(loginProvider.notifier);
                notifier.validateAndSubmit();
                final state = ref.read(loginProvider);
                final hasLocalErrors =
                    state.emailError != null || state.passwordError != null;
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
                  if (msg.contains('invalid') || msg.contains('credentials')) {
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, LoginState loginState) {
    return Column(
      key: _topKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.l + Spacing.xs),
        const LoginHeader(),
        const SizedBox(height: Spacing.l + Spacing.xs),
        LoginEmailField(
          controller: _emailController,
          errorText: loginState.emailError,
          autofocus: true,
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
        LoginForgotButton(onPressed: () => context.go('/auth/forgot')),
        const SizedBox(height: Spacing.l + Spacing.xs),
        SocialAuthRow(
          onGoogle: () {}, // TODO: Google sign-in
          onApple: () {}, // TODO: Apple sign-in
        ),
      ],
    );
  }
}
