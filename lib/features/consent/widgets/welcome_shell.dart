import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../core/design_tokens/sizes.dart';
import '../../../core/design_tokens/spacing.dart';
import 'dots_indicator.dart';

class WelcomeShell extends StatelessWidget {
  WelcomeShell({
    super.key,
    required this.hero,
    required this.heroAspect, // z.B. 438/619
    required this.waveHeightPx, // z.B. 427
    this.title,
    this.subtitle,
    this.onNext,
    this.activeIndex,
    String? waveAsset,
    this.headerSpacing = 0,
    this.primaryButtonLabel,
    this.subtitleMaxWidth = double.infinity,
    this.bottomContent,
  })  : waveAsset = waveAsset ?? Assets.images.welcomeWave,
        assert(
         bottomContent != null ||
             (title != null &&
                 subtitle != null &&
                 onNext != null &&
                 activeIndex != null),
         'Provide either bottomContent or the default welcome parameters.',
       );

  final Widget hero;
  final double heroAspect;
  final double waveHeightPx;
  final Widget? title;
  final String? subtitle;
  final VoidCallback? onNext;
  final int? activeIndex;
  final String waveAsset;
  final double headerSpacing;
  final String? primaryButtonLabel;
  final double subtitleMaxWidth;
  final Widget? bottomContent;

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
            // Text + CTAs auf der Wave
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.l,
                  0,
                  Spacing.l,
                  Spacing.l,
                ),
                child: bottomContent ?? _buildDefaultContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    final theme = Theme.of(context);
    final buttonLabel = primaryButtonLabel ??
        AppLocalizations.of(context)?.commonContinue ??
        'Weiter';
    final skipLabel = AppLocalizations.of(context)?.commonSkip ?? 'Skip';
    final children = <Widget>[];

    final hasContent = title != null || subtitle != null || activeIndex != null || onNext != null;
    if (hasContent && headerSpacing > 0) {
      children.add(SizedBox(height: headerSpacing));
    }

    if (title != null) {
      children.add(Semantics(header: true, child: title!));
    }
    if (title != null && subtitle != null) {
      children.add(const SizedBox(height: Spacing.s));
    }
    if (subtitle != null) {
      children.add(
        Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: subtitleMaxWidth),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }
    if (subtitle != null && activeIndex != null) {
      children.add(const SizedBox(height: Spacing.l));
    }
    if (activeIndex != null) {
      children.add(
        DotsIndicator(count: Sizes.dotsCount, activeIndex: activeIndex!),
      );
    }
    if (activeIndex != null && onNext != null) {
      children.add(const SizedBox(height: Spacing.l));
    }
    if (onNext != null) {
      children.add(
        ElevatedButton(
          onPressed: onNext!,
          child: Text(buttonLabel),
        ),
      );
      children.add(const SizedBox(height: Spacing.m));
    }

    children.add(
      TextButton(
        onPressed: () {
          /* später: skip */
        },
        child: Text(skipLabel),
      ),
    );

    if (children.isNotEmpty) {
      children.add(const SizedBox(height: Spacing.xs));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
