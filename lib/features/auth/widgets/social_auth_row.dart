import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';

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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(height: 1, color: colorScheme.outlineVariant),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
              child: Text(
                'Oder melde dich an mit',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 20,
                  height: 1.2,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: colorScheme.outlineVariant),
            ),
          ],
        ),
        SizedBox(height: dividerToButtonsGap),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                svgAsset: 'assets/icons/google_g.svg',
                label: 'Google',
                onPressed: onGoogle,
              ),
            ),
            const SizedBox(width: Spacing.s + Spacing.xs),
            Expanded(
              child: _SocialButton(
                icon: Icons.apple,
                label: 'Apple',
                onPressed: onApple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    this.icon,
    this.svgAsset,
    required this.label,
    required this.onPressed,
  });

  final IconData? icon;
  final String? svgAsset;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      height: Sizes.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.onPrimary,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
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
              Icon(icon, size: Spacing.l, color: colorScheme.onSurface),
              const SizedBox(width: Spacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 17,
                height: 1.47,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
