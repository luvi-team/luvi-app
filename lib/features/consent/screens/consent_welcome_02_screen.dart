import 'package:flutter/material.dart';
import 'welcome_metrics.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:go_router/go_router.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_03_screen.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class ConsentWelcome02Screen extends StatelessWidget {
  const ConsentWelcome02Screen({super.key});

  static const routeName = '/onboarding/w2';

  @override
  Widget build(BuildContext context) {
    final maybeL10n = AppLocalizations.of(context);
    if (maybeL10n == null) {
      return Localizations.override(
        context: context,
        delegates: AppLocalizations.localizationsDelegates,
        locale: AppLocalizations.supportedLocales.first,
        child: Builder(builder: _buildLocalizedContent),
      );
    }

    return _buildLocalizedContent(context);
  }

  Widget _buildLocalizedContent(BuildContext context) {
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
            TextSpan(text: l10n.welcome02TitleLine1),
            TextSpan(
              text: l10n.welcome02TitleLine2,
              style: titleStyle?.copyWith(color: c.primary),
            ),
          ],
        ),
      ),
      subtitle: l10n.welcome02Subtitle,
      onNext: () => context.go(ConsentWelcome03Screen.routeName),
      hero: Image.asset(Assets.images.welcomeHero02, fit: BoxFit.cover),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      headerSpacing: 0,
      activeIndex: 1,
    );
  }
}
