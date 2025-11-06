import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'welcome_metrics.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_02_screen.dart';
import '../widgets/localized_builder.dart';

class ConsentWelcome01Screen extends StatelessWidget {
  const ConsentWelcome01Screen({super.key});

  static const routeName = '/onboarding/w1';

  // Documented constants (formerly magic numbers)
  static const double _kHeroAspect = kWelcomeHeroAspect; // Figma aspect ratio
  static const double _kWaveHeight =
      kWelcomeWaveHeight; // tuned height from visual QA

  @override
  Widget build(BuildContext context) {
    return LocalizedBuilder(builder: _buildLocalizedContent);
  }

  Widget _buildLocalizedContent(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final c = theme.colorScheme;
    final prefix = l10n.welcome01TitlePrefix;
    final accent = l10n.welcome01TitleAccent;
    final suffixLine1 = l10n.welcome01TitleSuffixLine1.trim();
    final suffixLine2 = l10n.welcome01TitleSuffixLine2.trim();
    final titleStyle = (t.headlineMedium ?? const TextStyle()).copyWith(
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
            TextSpan(text: prefix),
            const TextSpan(text: ' '),
            TextSpan(
              text: accent,
              style: titleStyle.copyWith(color: c.secondary),
            ),
            const TextSpan(text: ' '),
            TextSpan(text: suffixLine1),
            const TextSpan(text: '\n'),
            TextSpan(text: suffixLine2),
          ],
        ),
      ),
      subtitle: l10n.welcome01Subtitle,
      primaryButtonLabel: l10n.welcome01PrimaryCta,
      onNext: () => context.go(ConsentWelcome02Screen.routeName),
      hero: Image.asset(
        Assets.images.welcomeHero01,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
      heroAspect: _kHeroAspect,
      waveHeightPx: _kWaveHeight,
      waveAsset: Assets.images.welcomeWave,
      headerSpacing: 0,
      activeIndex: 0,
    );
  }
}
