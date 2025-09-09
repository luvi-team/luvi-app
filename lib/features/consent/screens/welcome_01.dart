// lib/features/consent/screens/welcome_01.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/tokens.dart';
import 'package:luvi_app/features/consent/routes.dart';

class Welcome01Screen extends StatelessWidget {
  const Welcome01Screen({super.key});
  
  Widget _buildDot(BuildContext context, {required bool isActive}) {
    final theme = Theme.of(context);
    final tokens = LuviTokens.of(context);
    return Stack(
      children: [
        // Use spacing token to define size (avoids magic numbers)
        tokens.gap8,
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = LuviTokens.of(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * 0.62; // wie im ursprünglichen Layout
    final width = size.width;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero mit korrekter Höhe und SVG Wave unten verankert
            SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Bild
                  Image.asset(
                    'assets/images/consent/welcome/welcome_hero_1.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                  ),
                  
                  // Wave-Overlay (SVG) – UNBEDINGT UNTEN verankern
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Builder(
                      builder: (context) {
                        // Figma-Baseline: Breite 428 → Wave-Höhe ~160
                        const baselineWidth = 428.0;
                        const baselineWaveHeight = 160.0; // optisch aus Figma
                        final waveHeight = baselineWaveHeight * (width / baselineWidth);
                        
                        return SvgPicture.asset(
                          'assets/svg/waves/welcome_01_wave.svg',
                          width: width,
                          height: waveHeight,
                          fit: BoxFit.fill,
                          alignment: Alignment.bottomCenter,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Content beginnt direkt nach dem Hero
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
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
                    tokens.gap8,
                    Text(
                      'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
                      style: tokens.body?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    tokens.gap24,
                    // Pagination Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(context, isActive: true),
                        tokens.gap8,
                        _buildDot(context, isActive: false),
                        tokens.gap8,
                        _buildDot(context, isActive: false),
                      ],
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
                          onPressed: () => context.go(ConsentRoutes.welcome02Route),
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
                    tokens.gap24,
                    TextButton(
                      onPressed: () => context.go(ConsentRoutes.welcome03Route),
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
                    tokens.gap34,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
