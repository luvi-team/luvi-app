import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/widgets/welcome_button.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import 'package:luvi_app/features/consent/widgets/welcome_video_player.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/device_state_service.dart';

/// New Welcome screen with 3 pages (PageView).
///
/// Flow: W1 (Video) → W2 (Image) → W3 (Video) → Auth
/// Device-local flag is set when completing the flow.
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
        backgroundColor: DsColors.welcomeWaveBg,
        body: Stack(
          children: [
            // PageView with 3 welcome pages
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _WelcomePage(
                  hero: WelcomeVideoPlayer(
                    assetPath: Assets.videos.welcomeVideo01,
                    fallbackAsset: Assets.images.welcomeFallback01,
                  ),
                  title: l10n.welcomeNewTitle1,
                  ctaLabel: l10n.welcomeNewCta1,
                  onCta: _nextPage,
                ),
                _WelcomePage(
                  hero: Image.asset(
                    Assets.images.welcomeHero02,
                    fit: BoxFit.cover,
                  ),
                  title: l10n.welcomeNewTitle2,
                  ctaLabel: l10n.welcomeNewCta2,
                  onCta: _nextPage,
                ),
                _WelcomePage(
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
            // Page indicators (positioned at top, adaptive to SafeArea)
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
class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.hero,
    required this.title,
    this.subtitle,
    required this.ctaLabel,
    required this.onCta,
    this.isLoading = false,
  });

  final Widget hero;
  final String title;
  final String? subtitle;
  final String ctaLabel;
  final VoidCallback onCta;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Title style: Playfair Display SemiBold, line-height 38/30
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: TypographyTokens.lineHeightRatio38on32,
    );

    // Subtitle style: Figtree Regular
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      height: TypographyTokens.lineHeightRatio26on20,
      color: DsColors.textSecondary,
    );

    return Column(
      children: [
        // Hero area (full width, aspect ratio from metrics)
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Spacing.l),
            child: Container(
              margin: EdgeInsets.fromLTRB(
                Spacing.m,
                MediaQuery.of(context).padding.top + Spacing.xl + Spacing.m,
                Spacing.m,
                Spacing.m,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Spacing.l),
                color: DsColors.cardBackgroundNeutral,
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: kWelcomeHeroAspect,
                child: hero,
              ),
            ),
          ),
        ),
        // Content area - flexible layout to prevent overflow on smaller screens
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Title block (with optional subtitle)
                Column(
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
                      const SizedBox(height: Spacing.s),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: subtitleStyle,
                      ),
                    ],
                  ],
                ),
                // CTA Button
                WelcomeButton(
                  label: ctaLabel,
                  onPressed: onCta,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Page indicators showing current position in the welcome flow.
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          width: isActive ? Sizes.pageIndicatorActive : Sizes.pageIndicatorDot,
          height: Sizes.pageIndicatorDot,
          decoration: BoxDecoration(
            color: isActive
                ? DsColors.grayscaleBlack
                : DsColors.grayscaleBlack.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(Sizes.pageIndicatorRadius),
          ),
        );
      }),
    );
  }
}
