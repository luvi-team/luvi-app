import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';

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

  bool _obscurePassword = true;

  static const double _horizontalPadding = Spacing.l - Spacing.xs / 2; // 20
  static const double _inputGap = Spacing.s + Spacing.xs; // 20
  static const double _headerGap =
      Spacing.l * 2 + Spacing.s - Spacing.xs / 8; // 59
  static const double _topSpacer = Spacing.l + Spacing.xs; // breathing space
  static const EdgeInsets _fieldScrollPadding = EdgeInsets.only(
    bottom: Sizes.buttonHeight + Spacing.l * 2,
  );

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
    final formSection = _buildFormSection(context);

    return Scaffold(
      key: const ValueKey('auth_signup_screen'),
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: Spacing.s),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            _inputGap,
            _horizontalPadding,
            0,
          ),
          child: _SignupCtaSection(onLoginPressed: () => context.go('/auth/login')),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: formSection,
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _topSpacer),
        const SizedBox(height: Spacing.l),
        Text('Deine Reise beginnt hier 💜', style: headlineStyle),
        const SizedBox(height: Spacing.xs),
        Text(
          'Schnell registrieren - dann geht\'s los.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: _headerGap),
        _SignupTextField(
          controller: _firstNameController,
          hintText: 'Dein Vorname',
          autofillHints: const [AutofillHints.givenName],
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          scrollPadding: _fieldScrollPadding,
        ),
        const SizedBox(height: _inputGap),
        _SignupTextField(
          controller: _lastNameController,
          hintText: 'Dein Nachname',
          autofillHints: const [AutofillHints.familyName],
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          scrollPadding: _fieldScrollPadding,
        ),
        const SizedBox(height: _inputGap),
        _SignupTextField(
          controller: _phoneController,
          hintText: 'Deine Telefonnummer',
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          scrollPadding: _fieldScrollPadding,
        ),
        const SizedBox(height: _inputGap),
        LoginEmailField(
          controller: _emailController,
          errorText: null,
          autofocus: false,
          onChanged: (_) {},
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          scrollPadding: _fieldScrollPadding,
        ),
        const SizedBox(height: _inputGap),
        LoginPasswordField(
          controller: _passwordController,
          errorText: null,
          obscure: _obscurePassword,
          onToggleObscure: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          onChanged: (_) {},
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            // TODO: später CTA triggern.
          },
          scrollPadding: _fieldScrollPadding,
        ),
        const SizedBox(height: _inputGap),
      ],
    );
  }
}

class _SignupCtaSection extends StatelessWidget {
  const _SignupCtaSection({required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkBaseStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: Sizes.buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Registrieren'),
          ),
        ),
        const SizedBox(height: Spacing.s),
        TextButton(
          key: const ValueKey('signup_login_link'),
          onPressed: onLoginPressed,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Schon dabei? ',
                  style: linkBaseStyle,
                ),
                TextSpan(
                  text: 'Anmelden',
                  style: linkBaseStyle?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    this.scrollPadding =
        const EdgeInsets.only(bottom: Sizes.buttonHeight + Spacing.l * 2),
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final EdgeInsets scrollPadding;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final inputStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: TypeScale.smallSize,
      height: TypeScale.smallHeight,
      color: theme.colorScheme.onSurface,
    );
    return Container(
      height: Sizes.buttonHeight,
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(Sizes.radiusM),
        border: Border.all(color: tokens.inputBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        style: inputStyle,
        scrollPadding: scrollPadding,
        onSubmitted:
            onSubmitted ?? (_) => FocusScope.of(context).nextFocus(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: inputStyle?.copyWith(color: tokens.grayscale500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
        ),
      ),
    );
  }
}
