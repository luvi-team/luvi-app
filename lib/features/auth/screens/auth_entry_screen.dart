import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_entry_layout.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AuthEntryLayout.waveToTitleBaseline),
        Semantics(
          header: true,
          child: Text(
            AuthEntryScreen._titleText,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AuthEntryLayout.titleToSubhead),
        Text(
          AuthEntryScreen._subheadText,
          textAlign: TextAlign.center,
          // Typo-Tweak für MVP: einzeilig & kleiner, damit Buttons höher rutschen.
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14, // vorher 15
            height: 20 / 14, // ~20px line-height wie Figma-Feeling
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AuthEntryLayout.subheadToPrimary),
        ElevatedButton(
          key: const ValueKey('auth_entry_register_cta'),
          onPressed: () => context.push('/auth/signup'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Registrieren'),
        ),
        const SizedBox(height: AuthEntryLayout.primaryToSecondary),
        TextButton(
          key: const ValueKey('auth_entry_login_cta'),
          onPressed: () => context.push('/auth/login'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size.fromHeight(24),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Einloggen'),
        ),
        Builder(
          builder: (context) {
            final safeBottom = MediaQuery.of(context).padding.bottom;
            final diff = (AuthEntryLayout.bottomRest - safeBottom - Spacing.l)
                .clamp(0.0, AuthEntryLayout.bottomRest);
            return SizedBox(height: diff);
          },
        ),
      ],
    );
  }
}
