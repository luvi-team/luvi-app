import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'welcome_metrics.dart';
import '../widgets/welcome_shell.dart';
import '../widgets/welcome_video_player.dart';
import 'consent_01_screen.dart';
import '../widgets/localized_builder.dart';

class ConsentWelcome05Screen extends StatelessWidget {
  const ConsentWelcome05Screen({super.key});

  static const routeName = '/onboarding/w5';

  @override
  Widget build(BuildContext context) {
    return LocalizedBuilder(builder: _buildLocalizedContent);
  }

  Widget _buildLocalizedContent(BuildContext context, AppLocalizations l10n) {
    return WelcomeShell(
      title: Text(
        l10n.welcome05Title,
        textAlign: TextAlign.center,
      ),
      subtitle: l10n.welcome05Subtitle,
      primaryButtonLabel: l10n.welcome05PrimaryCta, // "Jetzt loslegen"
      onNext: () => context.go(Consent01Screen.routeName),
      hero: WelcomeVideoPlayer(assetPath: Assets.videos.welcomeVideo05),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      waveAsset: Assets.images.welcomeWave,
    );
  }
}
