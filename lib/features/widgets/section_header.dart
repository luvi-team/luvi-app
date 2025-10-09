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
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: FontFamilies.figtree,
              fontSize: TypographyTokens.size20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF030401),
            ),
          ),
        ),
        if (showTrailingAction) ...[
          const SizedBox(width: 12),
          Text(
            trailingLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: FontFamilies.figtree,
              fontSize: TypographyTokens.size14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFD9B18E),
            ),
          ),
        ],
      ],
    );
  }
}
