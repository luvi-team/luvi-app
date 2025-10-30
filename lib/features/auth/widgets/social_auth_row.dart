import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';

class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({
    super.key,
    required this.onGoogle,
    required this.onApple,
    this.dividerToButtonsGap = Spacing.l + Spacing.xs,
  });

  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final double dividerToButtonsGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final children = <Widget>[
      _SocialDivider(
        label: AuthStrings.loginSocialDivider,
        lineColor: colorScheme.outlineVariant,
        textStyle: textTheme.bodyMedium?.copyWith(
          fontSize: 20,
          height: 1.2,
          color: colorScheme.onSurface,
        ),
      ),
      SizedBox(height: dividerToButtonsGap),
    ];

    final buttons = <Widget>[];
    // Apple-first ordering per Apple HIG
    if (FeatureFlags.enableAppleSignIn) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: SignInWithAppleButton(
            style: SignInWithAppleButtonStyle.black,
            onPressed: onApple,
          ),
        ),
      );
    }
    if (FeatureFlags.enableGoogleSignIn) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: SignInButton(
            Buttons.google,
            text: AuthStrings.loginSocialGoogle,
            onPressed: onGoogle,
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      // No providers enabled: render nothing (avoid orphaned divider)
      return const SizedBox.shrink();
    }

    // Vertical layout: Apple first, optional gap, then Google
    if (buttons.length == 2) {
      children.addAll([
        buttons.first,
        const SizedBox(height: Spacing.m), // 16dp gap between buttons
        buttons.last,
      ]);
    } else {
      children.addAll(buttons);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

// Deprecated custom social button removed in favor of package-provided widgets.

class _SocialDivider extends StatelessWidget {
  const _SocialDivider({
    required this.label,
    required this.lineColor,
    required this.textStyle,
  });

  final String label;
  final Color lineColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
          child: Text(label, style: textStyle),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }
}
