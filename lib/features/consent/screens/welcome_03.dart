// lib/features/consent/screens/welcome_03.dart
import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/tokens.dart';

class Welcome03Screen extends StatelessWidget {
  const Welcome03Screen({super.key});

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
                  'assets/images/consent/welcome/welcome_hero_3.png',
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
                  // TODO(welcome-fix): EdgeInsets.symmetric(horizontal: 20) -> tokens.welcomeContentHorizontal
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
                              const TextSpan(text: 'Deine Reise beginnt – mit LUVI an deiner '),
                              TextSpan(
                                text: 'Seite.',
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
                        'Starte deine personalisierte Gesundheitsreise.',
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
                          label: 'Los gehts - starte deine Gesundheitsreise',
                          child: ElevatedButton(
                            key: const Key('welcome3_cta'),
                            onPressed: () { /* TODO: navigate to next step */ },
                            child: const Text('Los geht\'s'),
                          ),
                        ),
                      ),
                      tokens.gap24,
                      TextButton(
                        onPressed: () { /* TODO: skip */ },
                        child: const Text('Überspringen'),
                      ),
                      // TODO(welcome-fix): SizedBox(height: 34) -> tokens.welcomeDotsToButton
                      // TODO(welcome-fix): SafeArea/Padding konsolidieren (einheitlich per tokens.welcomeSafeBottomPadding)
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