import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/consent/widgets/welcome_video_player.dart';
import 'package:luvi_app/features/welcome/widgets/welcome_cta_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/device_state_service.dart';

/// New Welcome screen with 3 pages (PageView).
///
/// Flow: W1 (Video) → W2 (Image) → W3 (Video) → Auth
/// Device-local flag is set when completing the flow.
///
/// Figma SSOT: context/design/welcome-rebrand/figma-audit.md
/// Figma reference device: iPhone 14 Pro (393×852)
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  static const String routeName = '/welcome';

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeWelcome() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    try {
      final deviceState = await ref.read(deviceStateServiceProvider.future);
      await deviceState.markWelcomeCompleted();
      if (mounted) {
        context.go(RoutePaths.authSignIn);
      }
    } catch (e) {
      // Best-effort: navigate anyway (flag can be set on next launch)
      if (mounted) {
        context.go(RoutePaths.authSignIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        // Figma: Background #F9F1E6
        backgroundColor: DsColors.splashBg,
        body: Stack(
          children: [
            // PageView with 3 welcome pages
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                // Page 1: Video + "Dein Zyklus. Deine Kraft. Jeden Tag."
                _WelcomePage(
                  pageIndex: 0,
                  hero: WelcomeVideoPlayer(
                    assetPath: Assets.videos.welcomeVideo01,
                    fallbackAsset: Assets.images.welcomeFallback01,
                  ),
                  title: l10n.welcomeNewTitle1,
                  ctaLabel: l10n.welcomeNewCta1,
                  onCta: _nextPage,
                ),
                // Page 2: Static Image + "Dein Rhythmus führt. LUVI folgt."
                _WelcomePage(
                  pageIndex: 1,
                  hero: Image.asset(
                    Assets.images.welcomeHero02,
                    fit: BoxFit.cover,
                  ),
                  title: l10n.welcomeNewTitle2,
                  ctaLabel: l10n.welcomeNewCta2,
                  onCta: _nextPage,
                ),
                // Page 3: Video + "Alles bereit." + Subline
                _WelcomePage(
                  pageIndex: 2,
                  hero: WelcomeVideoPlayer(
                    assetPath: Assets.videos.welcomeVideo03,
                    fallbackAsset: Assets.images.welcomeFallback03,
                  ),
                  title: l10n.welcomeNewTitle3,
                  subtitle: l10n.welcomeNewSubtitle3,
                  ctaLabel: l10n.welcomeNewCta3,
                  onCta: _completeWelcome,
                  isLoading: _isCompleting,
                ),
              ],
            ),
            // Page indicators (positioned at top, after SafeArea)
            Positioned(
              top: MediaQuery.of(context).padding.top + Spacing.m,
              left: 0,
              right: 0,
              child: _PageIndicators(
                key: const Key('welcome_page_indicators'),
                currentPage: _currentPage,
                totalPages: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual welcome page within the PageView.
///
/// Responsive column layout with fixed hero and flexible content area:
/// - Hero fixed at 354×475px on ≥393px viewport, scales down proportionally
/// - AC-1: Dots→Hero = 24px (bottom-to-top)
/// - Content area (text block) uses Expanded for responsive spacing
/// - Text block has fixed height (108px W1/W2, 75px W3) for visual consistency
/// - Flexible gaps between hero↔text and text↔CTA prevent overflow on all devices
class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.pageIndex,
    required this.hero,
    required this.title,
    this.subtitle,
    required this.ctaLabel,
    required this.onCta,
    this.isLoading = false,
  });

  final int pageIndex;
  final Widget hero;
  final String title;
  final String? subtitle;
  final String ctaLabel;
  final VoidCallback onCta;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    // Hero top offset (AC-1: 24px gap from dots-bottom to hero-top)
    // Dots at safeTop + 16, height 4px → bottom at safeTop + 20
    // Hero at safeTop + 44 → gap = 44 - 20 = 24px ✓
    final heroTopOffset = safeTop + Spacing.welcomeHeroTopOffset;

    // Hero dimensions (AC-2: 354×475 on ≥393px, scales down proportionally)
    // Available width = screen - left padding (asymmetric layout)
    final availableWidth = screenWidth - Spacing.screenPadding;
    final heroWidth = availableWidth >= Sizes.welcomeHeroWidth
        ? Sizes.welcomeHeroWidth
        : availableWidth;
    final heroHeight = heroWidth / Sizes.welcomeHeroAspect;

    return Column(
      children: [
        // Spacer to position hero (accounts for safe area + offset)
        SizedBox(height: heroTopOffset),

        // Hero Frame (354×475 on ≥393px, scales down on smaller screens)
        Padding(
          padding: const EdgeInsets.only(left: Spacing.screenPadding),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _HeroFrame(
              key: const Key('welcome_hero_frame'),
              hero: hero,
              width: heroWidth,
              height: heroHeight,
            ),
          ),
        ),

        // Flexible content area: distributes space between hero and CTA
        // Uses Expanded to prevent overflow on smaller screens while
        // maintaining visual consistency across all 3 welcome pages
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Headline Block grows naturally with content
              // Expanded distributes remaining space evenly above/below
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: Spacing.screenPadding),
                child: _HeadlineBlock(
                  key: const Key('welcome_headline_block'),
                  pageIndex: pageIndex,
                  title: title,
                  subtitle: subtitle,
                ),
              ),
            ],
          ),
        ),

        // CTA Button (centered)
        WelcomeCtaButton(
          key: const Key('welcome_cta_button'),
          label: ctaLabel,
          onPressed: onCta,
          isLoading: isLoading,
        ),

        // Bottom padding (38px + safe area)
        SizedBox(height: Spacing.welcomeCtaBottomPadding + safeBottom),
      ],
    );
  }
}

