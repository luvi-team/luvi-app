import 'dart:math' as math;

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
/// Responsive layout strategy:
/// - Hero scales based on screen width (max 354px, maintains 354:475 aspect)
/// - Uses SafeArea for proper inset handling
/// - Top section (Hero + Headline) is scrollable if needed
/// - CTA is fixed at bottom with consistent 38px spacing to home indicator
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
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          // Calculate responsive hero size
          // Figma: 354×475 on 393px wide screen = ~90% width
          // Max hero width is 354px, scales down on smaller screens
          final heroWidth = math.min(
            Sizes.welcomeHeroWidth,
            availableWidth - (Spacing.screenPadding * 2),
          );
          final heroHeight = heroWidth / Sizes.welcomeHeroAspect;

          return Column(
            children: [
              // Scrollable top section (Hero + Headline)
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top spacing (below page indicators)
                      const SizedBox(height: Spacing.l),

                      // Hero frame with border
                      _HeroFrame(
                        hero: hero,
                        width: heroWidth,
                        height: heroHeight,
                      ),

                      // Gap between hero and headline
                      const SizedBox(height: Spacing.xl),

                      // Headline block (typography varies by page)
                      _HeadlineBlock(
                        pageIndex: pageIndex,
                        title: title,
                        subtitle: subtitle,
                      ),

                      // Minimum gap before CTA (scrollable area ends here)
                      const SizedBox(height: Spacing.xl),
                    ],
                  ),
                ),
              ),

              // Fixed bottom section (CTA always visible, consistent position)
              WelcomeCtaButton(
                label: ctaLabel,
                onPressed: onCta,
                isLoading: isLoading,
              ),
              const SizedBox(height: Spacing.welcomeCtaBottomPadding),
            ],
          );
        },
      ),
    );
  }
}

/// Hero frame with border, radius, and clipped content.
///
/// Figma specs:
/// - Max Width: 354px, Height maintains 354:475 aspect ratio
/// - Border radius: 24px (fixed, not scaled)
/// - Border: 1px solid #000000
class _HeroFrame extends StatelessWidget {
  const _HeroFrame({
    required this.hero,
    required this.width,
    required this.height,
  });

  final Widget hero;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Fix radius at 24px, but cap at half the smaller dimension
    // to prevent radius larger than frame on very small screens
    final maxRadius = math.min(width, height) / 2;
    final radius = math.min(Sizes.welcomeHeroRadius, maxRadius);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFF000000), // Figma: #000000 (pure black)
          width: Sizes.welcomeHeroBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          math.max(0, radius - Sizes.welcomeHeroBorderWidth),
        ),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: Sizes.welcomeHeroWidth,
              height: Sizes.welcomeHeroHeight,
              child: hero,
            ),
          ),
        ),
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
///       + Subheader: Playfair Display 20px Bold 700, line-height 38px
class _HeadlineBlock extends StatelessWidget {
  const _HeadlineBlock({
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: Spacing.xs), // Figma: 8px
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Sizes.welcomeSubheaderWidth,
              ),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamilies.playfairDisplay,
                  fontSize: TypographyTokens.size20,
                  fontWeight: FontWeight.w700,
                  height: 38 / 20, // Figma: line-height 38px
                  color: DsColors.grayscaleBlack,
                ),
              ),
            ),
          ],
        ],
      ),
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
