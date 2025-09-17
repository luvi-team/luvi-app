import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

class AuthSignupScreen extends ConsumerStatefulWidget {
  const AuthSignupScreen({super.key});

  @override
  ConsumerState<AuthSignupScreen> createState() => _AuthSignupScreenState();
}

class _AuthSignupScreenState extends ConsumerState<AuthSignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _topKey = GlobalKey();
  final _ctaKey = GlobalKey();

  bool _obscurePassword = true;
  bool _shouldScroll = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.padding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final keyboardOffset = math.max(keyboardInset - safeBottom, 0.0);

    final formSection = _buildFormSection(context);

    return Scaffold(
      key: const ValueKey('auth_signup_screen'),
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.colorScheme.surface,
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
                  Spacing.l,
                  Spacing.l,
                  safeBottom + Spacing.s,
                ),
                child: SizedBox(
                  height: Sizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Anmelden'),
                  ),
                ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView(
                      key: _topKey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.l,
                      ),
                      physics: shouldAllowScroll
                          ? const ClampingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      shrinkWrap: !shouldAllowScroll,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [formSection],
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

  Widget _buildFormSection(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 32,
      height: 1.25,
      color: theme.colorScheme.onSurface,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.l + Spacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: BackButtonCircle(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/auth/login');
              }
            },
          ),
        ),
        const SizedBox(height: Spacing.l),
        Text('Konto erstellen', style: headlineStyle),
        const SizedBox(height: Spacing.s),
        Text(
          'Starte jetzt mit deinem persönlichen LUVI Profil.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 20,
            height: 1.2,
            color: theme.colorScheme.onSurface.withValues(alpha: 214),
          ),
        ),
        const SizedBox(height: Spacing.l + Spacing.xs),
        _SignupTextField(
          controller: _firstNameController,
          hintText: 'Vorname',
          autofillHints: const [AutofillHints.givenName],
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
        _SignupTextField(
          controller: _lastNameController,
          hintText: 'Nachname',
          autofillHints: const [AutofillHints.familyName],
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
        _SignupTextField(
          controller: _phoneController,
          hintText: 'Telefonnummer',
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
        LoginEmailField(
          controller: _emailController,
          errorText: null,
          autofocus: false,
          onChanged: (_) {},
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
        LoginPasswordField(
          controller: _passwordController,
          errorText: null,
          obscure: _obscurePassword,
          onToggleObscure: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          onChanged: (_) {},
        ),
        const SizedBox(height: Spacing.l + Spacing.xs),
      ],
    );
  }
}

class _SignupTextField extends StatelessWidget {
  const _SignupTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    return Container(
      height: Sizes.buttonHeight,
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(Sizes.radiusM),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 219),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
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
          contentPadding: const EdgeInsets.only(
            left: Spacing.m,
            right: Spacing.m,
            top: Spacing.s,
            bottom: Spacing.s,
          ),
        ),
      ),
    );
  }
}
