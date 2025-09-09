// lib/features/consent/screens/welcome_02.dart
import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/tokens.dart';

class Welcome02Screen extends StatelessWidget {
  const Welcome02Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = LuviTokens.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Hero
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/consent/welcome/welcome_hero_2.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const SizedBox.expand(),
                ),
                // sanfter Verlauf zur Fläche
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.colorScheme.surface.withValues(alpha: 0.8),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Titel (mit Primary Akzent)
                      Semantics(
                        header: true,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: tokens.h1?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            children: [
                              const TextSpan(text: 'Dein Körper spricht zu dir – lerne seine '),
                              TextSpan(
                                text: 'Sprache.',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      tokens.gap16,
                      Text(
                        'LUVI übersetzt, was dein Zyklus dir sagen möchte.',
                        style: tokens.body?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      tokens.gap24,
                      // CTA
                      SizedBox(
                        width: double.infinity,
                        child: Semantics(
                          button: true,
                          label: 'Weiter zur nächsten Seite',
                          child: ElevatedButton(
                            key: const Key('welcome2_cta'),
                            onPressed: () { /* TODO: navigate to next step */ },
                            child: const Text('Weiter'),
                          ),
                        ),
                      ),
                      tokens.gap24,
                      TextButton(
                        onPressed: () { /* TODO: skip */ },
                        child: const Text('Überspringen'),
                      ),
                      const SizedBox(height: 34),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
