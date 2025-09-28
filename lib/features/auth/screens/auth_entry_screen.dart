import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';

/// Entry screen shown after consent flow but before sign up/login.
class AuthEntryScreen extends ConsumerWidget {
  const AuthEntryScreen({super.key});

  static const routeName = '/auth/entry';

  static const _titleText = 'Training, Ernährung und Regeneration';
  static const _subheadText = 'Bereits über 5.000+ Frauen nutzen LUVI täglich.';
  static const _heroAssetPath = 'assets/images/auth/hero_login_default_00.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return WelcomeShell(
      key: const ValueKey('auth_entry_screen'),
      hero: Image.asset(
        _heroAssetPath,
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.8),
      ),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      bottomContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              _titleText,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Spacing.s), // title -> subtitle
          Text(
            _subheadText,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: Spacing.l), // subtitle -> buttons
          ElevatedButton(
            key: const ValueKey('auth_entry_register_cta'),
            onPressed: () => context.push('/auth/signup'),
            child: const Text('Registrieren'),
          ),
          const SizedBox(height: Spacing.s), // primary -> secondary
          TextButton(
            key: const ValueKey('auth_entry_login_cta'),
            onPressed: () => context.push('/auth/login'),
            child: const Text('Einloggen'),
          ),
          const SizedBox(height: Spacing.xs), // breathing space
        ],
      ),
    );
  }
}
