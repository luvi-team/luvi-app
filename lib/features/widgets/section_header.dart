import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

/// Reusable section header for Dashboard (title on left, optional trailing label on right).
class SectionHeader extends StatelessWidget {
  final String title;
  final bool showTrailingAction;
  final String trailingLabel;

  const SectionHeader({
    required this.title,
    this.showTrailingAction = true,
    this.trailingLabel = 'Alle',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: TypographyTokens.size20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF030401),
          ),
        ),
        if (showTrailingAction)
          Text(
            trailingLabel,
            style: const TextStyle(
              fontFamily: FontFamilies.figtree,
              fontSize: TypographyTokens.size14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFD9B18E),
            ),
          ),
      ],
    );
  }
}
