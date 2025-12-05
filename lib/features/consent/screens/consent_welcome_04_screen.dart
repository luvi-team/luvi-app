import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'welcome_metrics.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_05_screen.dart';
import '../widgets/localized_builder.dart';

class ConsentWelcome04Screen extends StatelessWidget {
  const ConsentWelcome04Screen({super.key});

  static const routeName = '/onboarding/w4';

  @override
  Widget build(BuildContext context) {
    return LocalizedBuilder(builder: _buildLocalizedContent);
  }

  Widget _buildLocalizedContent(BuildContext context, AppLocalizations l10n) {
    return WelcomeShell(
      title: Text(
        l10n.welcome04Title,
        textAlign: TextAlign.center,
      ),
      subtitle: l10n.welcome04Subtitle,
      primaryButtonLabel: l10n.commonContinue,
      onNext: () => context.go(ConsentWelcome05Screen.routeName),
      hero: Image.asset(
        Assets.images.welcomeHero04,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      waveAsset: Assets.images.welcomeWave,
    );
  }
}
