// lib/features/consent/screens/welcome_01.dart
import 'package:flutter/material.dart';
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
    // TODO(welcome-fix): heroHeight künftig aus tokens.welcomeHeroHeightRatio ableiten
    final heroHeight = size.height * 0.62;
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
                  
                  // Wave-Overlay mit CustomClipper – UNBEDINGT UNTEN verankern
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: width,
                      // TODO(welcome-fix): Wave künftig über tokens.welcomeWaveIntrusionForWidth(width) statt legacy height
                      height: tokens.welcomeWaveHeightForWidth(width),
                      child: ClipPath(
                        clipper: _WelcomeWaveClipper(),
                        child: Container(color: theme.colorScheme.surface),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Spacing zwischen Wave und Content
            SizedBox(height: tokens.welcomeTextTopSpacingForWidth(width)),
            // Content beginnt direkt nach dem Hero
            SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                // TODO(welcome-fix): SafeArea bottom eindeutig – keine Doppelung mit zusätzlichem Padding
                // TODO(welcome-fix): Spacing ausschließlich per Tokens (headline/body/dots/button/skip)
                padding: EdgeInsets.fromLTRB(20, 40, 20, tokens.safeBottomPadding(context)),
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
                      child: Semantics(
                        button: true,
                        label: 'Weiter zur nächsten Seite',
                        child: ElevatedButton(
                          key: const Key('welcome1_cta'),
                          onPressed: () => context.go(ConsentRoutes.welcome02Route),
                          child: const Text('Weiter'),
                        ),
                      ),
                    ),
                    tokens.gap24,
                    TextButton(
                      onPressed: () => context.go(ConsentRoutes.welcome03Route),
                      child: const Text('Überspringen'),
                    ),
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

class _WelcomeWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Figma Baseline: width=428, topCurveY=40, bottomY=427
    const baselineW = 428.0;
    const topY = 40.0;
    const bottomY = 427.0;

    final w = size.width;
    final h = size.height;

    // Skaliere Y-Punkte proportional zur Zielhöhe
    final yTop = (topY / bottomY) * h;

    final p = Path()
      ..moveTo(0, yTop)
      ..cubicTo(
        0, yTop,              // C1
        (85.5 / baselineW) * w, 0,  // C2
        (214 / baselineW) * w, 0)   // M
      ..cubicTo(
        (342.5 / baselineW) * w, 0, // C1
        w, yTop,                    // C2
        w, yTop)                    // End
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    return p;
  }
  
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
