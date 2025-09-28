import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          // Wave -> Title: Text weiter weg von der Wave, Buttons bleiben fix.
          // Erhöhe Top-Padding um Δ=8 (116→124) für korrekte Baseline.
          const SizedBox(height: 124),
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
          // title -> subhead (Figma/MCP): 37 px
          const SizedBox(height: 37),
          Text(
            _subheadText,
            textAlign: TextAlign.center,
            // Figma: #6B7280 → ColorScheme.onSurfaceVariant
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          // ... kompensiere unten um Δ=8 (67→59), damit Buttons nicht mitwandern.
          const SizedBox(height: 59),
          ElevatedButton(
            key: const ValueKey('auth_entry_register_cta'),
            onPressed: () => context.push('/auth/signup'),
            // Primary-Höhe exakt 50 px
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Registrieren'),
          ),
          // primary -> secondary (Figma/MCP): 24 px (ohne zusätzliches TextButton-Padding!)
          const SizedBox(height: 24),
          TextButton(
            key: const ValueKey('auth_entry_login_cta'),
            onPressed: () => context.push('/auth/login'),
            // Figma: text-only 24 px Labelhöhe → Padding entfernen, Höhe nicht künstlich vergrößern
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size.fromHeight(24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Einloggen'),
          ),
          // Figma-Bottom-Spacing: ~59 px bis zum Frame-Bottom.
          // SafeArea fügt 'safeBottom' hinzu; wir ergänzen die Differenz.
          Builder(
            builder: (context) {
              final safeBottom = MediaQuery.of(context).padding.bottom;
              final diff = (59 - safeBottom).clamp(0.0, 59.0);
              return SizedBox(height: diff);
            },
          ),
        ],
      ),
    );
  }
}
