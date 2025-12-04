import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'welcome_metrics.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_04_screen.dart';
import '../widgets/localized_builder.dart';

class ConsentWelcome03Screen extends StatelessWidget {
  const ConsentWelcome03Screen({super.key});

  static const routeName = '/onboarding/w3';

  @override
  Widget build(BuildContext context) {
    return LocalizedBuilder(builder: _buildLocalizedContent);
  }

  Widget _buildLocalizedContent(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineMedium;

    return WelcomeShell(
      title: Text(
        l10n.welcome03Title,
        textAlign: TextAlign.center,
        style: titleStyle,
      ),
      subtitle: l10n.welcome03Subtitle,
      primaryButtonLabel: l10n.commonContinue,
      onNext: () => context.go(ConsentWelcome04Screen.routeName),
      hero: Image.asset(
        Assets.images.welcomeHero03,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      waveAsset: Assets.images.welcomeWave,
    );
  }
}
