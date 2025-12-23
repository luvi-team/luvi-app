import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/effects.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/onboarding/model/fitness_level.dart';
import 'package:luvi_app/features/onboarding/model/goal.dart';
import 'package:luvi_app/features/onboarding/model/interest.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/circular_progress_ring.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/data/onboarding_backend_writer.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/user_state_service.dart' as services;

const String kErrOnboardingFitnessLevelUnknown =
    'onboarding_fitness_level_unknown';

/// Animation state machine for O9 success screen
enum O9AnimationState {
  animating, // 0-100% Progress animation running
  saving, // Save operation in progress
  error, // Save failed, retry available
  success, // Done, navigation starts
}

/// Final screen after onboarding completes (O9).
/// Shows content preview cards, progress ring animation,
/// then saves data and navigates to home.
class OnboardingSuccessScreen extends ConsumerStatefulWidget {
  const OnboardingSuccessScreen({super.key, required this.fitnessLevel});

  static const routeName = '/onboarding/success';

  /// GoRoute name for pushNamed navigation
  static const navName = 'onboarding_success';

  final services.FitnessLevel fitnessLevel;

  @override
  ConsumerState<OnboardingSuccessScreen> createState() =>
      _OnboardingSuccessScreenState();
}

class _OnboardingSuccessScreenState
    extends ConsumerState<OnboardingSuccessScreen> {
  O9AnimationState _state = O9AnimationState.animating;
  final GlobalKey<CircularProgressRingState> _progressKey = GlobalKey();

  // Figma base dimensions (iPhone 14 Pro: 393×852)
  static const double _figmaBaseWidth = 393.0;
  static const double _figmaBaseHeight = 852.0;

  // Figma v3 exact card positions and sizes
  // All cards shifted up by 30px to move closer to top of screen
  // Card 1 (oben links): x=66, y=51 (was 81), 150×183
  static const double _card1Left = 66.0;
  static const double _card1Top = 51.0; // 81 - 30
  static const double _card1Width = 150.0;
  static const double _card1Height = 183.0;

  // Card 2 (rechts): x=227, y=180 (was 210), 140×120
  static const double _card2Left = 227.0;
  static const double _card2Top = 180.0; // 210 - 30
  static const double _card2Width = 140.0;
  static const double _card2Height = 120.0;

  // Card 3 (unten links): x=79, y=252 (was 282), 133×114
  static const double _card3Left = 79.0;
  static const double _card3Top = 252.0; // 282 - 30
  static const double _card3Width = 133.0;
  static const double _card3Height = 114.0;

  // Cards container height (bottom of card 3 + margin)
  static const double _cardsContainerHeight = 400.0;

  /// Calculates responsive scale factor based on screen size
  /// Uses min of width and height ratios to prevent overflow
  double _scaleFactor(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return min(
      size.width / _figmaBaseWidth,
      size.height / _figmaBaseHeight,
    );
  }

  void _onAnimationComplete() {
    if (!mounted) return;
    setState(() {
      _state = O9AnimationState.saving;
    });
    _performSave();
  }

  Future<void> _performSave() async {
    try {
      // Read all onboarding data from OnboardingNotifier
      final onboardingData = ref.read(onboardingProvider);

      // Backend-SSOT: Validate data completeness FIRST (no fallback values)
      if (!onboardingData.isComplete) {
        log.w(
          'onboarding_data_incomplete',
          tag: 'onboarding_success',
          error: 'Onboarding data is incomplete. Cannot proceed.',
        );
        if (mounted) {
          setState(() {
            _state = O9AnimationState.error;
          });
        }
        return;
      }

      final fitnessLevelId = onboardingData.fitnessLevel?.id;
      if (fitnessLevelId == null) {
        log.w(
          'onboarding_invalid_fitness_level_id',
          tag: 'onboarding_success',
          error: kErrOnboardingFitnessLevelUnknown,
        );
        if (mounted) {
          setState(() {
            _state = O9AnimationState.error;
          });
        }
        return;
      }

      final localFitnessLevel = services.FitnessLevel.tryParse(fitnessLevelId);
      if (localFitnessLevel == null ||
          localFitnessLevel == services.FitnessLevel.unknown) {
        log.w(
          'onboarding_invalid_fitness_level',
          tag: 'onboarding_success',
          error: kErrOnboardingFitnessLevelUnknown,
        );
        if (mounted) {
          setState(() {
            _state = O9AnimationState.error;
          });
        }
        return;
      }

      // Backend-SSOT: User MUST be authenticated to complete onboarding
      final backendWriter = ref.read(onboardingBackendWriterProvider);

      // Block unauthenticated users from completing onboarding
      if (!backendWriter.isAuthenticated) {
        log.w(
          'onboarding_not_authenticated',
          tag: 'onboarding_success',
          error: 'User not authenticated. Cannot complete onboarding.',
        );
        if (mounted) {
          setState(() {
            _state = O9AnimationState.error;
          });
        }
        return;
      }

      // Authenticated user - backend save MUST succeed
      final supabaseSuccess =
          await _saveToSupabase(onboardingData, backendWriter, fitnessLevelId);
      if (!supabaseSuccess) {
        // Backend save failed - do NOT mark local as complete
        log.w(
          'onboarding_backend_save_failed',
          tag: 'onboarding_success',
          error: 'Backend save failed. Local completion blocked.',
        );
        if (mounted) {
          setState(() {
            _state = O9AnimationState.error;
          });
        }
        return;
      }

      // Local save (only after successful backend save for authenticated users)
      final userState = await tryOrNullAsync(
        () => ref.read(services.userStateServiceProvider.future),
        tag: 'userState',
      );

      if (userState == null) {
        log.w(
          'onboarding_user_state_unavailable',
          tag: 'onboarding_success',
          error: 'Cannot complete onboarding: user state service unavailable',
        );
        if (mounted) {
          setState(() {
            _state = O9AnimationState.error;
          });
        }
        return;
      }

      final uid = SupabaseService.currentUser?.id;
      if (uid != null) {
        await userState.bindUser(uid);
      }

      await userState.markOnboardingComplete(
        fitnessLevel: localFitnessLevel,
      );

      if (mounted) {
        setState(() {
          _state = O9AnimationState.success;
        });
        // Navigate to home after short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go(HeuteScreen.routeName);
        }
      }
    } catch (error, stackTrace) {
      log.e(
        'onboarding_mark_complete_failed',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (mounted) {
        setState(() {
          _state = O9AnimationState.error;
        });
      }
    }
  }

  /// Saves onboarding data to Supabase.
  /// Returns true on success, false on failure.
  /// Backend-SSOT: This must succeed for authenticated users before local save.
  Future<bool> _saveToSupabase(
    OnboardingData data,
    OnboardingBackendWriter backendWriter,
    String fitnessLevelId,
  ) async {
    try {
      // data.isComplete was verified in _performSave, so birthDate is guaranteed non-null
      final birthDate = data.birthDate!;
      final now = DateTime.now();
      final age = now.year -
          birthDate.year -
          ((now.month < birthDate.month ||
                  (now.month == birthDate.month && now.day < birthDate.day))
              ? 1
              : 0);

      // Save profile data (data.name is guaranteed non-null by isComplete)
      await backendWriter.upsertProfile(
        displayName: data.name!,
        birthDate: birthDate,
        fitnessLevel: fitnessLevelId,
        goals: data.selectedGoals.map((g) => g.id).toList(),
        interests: data.selectedInterests.map((i) => i.id).toList(),
      );

      // Save cycle data only if periodStart is available
      // (User may have selected "I don't remember" in O6)
      if (data.periodStart != null) {
        await backendWriter.upsertCycleData(
          cycleLength: data.cycleLength,
          periodDuration: data.periodDuration,
          lastPeriod: data.periodStart!,
          age: age,
        );
      } else {
        log.i(
          'onboarding_cycle_skipped: User selected "I don\'t remember"',
          tag: 'onboarding_success',
        );
      }

      // IMPORTANT: Mark onboarding completion only after ALL backend writes
      // succeed. This prevents "completed=true" on the server when a later
      // write fails (save-loop / gate bypass risk).
      await backendWriter.markOnboardingComplete();

      log.d('onboarding_supabase_save_success', tag: 'onboarding_success');
      return true;
    } catch (error, stackTrace) {
      log.e(
        'onboarding_supabase_save_failed',
        tag: 'onboarding_success',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      return false;
    }
  }

  void _handleRetry() {
    // BUG FIX: Set state to animating (not saving) so animation runs correctly
    // Animation will trigger _onAnimationComplete which sets saving state
    setState(() {
      _state = O9AnimationState.animating;
    });

    // Schedule check after widget tree rebuild to avoid race condition
    // between setState and accessing _progressKey.currentState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Animation restart if available - save triggers via onAnimationComplete
      final animationState = _progressKey.currentState;
      if (animationState != null) {
        animationState.restart();
      } else {
        // TODO(tech-debt): Investigate root cause why _progressKey.currentState
        // can be null after first postFrameCallback. Possible causes:
        // - Widget not in tree during error state
        // - GlobalKey conflict
        // - Build order timing issue
        // Retry once more after another frame (defensive workaround)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final retryState = _progressKey.currentState;
          if (retryState != null) {
            retryState.restart();
          } else {
            // Final fallback: direct save without animation
            setState(() {
              _state = O9AnimationState.saving;
            });
            _performSave();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final spacing = OnboardingSpacing.of(context);

    return Scaffold(
      body: Container(
        // Gradient fills entire screen (Figma v2)
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: DsGradients.successScreen,
        ),
        // B4: Restructure to position cards without horizontal padding
        // Cards use absolute Figma coordinates, rest uses padding
        child: SafeArea(
          child: Stack(
            children: [
              // Cards OHNE Padding (absolute Figma-Koordinaten)
              _buildContentCards(l10n),
              // Rest MIT Padding (Progress Ring, Button)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.horizontalPadding,
                  ),
                  child: Column(
                    children: [
                      // Platzhalter für Cards-Bereich
                      SizedBox(
                        height: _cardsContainerHeight * _scaleFactor(context),
                      ),
                      // Figma v3 Fix 5: Flexible Spacer distribution for overflow prevention
                      const Spacer(flex: 2),
                      // Progress ring
                      _buildProgressSection(textTheme, colorScheme, l10n),
                      const Spacer(flex: 1),
                      // Error retry button with reduced bottom padding
                      if (_state == O9AnimationState.error) ...[
                        _buildRetryButton(l10n),
                        const SizedBox(height: Spacing.m), // Reduced from Spacing.xl
                      ] else
                        const SizedBox(height: Spacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCards(AppLocalizations l10n) {
    final scale = _scaleFactor(context);

    // Stack with absolute positioned cards per Figma coordinates
    return Stack(
      clipBehavior: Clip.none,
      children: [
          // Card 1 - oben links (vertikal: Bild oben, Text unten)
          // Figma v3: x=66, y=81, 150×183, Purple background
          Positioned(
            left: _card1Left * scale,
            top: _card1Top * scale,
            child: _VerticalContentCard(
              imagePath: 'assets/images/onboarding/content_card_1.png',
              text: l10n.onboardingContentCard1,
              width: _card1Width * scale,
              height: _card1Height * scale,
              scaleFactor: scale,
              decoration: DsEffects.successCardPurple,
            ),
          ),
          // Card 2 - rechts (horizontal: Bild links, Text rechts)
          // Figma v3: x=227, y=210, 140×120, Cyan background
          Positioned(
            left: _card2Left * scale,
            top: _card2Top * scale,
            child: _HorizontalContentCard(
              imagePath: 'assets/images/onboarding/content_card_2.png',
              text: l10n.onboardingContentCard2,
              width: _card2Width * scale,
              height: _card2Height * scale,
              scaleFactor: scale,
              decoration: DsEffects.successCardCyan,
            ),
          ),
          // Card 3 - unten links (horizontal: Text links, Bild rechts)
          // Figma v3: x=79, y=282, 133×114, Pink background
          // Plan v3 Final: Image closer to text via smaller gap
          Positioned(
            left: _card3Left * scale,
            top: _card3Top * scale,
            child: _HorizontalContentCard(
              imagePath: 'assets/images/onboarding/content_card_3.png',
              text: l10n.onboardingContentCard3,
              width: _card3Width * scale,
              height: _card3Height * scale,
              scaleFactor: scale,
              imageOnRight: true,
              gap: Spacing.successCard3Gap,
              decoration: DsEffects.successCardPink,
            ),
          ),
        ],
      );
  }

  Widget _buildProgressSection(
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressRing(
          key: _progressKey,
          duration: const Duration(seconds: 3),
          onAnimationComplete: _onAnimationComplete,
          isSpinning: _state != O9AnimationState.success,
        ),
        const SizedBox(height: Spacing.l),
        Text(
          _getStatusText(l10n),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: TypographyTokens.size16,
            fontWeight: FontWeight.w500, // Figma v3: System Medium
            color: DsColors.grayscaleBlack,
          ),
        ),
      ],
    );
  }

  String _getStatusText(AppLocalizations l10n) {
    return switch (_state) {
      O9AnimationState.animating => l10n.onboardingSuccessLoading,
      O9AnimationState.saving => l10n.onboardingSuccessSaving,
      O9AnimationState.error => l10n.onboardingSaveError,
      O9AnimationState.success => l10n.onboardingSuccessComplete,
    };
  }

  Widget _buildRetryButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.l),
      child: Center(
        child: OnboardingButton(
          label: l10n.onboardingRetryButton,
          onPressed: _handleRetry,
          isEnabled: true,
        ),
      ),
    );
  }
}

/// Vertical content preview card (Bild oben, Text unten) for O9 Card 1
/// Figma v3: Fixed card dimensions with auto-fit text
class _VerticalContentCard extends StatelessWidget {
  const _VerticalContentCard({
    required this.imagePath,
    required this.text,
    required this.width,
    required this.height,
    required this.scaleFactor,
    required this.decoration,
  });

  final String imagePath;
  final String text;
  final double width;
  final double height;
  final double scaleFactor;
  final BoxDecoration decoration;

  // Figma v3: Base font sizes that scale with screen
  static const double _maxFontSize = 12.0;
  static const double _minFontSize = 9.0;

  @override
  Widget build(BuildContext context) {
    // Figma v3: Use token-based padding (MUST-02 compliant)
    final cardPadding = Spacing.successCard1Padding(scaleFactor);
    // Figma v3: Use token-based image dimensions (92×127)
    final imageWidth = Sizes.successCard1ImageWidth * scaleFactor;
    final imageHeight = Sizes.successCard1ImageHeight * scaleFactor;

    return Container(
      width: width,
      height: height,
      padding: cardPadding,
      decoration: decoration,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.radiusCard * scaleFactor),
            child: Image.asset(
              imagePath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder: Assets.defaultImageErrorBuilder,
            ),
          ),
          SizedBox(height: Spacing.successCard1Gap * scaleFactor),
          // Auto-fit text takes remaining space
          Expanded(
            child: _AutoFitText(
              text: text,
              maxFontSize: _maxFontSize * scaleFactor,
              minFontSize: _minFontSize * scaleFactor,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal content preview card for O9 Card 2/3
/// Figma v3: Fixed card dimensions with auto-fit text
/// Supports image on left (default) or right via [imageOnRight] parameter
class _HorizontalContentCard extends StatelessWidget {
  const _HorizontalContentCard({
    required this.imagePath,
    required this.text,
    required this.width,
    required this.height,
    required this.scaleFactor,
    required this.decoration,
    this.imageOnRight = false,
    this.gap,
  });

  final String imagePath;
  final String text;
  final double width;
  final double height;
  final double scaleFactor;
  final BoxDecoration decoration;
  final bool imageOnRight;
  /// Custom gap between image and text. Defaults to Spacing.successCard2Gap.
  final double? gap;

  // Figma v3: Base font sizes that scale with screen
  static const double _maxFontSize = 12.0;
  static const double _minFontSize = 9.0;

  @override
  Widget build(BuildContext context) {
    // Figma v3: Use token-based padding (MUST-02 compliant)
    final cardPadding = Spacing.successCard2Padding(scaleFactor);
    // Figma v3: Use token-based image dimensions (46×90)
    final imageWidth = Sizes.successCardSmallImageWidth * scaleFactor;
    final imageHeight = Sizes.successCardSmallImageHeight * scaleFactor;

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(Sizes.radiusCard * scaleFactor),
      child: Image.asset(
        imagePath,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: Assets.defaultImageErrorBuilder,
      ),
    );

    // Text takes remaining space via Expanded
    final textWidget = Expanded(
      child: _AutoFitText(
        text: text,
        maxFontSize: _maxFontSize * scaleFactor,
        minFontSize: _minFontSize * scaleFactor,
        textAlign: TextAlign.start,
      ),
    );

    // Use custom gap if provided, otherwise default to Card2 gap
    final effectiveGap = (gap ?? Spacing.successCard2Gap) * scaleFactor;

    return Container(
      width: width,
      height: height,
      padding: cardPadding,
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: imageOnRight
            ? [
                textWidget,
                SizedBox(width: effectiveGap),
                imageWidget,
              ]
            : [
                imageWidget,
                SizedBox(width: effectiveGap),
                textWidget,
              ],
      ),
    );
  }
}

/// Auto-fit text widget that finds the largest font size that fits
/// within the available space using TextPainter measurement.
/// Figma v3: Ensures text is always fully visible without overflow.
class _AutoFitText extends StatelessWidget {
  const _AutoFitText({
    required this.text,
    required this.maxFontSize,
    required this.minFontSize,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double maxFontSize;
  final double minFontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    // A11y: Account for system text scaling
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Apply text scaling to font size bounds
        final scaledMax = textScaler.scale(maxFontSize);
        final scaledMin = textScaler.scale(minFontSize);

        // Guard against inverted ranges
        if (scaledMin > scaledMax) {
          return Text(
            text,
            textAlign: textAlign,
            maxLines: null,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: scaledMin,
              fontWeight: FontWeight.w500,
              color: DsColors.grayscaleBlack,
            ),
          );
        }

        // Binary search for largest font size that fits (O(log n) vs O(n))
        double lo = scaledMin;
        double hi = scaledMax;
        double fontSize = scaledMin;

        while (hi - lo > 0.5) {
          final mid = (lo + hi) / 2;
          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: mid,
                fontWeight: FontWeight.w500,
              ),
            ),
            textDirection: TextDirection.ltr,
            maxLines: null,
          );
          textPainter.layout(maxWidth: availableWidth);

          if (textPainter.height <= availableHeight) {
            fontSize = mid; // This size fits, try larger
            lo = mid;
          } else {
            hi = mid; // Too big, try smaller
          }
        }

        return Text(
          text,
          textAlign: textAlign,
          maxLines: null,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: DsColors.grayscaleBlack,
          ),
        );
      },
    );
  }
}
