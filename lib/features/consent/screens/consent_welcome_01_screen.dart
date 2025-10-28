import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'welcome_metrics.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_02_screen.dart';

class ConsentWelcome01Screen extends StatelessWidget {
  const ConsentWelcome01Screen({super.key});

  static const routeName = '/onboarding/w1';

  // Documented constants (formerly magic numbers)
  static const double _kHeroAspect = kWelcomeHeroAspect; // Figma aspect ratio
  static const double _kWaveHeight =
      kWelcomeWaveHeight; // tuned height from visual QA

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
      // RichTitle: normal + Accent getrennt (wie Figma)
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          // use theme-provided H1 (Playfair Display via Theme)
          style: titleStyle,
          children: [
            TextSpan(text: l10n.welcome01TitlePrefix),
            TextSpan(
              text: l10n.welcome01TitleAccent,
              style: titleStyle?.copyWith(color: c.secondary),
            ),
            TextSpan(text: l10n.welcome01TitleSuffixLine1),
            TextSpan(text: l10n.welcome01TitleSuffixLine2),
          ],
        ),
      ),
      subtitle: l10n.welcome01Subtitle,
      primaryButtonLabel: l10n.welcome01PrimaryCta,
      onNext: () => context.go(ConsentWelcome02Screen.routeName),
      hero: Image.asset(Assets.images.welcomeHero01, fit: BoxFit.cover),
      heroAspect: _kHeroAspect,
      waveHeightPx: _kWaveHeight,
      waveAsset: Assets.images.welcomeWave,
      headerSpacing: 0,
      activeIndex: 0,
    );
  }
}
