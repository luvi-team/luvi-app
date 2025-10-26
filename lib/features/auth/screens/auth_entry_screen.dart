import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_entry_layout.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';

/// Entry screen shown after consent flow but before sign up/login.
class AuthEntryScreen extends ConsumerWidget {
  const AuthEntryScreen({super.key});

  static const routeName = '/auth/entry';

  static const _titleText = 'Training, Ernährung und Regeneration';
  static const _subheadText = 'Bereits über 5.000+ Frauen nutzen LUVI täglich.';
  static const _heroAssetPath = 'assets/images/auth/hero_login_default_00.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WelcomeShell(
      key: const ValueKey('auth_entry_screen'),
      hero: Image.asset(
        _heroAssetPath,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        excludeFromSemantics: true,
      ),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      bottomContent: const _AuthEntryBody(),
    );
  }
}

class _AuthEntryBody extends StatelessWidget {
  const _AuthEntryBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AuthEntryLayout.waveToTitleBaseline),
        const _EntryTitle(),
        const SizedBox(height: AuthEntryLayout.titleToSubhead),
        const _EntrySubtitle(),
        const SizedBox(height: AuthEntryLayout.subheadToPrimary),
        const _EntryPrimaryCta(),
        const SizedBox(height: AuthEntryLayout.primaryToSecondary),
        const _EntrySecondaryCta(),
        const _BottomRestSpacer(),
      ],
    );
  }
}

class _EntryTitle extends StatelessWidget {
  const _EntryTitle();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Text(
        AuthEntryScreen._titleText,
        style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EntrySubtitle extends StatelessWidget {
  const _EntrySubtitle();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final colorScheme = t.colorScheme;
    final ds = t.extension<DsTokens>();
    return Text(
      AuthEntryScreen._subheadText,
      textAlign: TextAlign.center,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: ds?.authEntrySubhead.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}

class _EntryPrimaryCta extends StatelessWidget {
  const _EntryPrimaryCta();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const ValueKey('auth_entry_register_cta'),
      onPressed: () => context.push(AuthSignupScreen.routeName),
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      child: const Text('Registrieren'),
    );
  }
}

class _EntrySecondaryCta extends StatelessWidget {
  const _EntrySecondaryCta();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: const ValueKey('auth_entry_login_cta'),
      onPressed: () => context.push(LoginScreen.routeName),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size.fromHeight(24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('Einloggen'),
    );
  }
}

class _BottomRestSpacer extends StatelessWidget {
  const _BottomRestSpacer();

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final diff = (AuthEntryLayout.bottomRest - safeBottom - Spacing.l).clamp(
      0.0,
      AuthEntryLayout.bottomRest,
    );
    return SizedBox(height: diff);
  }
}
