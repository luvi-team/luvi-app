import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/auth_text_field.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const double _signupInputGap = Spacing.s + Spacing.xs; // 20
const double _signupTopSpacer = Spacing.l + Spacing.xs;

class AuthSignupScreen extends ConsumerStatefulWidget {
  const AuthSignupScreen({super.key});

  static const String routeName = '/auth/signup';

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
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _handleSignup() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = AuthStrings.signupMissingFields;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final metadata = <String, dynamic>{
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
    }..removeWhere((_, value) => (value as String).isEmpty);

    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.signUp(
        email: email,
        password: password,
        data: metadata.isEmpty ? null : metadata,
      );

      if (!mounted) return;
      context.goNamed('verify', queryParameters: const {'variant': 'email'});
    } on AuthException catch (error, stackTrace) {
      debugPrint('Signup failed (auth): ${error.message}\n$stackTrace');
      if (!mounted) return;
      final message = error.message;
      setState(() {
        _errorMessage = message.isNotEmpty
            ? message
            : AuthStrings.signupGenericError;
      });
    } catch (error, stackTrace) {
      debugPrint('Signup failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = AuthStrings.signupGenericError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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
      bottomNavigationBar: AuthBottomCta(
        topPadding: AuthLayout.inputToCta,
        child: _SignupCtaSection(
          onLoginPressed: () => context.goNamed('login'),
          onSignupPressed: _handleSignup,
          isLoading: _isSubmitting,
        ),
      ),
      body: AuthScreenShell(
        includeBottomReserve: false,
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
            onSubmit: _handleSignup,
            isSubmitting: _isSubmitting,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: Spacing.s),
            Semantics(
              liveRegion: true,
              label: _errorMessage,
              child: Text(
                _errorMessage!,
                key: const ValueKey('signup_error_message'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ],
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
    required this.onSubmit,
    required this.isSubmitting,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final EdgeInsets scrollPadding;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final bool isSubmitting;

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
        _PhoneField(controller: phoneController, scrollPadding: scrollPadding),
        const SizedBox(height: _signupInputGap),
        _EmailPasswordFields(
          emailController: emailController,
          passwordController: passwordController,
          obscurePassword: obscurePassword,
          scrollPadding: scrollPadding,
          onToggleObscure: onToggleObscure,
          onSubmit: onSubmit,
          isSubmitting: isSubmitting,
        ),
        const SizedBox(height: AuthLayout.inputToCta),
      ],
    );
  }
}

class _SignupCtaSection extends StatelessWidget {
  const _SignupCtaSection({
    required this.onLoginPressed,
    required this.onSignupPressed,
    required this.isLoading,
  });

  final VoidCallback onLoginPressed;
  final VoidCallback onSignupPressed;
  final bool isLoading;

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
            onPressed: isLoading ? null : onSignupPressed,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _SignupButtonChild(isLoading: isLoading),
            ),
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
                  style: linkBaseStyle?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignupButtonChild extends StatelessWidget {
  const _SignupButtonChild({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Text(
        AuthStrings.signupCta,
        key: const ValueKey('signup_cta_label'),
      );
    }

    final theme = Theme.of(context);
    return Semantics(
      key: const ValueKey('signup_cta_loading_semantics'),
      label: AuthStrings.signupCtaLoadingSemantic,
      liveRegion: true,
      child: SizedBox(
        key: const ValueKey('signup_cta_loading'),
        height: Sizes.buttonHeight / 2,
        width: Sizes.buttonHeight / 2,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
        ),
      ),
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
  const _PhoneField({required this.controller, required this.scrollPadding});

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
    required this.onSubmit,
    required this.isSubmitting,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final EdgeInsets scrollPadding;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final bool isSubmitting;

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
            if (!isSubmitting) {
              onSubmit();
            }
          },
          scrollPadding: scrollPadding,
          hintText: AuthStrings.passwordHint,
        ),
      ],
    );
  }
}
