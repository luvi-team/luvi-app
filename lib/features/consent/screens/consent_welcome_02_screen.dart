import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'welcome_metrics.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_03_screen.dart';
import '../widgets/localized_builder.dart';

class ConsentWelcome02Screen extends StatelessWidget {
  const ConsentWelcome02Screen({super.key});

  static const routeName = '/onboarding/w2';

  @override
  Widget build(BuildContext context) {
    return LocalizedBuilder(builder: _buildLocalizedContent);
  }

  Widget _buildLocalizedContent(BuildContext context, AppLocalizations l10n) {
    return WelcomeShell(
      title: Text(
        l10n.welcome02Title,
        textAlign: TextAlign.center,
      ),
      subtitle: l10n.welcome02Subtitle,
      primaryButtonLabel: l10n.commonContinue,
      onNext: () => context.go(ConsentWelcome03Screen.routeName),
      hero: Image.asset(
        Assets.images.welcomeHero02,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      waveAsset: Assets.images.welcomeWave,
    );
  }
}
