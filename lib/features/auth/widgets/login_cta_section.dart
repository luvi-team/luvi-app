import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';

class LoginCtaSection extends StatelessWidget {
  const LoginCtaSection({
    super.key,
    required this.onSubmit,
    required this.onSignup,
    required this.hasValidationError,
    this.isLoading = false,
  });

  final VoidCallback onSubmit;
  final VoidCallback onSignup;
  final bool hasValidationError;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: Sizes.buttonHeight,
          child: ElevatedButton(
            key: const ValueKey('login_cta_button'),
            onPressed: (isLoading || hasValidationError) ? null : onSubmit,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _LoginButtonChild(isLoading: isLoading),
            ),
          ),
        ),
        SizedBox(
          height: hasValidationError
              ? AuthLayout.ctaLinkGapError
              : AuthLayout.ctaLinkGapNormal,
        ),
        Center(
          child: TextButton(
            key: const ValueKey('login_signup_link'),
            onPressed: onSignup,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AuthStrings.loginCtaLinkPrefix,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: AuthStrings.loginCtaLinkAction,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 17,
                      height: 1.47,
                      color: tokens.cardBorderSelected,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
      ],
    );
  }
}

class _LoginButtonChild extends StatelessWidget {
  const _LoginButtonChild({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return KeyedSubtree(
        // keep key stable for AnimatedSwitcher
        key: ValueKey('login_cta_label'),
        // non-const child due to localized string
        child: Text(AuthStrings.loginCtaButton),
      );
    }

    final theme = Theme.of(context);
    return Semantics(
      key: const ValueKey('login_cta_loading_semantics'),
      label: AuthStrings.loginCtaLoadingSemantic,
      liveRegion: true,
      child: SizedBox(
        key: const ValueKey('login_cta_loading'),
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
