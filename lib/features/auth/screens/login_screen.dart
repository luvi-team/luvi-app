import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';

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
  final _ctaKey = GlobalKey();
  bool _shouldScroll = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
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

    final topSection = _buildTopSection(theme, tokens, loginState);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
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
                final ctaBox =
                    _ctaKey.currentContext?.findRenderObject() as RenderBox?;
                if (!mounted || topBox == null || ctaBox == null) {
                  return;
                }
                final totalHeight = topBox.size.height + ctaBox.size.height;
                final needsScroll = totalHeight > constraints.maxHeight + 0.5;
                if (needsScroll != _shouldScroll) {
                  setState(() => _shouldScroll = needsScroll);
                }
              });

              final shouldAllowScroll = _shouldScroll || isKeyboardVisible;
              final ctaSection = Padding(
                key: _ctaKey,
                padding: EdgeInsets.fromLTRB(
                  Spacing.l,
                  32,
                  Spacing.l,
                  safeBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: Sizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => ref
                            .read(loginProvider.notifier)
                            .validateAndSubmit(),
                        child: const Text('Anmelden'),
                      ),
                    ),
                    SizedBox(height: hasValidationError ? 29.0 : 31.0),
                    Center(
                      child: TextButton(
                        onPressed: () {}, // TODO: Navigate to sign up
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Neu bei LUVI? ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 214,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: 'Starte hier',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 17,
                                  height: 1.47,
                                  color: tokens.cardBorderSelected,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.s + Spacing.xs),
                  ],
                ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.l,
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
                  ctaSection,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(
    ThemeData theme,
    DsTokens tokens,
    LoginState loginState,
  ) {
    return Column(
      key: _topKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.l + Spacing.xs),
        _Header(theme: theme),
        const SizedBox(height: Spacing.l + Spacing.xs),
        _InputField(
          controller: _emailController,
          hintText: 'Deine E-Mail',
          errorText: loginState.emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          autofocus: true,
          theme: theme,
          tokens: tokens,
          onChanged: (v) {
            ref.read(loginProvider.notifier).setEmail(v);
            if (loginState.emailError != null) {
              ref.read(loginProvider.notifier).clearErrors();
            }
          },
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
        _InputField(
          controller: _passwordController,
          hintText: 'Dein Passwort',
          errorText: loginState.passwordError,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          theme: theme,
          tokens: tokens,
          onChanged: (v) {
            ref.read(loginProvider.notifier).setPassword(v);
            if (loginState.passwordError != null) {
              ref.read(loginProvider.notifier).clearErrors();
            }
          },
          suffixIcon: Semantics(
            label: _obscurePassword
                ? 'Passwort anzeigen'
                : 'Passwort ausblenden',
            button: true,
            child: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 105),
                size: Spacing.l,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {}, // TODO: Navigate to forgot password
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Passwort vergessen?',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 105),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.l + Spacing.xs),
        _SocialSection(theme: theme),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final ThemeData theme;
  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Willkommen zurück',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Willkommen zurück 💜',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 32,
              height: 1.25,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Schön, dass du da bist.',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              height: 1.33,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ThemeData theme;
  final DsTokens tokens;
  final ValueChanged<String> onChanged;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final bool autofocus;

  const _InputField({
    required this.controller,
    required this.hintText,
    required this.errorText,
    required this.theme,
    required this.tokens,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.autofillHints,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: Sizes.buttonHeight,
          decoration: BoxDecoration(
            color: tokens.cardSurface,
            borderRadius: BorderRadius.circular(Sizes.radiusM),
            border: Border.all(
              color: errorText != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.outlineVariant.withValues(alpha: 219),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            autofocus: autofocus,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 105),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: Spacing.m,
                right: suffixIcon != null ? Spacing.xs : Spacing.m,
                top: Spacing.s,
                bottom: Spacing.s,
              ),
              suffixIcon: suffixIcon,
            ),
            onChanged: onChanged,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: Spacing.s - Spacing.xs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _SocialSection extends StatelessWidget {
  final ThemeData theme;
  const _SocialSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 224),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
              child: Text(
                'Oder melde dich an mit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 20,
                  height: 1.2,
                  color: theme.colorScheme.onSurface.withValues(alpha: 214),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 224),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.l + Spacing.xs),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                theme: theme,
                onPressed: () {}, // TODO: Google sign-in
                svgAsset: 'assets/icons/google_g.svg',
              ),
            ),
            const SizedBox(width: Spacing.s + Spacing.xs),
            Expanded(
              child: _SocialButton(
                icon: Icons.apple,
                label: 'Apple',
                theme: theme,
                onPressed: () {}, // TODO: Apple sign-in
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final ThemeData theme;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.theme,
    required this.onPressed,
    this.icon,
    this.svgAsset,
  }) : assert(
         icon != null || svgAsset != null,
         'Provide either an icon or an SVG asset for SocialButton',
       );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Sizes.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.colorScheme.onPrimary,
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 245),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radiusXL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgAsset != null) ...[
              Padding(
                padding: const EdgeInsets.only(right: Spacing.xs),
                child: SizedBox(
                  height: Spacing.l,
                  width: Spacing.l,
                  child: SvgPicture.asset(svgAsset!, fit: BoxFit.contain),
                ),
              ),
            ] else if (icon != null) ...[
              Icon(icon, size: Spacing.l, color: theme.colorScheme.onSurface),
              const SizedBox(width: Spacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 17,
                height: 1.47,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
