import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/nova_health_tokens.dart';
import 'package:luvi_app/features/consent/widgets/primary_cta_button.dart';
import 'package:luvi_app/features/consent/widgets/home_indicator.dart';

class ConsentWelcomeScreen extends StatelessWidget {
  const ConsentWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaHealthTokens.grayscaleWhite,
      body: Stack(
        children: [
          Positioned(
            left: -162,
            top: -10,
            width: 740,
            height: 1100,
            child: Container(
              color: NovaHealthTokens.surfaceSecondary,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: NovaHealthTokens.grayscaleBlack.withValues(alpha: 0.5),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Lass uns LUVI\nauf dich abstimmen 💜',
                    style: NovaHealthTokens.headingH1.copyWith(
                      color: NovaHealthTokens.surfacePrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Du entscheidest, was du teilen möchtest. Je mehr wir über dich wissen, desto besser können wir dich unterstützen.',
                    style: NovaHealthTokens.bodyRegular.copyWith(
                      color: NovaHealthTokens.accentSubtle,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 100),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: PrimaryCtaButton(label: 'Weiter'),
                ),
                const SizedBox(height: 50),
                const HomeIndicator(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}