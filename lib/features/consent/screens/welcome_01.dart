// lib/features/consent/screens/welcome_01.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/tokens.dart';
import 'package:luvi_app/features/consent/routes.dart';

class Welcome01Screen extends StatelessWidget {
  const Welcome01Screen({super.key});
  
  Widget _buildDot(BuildContext context, {required bool isActive}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? LuviTokens.welcomeDotActive
            : LuviTokens.welcomeDotInactive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = LuviTokens.of(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * LuviTokens.welcomeHeroHeightRatio;
    final width = size.width;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Hero mit korrekter Höhe und SVG Wave unten verankert
          SizedBox(
            height: heroHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Bild mit angepasstem Alignment
                Image.asset(
                  'assets/images/consent/welcome/welcome_hero_1.png',
                  fit: BoxFit.cover,
                  alignment: Alignment(0, LuviTokens.welcomeHeroAlignY),
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
                
                // Wave-Overlay mit CustomClipper – UNBEDINGT UNTEN verankern
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    width: width,
                    height: tokens.welcomeWaveIntrusionForWidth(width),
                    child: ClipPath(
                      clipper: _WelcomeWaveClipper(),
                      child: Container(color: theme.colorScheme.surface),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content mit Transform.translate für Overlap
          Transform.translate(
            offset: Offset(
              0,
              -(tokens.welcomeWaveIntrusionForWidth(width)
                - tokens.welcomeContentFromWaveForWidth(width)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: LuviTokens.welcomeContentHorizontal),
              child: Column(
                children: [
                  // Titel (mit Primary Akzent)
                  Semantics(
                    header: true,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: LuviTokens.welcomeTextPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Dein Zyklus ist deine '),
                          TextSpan(
                            text: 'Superkraft.',
                            style: TextStyle(
                              color: LuviTokens.welcomeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: LuviTokens.welcomeHeadlineToBody),
                  Text(
                    'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: LuviTokens.welcomeTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: LuviTokens.welcomeBodyToDots),
                  // Pagination Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(context, isActive: true),
                      const SizedBox(width: LuviTokens.welcomeDotSpacing),
                      _buildDot(context, isActive: false),
                      const SizedBox(width: LuviTokens.welcomeDotSpacing),
                      _buildDot(context, isActive: false),
                    ],
                  ),
                  const SizedBox(height: LuviTokens.welcomeDotsToButton),
                  // CTA und Skip in SafeArea
                  SafeArea(
                    bottom: true,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Semantics(
                            button: true,
                            label: 'Weiter zur nächsten Seite',
                            child: ElevatedButton(
                              key: const Key('welcome1_cta'),
                              onPressed: () => context.go(ConsentRoutes.welcome02Route),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LuviTokens.welcomeCtaFill,
                                foregroundColor: LuviTokens.welcomeCtaText,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Weiter'),
                            ),
                          ),
                        ),
                        const SizedBox(height: LuviTokens.welcomeButtonToSkip),
                        TextButton(
                          onPressed: () => context.go(ConsentRoutes.welcome03Route),
                          style: TextButton.styleFrom(
                            foregroundColor: LuviTokens.welcomeTextPrimary,
                          ),
                          child: const Text('Überspringen'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
