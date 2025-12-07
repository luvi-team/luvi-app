import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../core/design_tokens/colors.dart';
import '../../../core/design_tokens/sizes.dart';
import '../../../core/design_tokens/spacing.dart';
import '../../../core/design_tokens/typography.dart';

class WelcomeShell extends StatelessWidget {
  WelcomeShell({
    super.key,
    required this.hero,
    required this.heroAspect, // e.g. 438/619
    required this.waveHeightPx, // e.g. 321 (Figma reference)
    this.title,
    this.subtitle,
    this.onNext,
    String? waveAsset,
    this.headerSpacing = 0,
    this.primaryButtonLabel,
    this.subtitleMaxWidth = double.infinity,
    this.bottomContent,
    this.subtitleToButtonGap = Spacing.l,
  }) : waveAsset = waveAsset ?? Assets.images.welcomeWave,
       assert(
         bottomContent != null ||
             (title != null && subtitle != null && onNext != null),
         'Provide either bottomContent or the default welcome parameters '
         '(title, subtitle, onNext).',
       );

  final Widget hero;
  final double heroAspect;
  final double waveHeightPx;
  final Widget? title;
  final String? subtitle;
  final VoidCallback? onNext;
  final String waveAsset;
  final double headerSpacing;
  final String? primaryButtonLabel;
  final double subtitleMaxWidth;
  final Widget? bottomContent;
  final double subtitleToButtonGap;

  @override
  Widget build(BuildContext context) {
    // Inner Scaffold deliberately does not reuse the widget key to avoid GlobalKey clashes.
    return Scaffold(
      body: SafeArea(
        top: false, // Hero darf bis ganz oben (Full-bleed hinter StatusBar)
        bottom: false, // Wave darf full-bleed bis zum unteren Rand
        child: Stack(
          children: [
            // Hero oben, vollständig sichtbar
            Align(
              alignment: Alignment.topCenter,
              child: AspectRatio(aspectRatio: heroAspect, child: hero),
            ),
            // Wave exakt unten
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: waveHeightPx,
                child: SvgPicture.asset(waveAsset, fit: BoxFit.fill),
              ),
            ),
            // Text + CTAs on the wave
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.m, // 16px horizontal (Figma)
                  0,
                  Spacing.m,
                  Spacing.welcomeBottomPadding, // 52px bottom (Figma)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headerSpacing > 0) SizedBox(height: headerSpacing),
                    bottomContent ?? _buildDefaultContent(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    assert(
      l10n != null,
      'AppLocalizations must be provided above WelcomeShell. '
      'Ensure MaterialApp includes localizationsDelegates and supportedLocales.',
    );
    if (l10n == null) {
      throw FlutterError(
        'AppLocalizations not found. Ensure MaterialApp includes '
        'localizationsDelegates and supportedLocales.',
      );
    }
    final buttonLabel = primaryButtonLabel ?? l10n.commonContinue;
    final children = <Widget>[];

    // ─── LOCAL TextStyle Overrides (Figma Polish v2) ───
    // Title: Playfair Display SemiBold (w600), line-height 38/32
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: TypographyTokens.lineHeightRatio38on32,
    );
    // Subtitle: Figtree Regular, line-height 26/20
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      height: TypographyTokens.lineHeightRatio26on20,
    );

    if (title != null) {
      children.add(
        Semantics(
          header: true,
          child: DefaultTextStyle.merge(
            style: titleStyle,
            child: title!,
          ),
        ),
      );
    }
    if (subtitle != null) {
      children.add(const SizedBox(height: Spacing.m)); // 16px gap (Figma)
      children.add(
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: subtitleMaxWidth),
          child: Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: subtitleStyle,
          ),
        ),
      );
    }
    if (onNext != null) {
      children.add(SizedBox(height: subtitleToButtonGap)); // default 24px, W5: 40px
      // ─── LOCAL Button Override (Figma Polish v2) ───
      // Pill shape, #A8406F bg, white text
      children.add(
        ElevatedButton(
          onPressed: onNext!,
          style: ElevatedButton.styleFrom(
            backgroundColor: DsColors.welcomeButtonBg,
            foregroundColor: DsColors.welcomeButtonText,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.radiusWelcomeButton),
            ),
          ),
          child: Text(buttonLabel),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
