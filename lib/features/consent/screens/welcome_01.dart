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
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = LuviTokens.of(context);
    final theme = Theme.of(context);
    final w = MediaQuery.of(context).size.width;
    final heroHeight = w * (427.0 / 428.0); // aus dem SVG
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero mit exakter Höhe und SVG Wave
            SizedBox(
              width: double.infinity,
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/consent/welcome/welcome_hero_1.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stack) {
                      debugPrint('ASSET ERROR welcome_hero_1 -> $error');
                      return Container(
                        color: Colors.red.withValues(alpha: 0.3),
                        child: const Center(
                          child: Text('Asset Load Error',
                            style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SvgPicture.asset(
                      'assets/svg/waves/welcome_01_wave.svg',
                      width: w,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.surface,
                        BlendMode.srcIn,
                      ),
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