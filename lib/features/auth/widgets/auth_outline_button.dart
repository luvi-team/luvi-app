import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';

/// Outline button for "Anmelden mit E-Mail" on the SignIn screen.
///
/// Figma Details:
/// - Background: #FFFFFF (white)
/// - Border: 1px solid #E5E7EB (light gray)
/// - Height: 58px
/// - Border Radius: pill (29px for 58px height)
/// - Icon: Mail icon on the left
/// - Text: Centered text
class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Sizes.buttonHeightOutline,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: DsColors.white,
          foregroundColor: DsColors.authOutlineText,
          side: const BorderSide(color: DsColors.authOutlineBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.buttonHeightOutline / 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: Sizes.iconM),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
