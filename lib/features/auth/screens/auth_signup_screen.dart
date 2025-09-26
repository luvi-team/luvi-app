import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/widgets/auth_text_field.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';

const double _signupInputGap = Spacing.s + Spacing.xs; // 20
const double _signupTopSpacer = Spacing.l + Spacing.xs;

class AuthSignupScreen extends StatefulWidget {
  const AuthSignupScreen({super.key});

  @override
  State<AuthSignupScreen> createState() => _AuthSignupScreenState();
}

class _AuthSignupScreenState extends State<AuthSignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

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
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final fieldScrollPadding = EdgeInsets.only(
      bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
    );

    return Scaffold(
      key: const ValueKey('auth_signup_screen'),
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: Spacing.s),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AuthLayout.horizontalPadding,
            AuthLayout.inputToCta,
            AuthLayout.horizontalPadding,
            0,
          ),
          child: _SignupCtaSection(
            onLoginPressed: () => context.goNamed('login'),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AuthLayout.horizontalPadding,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SignupHeader(),
              _SignupFields(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                phoneController: _phoneController,
                emailController: _emailController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                scrollPadding: fieldScrollPadding,
                onToggleObscure: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupHeader extends StatelessWidget {
  const _SignupHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _signupTopSpacer),
        const SizedBox(height: Spacing.l),
        Text(AuthStrings.signupTitle, style: headlineStyle),
        const SizedBox(height: Spacing.xs),
        Text(
          AuthStrings.signupSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AuthLayout.gapTitleToInputs),
      ],
    );
  }
}

class _SignupFields extends StatelessWidget {
  const _SignupFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.scrollPadding,
    required this.onToggleObscure,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final EdgeInsets scrollPadding;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NameFieldsRow(
          firstNameController: firstNameController,
          lastNameController: lastNameController,
          scrollPadding: scrollPadding,
        ),
        const SizedBox(height: _signupInputGap),
        _PhoneField(
          controller: phoneController,
          scrollPadding: scrollPadding,
        ),
        const SizedBox(height: _signupInputGap),
        _EmailPasswordFields(
          emailController: emailController,
          passwordController: passwordController,
          obscurePassword: obscurePassword,
          scrollPadding: scrollPadding,
          onToggleObscure: onToggleObscure,
        ),
        const SizedBox(height: AuthLayout.inputToCta),
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
            key: const ValueKey('signup_cta_button'),
            onPressed: () {},
            child: const Text(AuthStrings.signupCta),
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
                  text: AuthStrings.signupLinkPrefix,
                  style: linkBaseStyle,
                ),
                TextSpan(
                  text: AuthStrings.signupLinkAction,
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

class _NameFieldsRow extends StatelessWidget {
  const _NameFieldsRow({
    required this.firstNameController,
    required this.lastNameController,
    required this.scrollPadding,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final EdgeInsets scrollPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: firstNameController,
          hintText: AuthStrings.signupHintFirstName,
          autofillHints: const [AutofillHints.givenName],
          textCapitalization: TextCapitalization.words,
          scrollPadding: scrollPadding,
        ),
        const SizedBox(height: _signupInputGap),
        AuthTextField(
          controller: lastNameController,
          hintText: AuthStrings.signupHintLastName,
          autofillHints: const [AutofillHints.familyName],
          textCapitalization: TextCapitalization.words,
          scrollPadding: scrollPadding,
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.scrollPadding,
  });

  final TextEditingController controller;
  final EdgeInsets scrollPadding;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hintText: AuthStrings.signupHintPhone,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      scrollPadding: scrollPadding,
    );
  }
}

class _EmailPasswordFields extends StatelessWidget {
  const _EmailPasswordFields({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.scrollPadding,
    required this.onToggleObscure,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final EdgeInsets scrollPadding;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoginEmailField(
          controller: emailController,
          errorText: null,
          autofocus: false,
          onChanged: (_) {},
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          scrollPadding: scrollPadding,
        ),
        const SizedBox(height: _signupInputGap),
        LoginPasswordField(
          controller: passwordController,
          errorText: null,
          obscure: obscurePassword,
          onToggleObscure: onToggleObscure,
          onChanged: (_) {},
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            // TODO: später CTA triggern.
          },
          scrollPadding: scrollPadding,
          hintText: AuthStrings.passwordHint,
        ),
      ],
    );
  }
}
