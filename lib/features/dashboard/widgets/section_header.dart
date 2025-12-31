import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Reusable section header for Dashboard (title on left, optional trailing label on right).
///
/// The optional [maxLines] parameter lets callers control how many lines the
/// header text may occupy. It is nullable, defaults to 1 for backward
/// compatibility, and keeps the existing ellipsis overflow trimming behavior.
class SectionHeader extends StatelessWidget {
  final String title;
  final bool showTrailingAction;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  /// Maximum number of lines for [title]; nullable and defaults to 1 to retain
  /// legacy single-line truncation.
  final int? maxLines;

  static const TextStyle _baseTitleStyle = TextStyle(
    fontFamily: FontFamilies.figtree,
    fontSize: TypographyTokens.size20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _baseTrailingStyle = TextStyle(
    fontFamily: FontFamilies.figtree,
    fontSize: TypographyTokens.size14,
    fontWeight: FontWeight.w400,
  );

  const SectionHeader({
    required this.title,
    this.showTrailingAction = true,
    this.trailingLabel,
    this.onTrailingTap,
    this.maxLines,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    final Color titleColor = textTokens?.primary ?? ColorTokens.sectionTitle;
    final Color trailingColor = Theme.of(
      context,
    ).colorScheme.primary; // maps to primary gold in light theme

    final localizedFallback = AppLocalizations.of(context)?.dashboardViewAll;
    final resolvedTrailingLabel = trailingLabel ?? localizedFallback;
    final shouldShowTrailing =
        showTrailingAction && (resolvedTrailingLabel?.isNotEmpty ?? false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              maxLines: maxLines ?? 1,
              overflow: TextOverflow.ellipsis,
              style: _baseTitleStyle.copyWith(color: titleColor),
            ),
          ),
        ),
        if (shouldShowTrailing) ...[
          const SizedBox(width: Spacing.s),
          if (onTrailingTap != null)
            Semantics(
              button: true,
              label: resolvedTrailingLabel ?? '',
              child: Material(
                color: DsColors.transparent,
                child: InkWell(
                  onTap: onTrailingTap,
                  borderRadius: BorderRadius.circular(Sizes.radiusXS),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xxs,
                        vertical: Spacing.micro,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          resolvedTrailingLabel ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _baseTrailingStyle.copyWith(
                            color: trailingColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Text(
              resolvedTrailingLabel ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _baseTrailingStyle.copyWith(color: trailingColor),
            ),
        ],
      ],
    );
  }
}
