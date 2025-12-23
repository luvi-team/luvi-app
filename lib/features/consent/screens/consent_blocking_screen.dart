import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// C3 - Consent Blocking Screen
///
/// Shown when user tries to proceed without accepting required consents.
/// Only offers one option: "Zurück & Zustimmen" → returns to C2 (ConsentOptionsScreen)
///
/// Route: /consent/blocking
class ConsentBlockingScreen extends StatelessWidget {
  const ConsentBlockingScreen({super.key});

  static const String routeName = '/consent/blocking';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: DsColors.bgCream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ConsentSpacing.pageHorizontal),
          child: Column(
            children: [
              // Scrollable content area (responsive for small screens)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: Spacing.xl),

                      // Shield Icon (Figma: 321 x 249 px, constrained for small screens)
                      // Fix 5: Shadow removed per user request
                      Semantics(
                        label: l10n.consentBlockingShieldSemantic,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 321,
                            maxHeight: mediaQuery.size.height * 0.35,
                          ),
                          child: Image.asset(
                            Assets.consentImages.shield2,
                            fit: BoxFit.contain,
                            errorBuilder: Assets.defaultImageErrorBuilder,
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),

                      // Title (Figma: Playfair Display SemiBold 30px)
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.consentBlockingTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontFamily: FontFamilies.playfairDisplay,
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                            height: 37.5 / 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.m),

                      // Body Text (Figma: Figtree Regular 18px)
                      Text(
                        l10n.consentBlockingBody,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontFamily: FontFamilies.figtree,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          height: 29.25 / 18,
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),
                    ],
                  ),
                ),
              ),

              // Fixed bottom button area
              SizedBox(
                width: double.infinity,
                height: Sizes.buttonHeight,
                child: Semantics(
                  label: l10n.consentBlockingCtaSemantic,
                  child: ElevatedButton(
                    onPressed: () => _handleBack(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DsColors.buttonPrimary,
                      foregroundColor: DsColors.grayscaleWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Sizes.radiusXL),
                      ),
                    ),
                    child: Text(
                      l10n.consentBlockingCtaBack,
                      style: TextStyle(
                        fontFamily: FontFamilies.figtree,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.padding.bottom + Spacing.l),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(ConsentOptionsScreen.routeName);
    }
  }
}
