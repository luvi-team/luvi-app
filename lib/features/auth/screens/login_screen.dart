import 'package:flutter/material.dart';
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
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final state = ref.read(loginProvider);
    setState(() {
      _emailError = (state.email.isEmpty || !state.email.contains('@'))
          ? 'Ups, bitte E-Mail überprüfen'
          : null;
      _passwordError = (state.password.isEmpty || state.password.length < 6)
          ? 'Ups, bitte Passwort überprüfen'
          : null;
    });
    if (_emailError == null && _passwordError == null) {
      // TODO: Supabase Sign-In
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final loginState = ref.watch(loginProvider);

    // Sync controllers with state
    if (_emailController.text != loginState.email) {
      _emailController.text = loginState.email;
    }
    if (_passwordController.text != loginState.password) {
      _passwordController.text = loginState.password;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Spacing.l + Spacing.xs),
              _Header(theme: theme),
              const SizedBox(height: Spacing.l + Spacing.xs),
              _InputField(
                controller: _emailController,
                hintText: 'Deine E-Mail',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                theme: theme,
                tokens: tokens,
                onChanged: (v) {
                  ref.read(loginProvider.notifier).setEmail(v);
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: Spacing.s + Spacing.xs),
              _InputField(
                controller: _passwordController,
                hintText: 'Dein Passwort',
                errorText: _passwordError,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                theme: theme,
                tokens: tokens,
                onChanged: (v) {
                  ref.read(loginProvider.notifier).setPassword(v);
                  if (_passwordError != null) setState(() => _passwordError = null);
                },
                suffixIcon: Semantics(
                  label: _obscurePassword ? 'Passwort anzeigen' : 'Passwort ausblenden',
                  button: true,
                  child: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.colorScheme.onSurface.withOpacity(0.41),
                      size: Spacing.l,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                      color: theme.colorScheme.onSurface.withOpacity(0.41),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.l + Spacing.xs),
              _SocialSection(theme: theme),
              const SizedBox(height: Spacing.l + Spacing.xs),
              SizedBox(
                width: double.infinity,
                height: Sizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: loginState.isValid ? _validateAndSubmit : null,
                  child: const Text('Anmelden'),
                ),
              ),
              const SizedBox(height: Spacing.m),
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
                            color: theme.colorScheme.onSurface.withOpacity(0.84),
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
        ),
      ),
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
                  : theme.colorScheme.outlineVariant.withOpacity(0.86),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
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
                color: theme.colorScheme.onSurface.withOpacity(0.41),
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
                color: theme.colorScheme.outlineVariant.withOpacity(0.88),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
              child: Text(
                'Oder melde dich an mit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 20,
                  height: 1.2,
                  color: theme.colorScheme.onSurface.withOpacity(0.84),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: theme.colorScheme.outlineVariant.withOpacity(0.88),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.l + Spacing.xs),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                theme: theme,
                onPressed: () {}, // TODO: Google sign-in
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
  final IconData icon;
  final String label;
  final ThemeData theme;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onPressed,
  });

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
            color: theme.colorScheme.outlineVariant.withOpacity(0.96),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.l + Spacing.m),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: Spacing.l,
              color: icon == Icons.apple ? theme.colorScheme.onSurface : null,
            ),
            const SizedBox(width: Spacing.xs),
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
