import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class HeuteHeader extends StatelessWidget {
  const HeuteHeader({
    super.key,
    required this.userName,
    required this.currentPhase,
    required this.hasNotifications,
  });

  final String userName;
  final Phase currentPhase;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textTokens = theme.extension<TextColorTokens>();
    final primaryColor = textTokens?.primary ?? DsColors.textPrimary;
    final secondaryColor =
        textTokens?.secondary ?? ColorTokens.recommendationTag;
    final notificationColor = theme.colorScheme.error;
    final greeting = l10n.dashboardGreeting(userName);
    final phaseLabel = _localizedPhaseLabel(l10n, currentPhase);

    return Column(
      key: const Key('dashboard_header'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontFamily: FontFamilies.playfairDisplay,
                      fontSize: 32,
                      height: 40 / 32,
                      fontWeight: FontWeight.w400,
                    ).copyWith(color: primaryColor),
                  ),
                  const SizedBox(height: Spacing.micro),
                  Text(
                    phaseLabel,
                    style: TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w400,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Semantics(
              label: hasNotifications
                  ? l10n.notificationsWithBadge
                  : l10n.notificationsNoBadge,
              child: Stack(
                children: [
                  _buildHeaderIcon(Assets.icons.notifications),
                  if (hasNotifications)
                    Positioned(
                      top: _notificationBadgeOffset,
                      right: _notificationBadgeOffset,
                      child: Container(
                        width: _notificationBadgeSize,
                        height: _notificationBadgeSize,
                        decoration: BoxDecoration(
                          color: notificationColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _localizedPhaseLabel(AppLocalizations l10n, Phase phase) {
    switch (phase) {
      case Phase.menstruation:
        return l10n.cyclePhaseMenstruation;
      case Phase.follicular:
        return l10n.cyclePhaseFollicular;
      case Phase.ovulation:
        return l10n.cyclePhaseOvulation;
      case Phase.luteal:
        return l10n.cyclePhaseLuteal;
    }
  }

  Widget _buildHeaderIcon(String assetPath) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(_headerIconPadding),
      decoration: BoxDecoration(
        color: DsColors.transparent,
        borderRadius: BorderRadius.circular(_headerIconRadius),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.08),
          width: _headerIconBorderWidth,
        ),
      ),
      child: SvgPicture.asset(assetPath, width: 24, height: 24),
    );
  }
}

const double _headerIconPadding = 8;
const double _headerIconRadius = 26.667;
const double _headerIconBorderWidth = 0.769;
const double _notificationBadgeSize = 6.668;
const double _notificationBadgeOffset = 8;
