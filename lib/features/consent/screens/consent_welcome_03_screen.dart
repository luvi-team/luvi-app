import 'package:flutter/material.dart';
import 'welcome_metrics.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:go_router/go_router.dart';
// no routing target yet for W3 → keep clean TODO
import '../widgets/welcome_shell.dart';
import 'consent_01_screen.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class ConsentWelcome03Screen extends StatelessWidget {
  const ConsentWelcome03Screen({super.key});

  static const routeName = '/onboarding/w3';
  // Keine spezielle Subtitle-Spaltenbreite notwendig – W1/W2 nutzen volle Breite.

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final titleStyle = t.headlineMedium?.copyWith(
      fontSize: TypographyTokens.size28,
      height: TypographyTokens.lineHeightRatio36on28,
    );

    return WelcomeShell(
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: titleStyle,
          children: [
            const TextSpan(text: 'Dein perfekter Tag\n'),
            TextSpan(
              text: 'beginnt hier',
              style: titleStyle?.copyWith(color: c.primary),
            ),
          ],
        ),
      ),
      subtitle: l10n.welcome03Subtitle,
      onNext: () => context.push(Consent01Screen.routeName),
      hero: Image.asset(Assets.welcomeHero03, fit: BoxFit.cover),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      headerSpacing: Spacing.s,
      primaryButtonLabel: l10n.commonStartNow,
      activeIndex: 2,
    );
  }
}