/// Hero frame with border, radius, and clipped content.
///
/// Figma specs:
/// - Width: 354px, Height: 475px (fixed on ≥393px viewport)
/// - Border radius: 24px
/// - Border: 1px solid #000000
///
/// Uses Single-Clip + Border Overlay pattern to avoid anti-aliasing
/// artifacts ("thick spots") from double-clipping (AC-3).
class _HeroFrame extends StatelessWidget {
  const _HeroFrame({
    super.key,
    required this.hero,
    required this.width,
    required this.height,
  });

  final Widget hero;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Content with SINGLE clip (no double-clipping!)
          ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.welcomeHeroRadius),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: Sizes.welcomeHeroWidth,
                  height: Sizes.welcomeHeroHeight,
                  child: hero,
                ),
              ),
            ),
          ),
          // Border as overlay (AC-3: DsColors.grayscaleBlack, no thick spots)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Sizes.welcomeHeroRadius),
                  border: Border.all(
                    color: DsColors.grayscaleBlack,
                    width: Sizes.welcomeHeroBorderWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Headline block with page-specific typography.
///
/// Figma specs:
/// - W1: Playfair Display 28px Bold 700, line-height 36px
/// - W2: Playfair Display 30px Bold 700, line-height 38px
/// - W3: Playfair Display 32px SemiBold 600, line-height 38px
///       + Subheader: Figtree 20px Regular 400, line-height 26px
class _HeadlineBlock extends StatelessWidget {
  const _HeadlineBlock({
    super.key,
    required this.pageIndex,
    required this.title,
    this.subtitle,
  });

  final int pageIndex;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    // Get page-specific typography
    final (fontSize, fontWeight, lineHeight) = _getTypography();

    final titleStyle = TextStyle(
      fontFamily: FontFamilies.playfairDisplay,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: lineHeight,
      color: DsColors.grayscaleBlack,
    );

    // Note: Horizontal padding handled by parent SizedBox in _WelcomePage
    // mainAxisAlignment.center ensures text is vertically centered within
    // the fixed-height container for visual consistency across all pages
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: Spacing.xs), // Figma: 8px (AC-6)
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Sizes.welcomeSubheaderWidth,
            ),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontFamilies.figtree, // Figma: Figtree
                fontSize: TypographyTokens.size20,
                fontWeight: FontWeight.w400, // Figma: Regular
                height: TypographyTokens.lineHeightRatio26on20, // 26/20
                color: DsColors.grayscaleBlack,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Returns (fontSize, fontWeight, lineHeight) based on page index.
  (double, FontWeight, double) _getTypography() {
    switch (pageIndex) {
      case 0:
        // W1: 28px Bold, line-height 36/28
        return (
          TypographyTokens.size28,
          FontWeight.w700,
          TypographyTokens.lineHeightRatio36on28,
        );
      case 1:
        // W2: 30px Bold, line-height 38/30
        return (
          TypographyTokens.size30,
          FontWeight.w700,
          TypographyTokens.lineHeightRatio38on30,
        );
      case 2:
      default:
        // W3: 32px SemiBold, line-height 38/32
        return (
          TypographyTokens.size32,
          FontWeight.w600,
          TypographyTokens.lineHeightRatio38on32,
        );
    }
  }
}

/// Page indicators showing current position in the welcome flow.
///
/// Figma specs:
/// - Height: 4px
/// - Active width: 32px, Inactive width: 24px
/// - Gap: 8px
/// - Active color: #030401 (grayscaleBlack)
/// - Inactive color: #DCDCDC (gray300)
/// - Border radius: pill (999px)
class _PageIndicators extends StatelessWidget {
  const _PageIndicators({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 0 : Sizes.pageIndicatorGap / 2,
            right: index == totalPages - 1 ? 0 : Sizes.pageIndicatorGap / 2,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive
                ? Sizes.pageIndicatorActiveWidth
                : Sizes.pageIndicatorInactiveWidth,
            height: Sizes.pageIndicatorHeight,
            decoration: BoxDecoration(
              color: isActive ? DsColors.grayscaleBlack : DsColors.gray300,
              borderRadius: BorderRadius.circular(Sizes.pageIndicatorRadius),
            ),
          ),
        );
      }),
    );
  }
}
