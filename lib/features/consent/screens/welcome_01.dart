// lib/features/consent/screens/welcome_01.dart
import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/tokens.dart';

class Welcome01Screen extends StatelessWidget {
  const Welcome01Screen({super.key});

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
                  'assets/images/consent/welcome/welcome_hero_1.png',
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
                              const TextSpan(text: 'Dein Zyklus ist deine '),
                              TextSpan(
                                text: 'Superkraft.',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
                        style: tokens.body?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      tokens.gap24,
                      // CTA
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Semantics(
                          button: true,
                          label: 'Weiter zur nächsten Seite',
                          child: ElevatedButton(
                            key: const Key('welcome1_cta'),
                            onPressed: () { /* TODO: navigate to welcome-02 */ },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text('Weiter', style: tokens.callout),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () { /* TODO: skip */ },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          'Überspringen',
                          style: tokens.body?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
