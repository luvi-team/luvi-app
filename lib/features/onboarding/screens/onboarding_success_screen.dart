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
import 'package:luvi_app/features/onboarding/model/goal.dart';
import 'package:luvi_app/features/onboarding/model/interest.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/circular_progress_ring.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/data/onboarding_backend_writer.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';

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

  final FitnessLevel fitnessLevel;

  @override
  ConsumerState<OnboardingSuccessScreen> createState() =>
      _OnboardingSuccessScreenState();
}

class _OnboardingSuccessScreenState
    extends ConsumerState<OnboardingSuccessScreen> {
  O9AnimationState _state = O9AnimationState.animating;
  final GlobalKey<CircularProgressRingState> _progressKey = GlobalKey();

  // Content cards layout constants (Figma O9 Success Screen specs v3)
  static const double _cardsContainerHeight = 280.0;

  // Card 1 (oben links, vertikal)
  static const double _card1Width = 150.0;
  static const double _card1ImageWidth = 92.0;
  static const double _card1ImageHeight = 127.0;

  // Card 2 (rechts, horizontal) - constrained width to prevent spanning screen
  static const double _card2Width = 180.0;
  static const double _card2Height = 120.0;
  static const double _card2ImageWidth = 46.0;
  static const double _card2ImageHeight = 90.0;
  static const double _card2TopOffset = 60.0;

  // Card 3 (unten, horizontal)
  static const double _card3Width = 133.0;
  static const double _card3Height = 114.0;
  static const double _card3ImageWidth = 46.0;
  static const double _card3ImageHeight = 90.0;
  static const double _card3LeftOffset = 20.0;

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
      final supabaseSuccess = await _saveToSupabase(onboardingData, backendWriter);
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
        () => ref.read(userStateServiceProvider.future),
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

      await userState.markOnboardingComplete(
        fitnessLevel: widget.fitnessLevel,
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
  ) async {
    // Skip if not authenticated (returns true - nothing to do)
    if (!backendWriter.isAuthenticated) {
      log.d('onboarding_skip_supabase: not authenticated', tag: 'onboarding_success');
      return true;
    }

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
        fitnessLevel: data.fitnessLevel?.name ?? widget.fitnessLevel.name,
        goals: data.selectedGoals.map((g) => g.dbKey).toList(),
        interests: data.selectedInterests.map((i) => i.key).toList(),
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
    // Animation restart if available - save triggers via onAnimationComplete
    // Fallback: Direct save if animation state unavailable
    if (_progressKey.currentState != null) {
      _progressKey.currentState!.restart();
    } else {
      // No animation available, directly save
      setState(() {
        _state = O9AnimationState.saving;
      });
      _performSave();
    }
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
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: Spacing.xl),
                // Content preview cards
                _buildContentCards(l10n),
                const Spacer(),
                // Progress ring
                _buildProgressSection(textTheme, colorScheme, l10n),
                const Spacer(),
                // Error retry button (only shown on error)
                if (_state == O9AnimationState.error)
                  _buildRetryButton(l10n),
                SizedBox(height: Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentCards(AppLocalizations l10n) {
    return SizedBox(
      height: _cardsContainerHeight,
      child: Stack(
        children: [
          // Card 1 - oben links (vertikal: Bild oben, Text unten)
          Positioned(
            left: 0,
            top: 0,
            child: _VerticalContentCard(
              imagePath: 'assets/images/onboarding/content_card_1.png',
              text: l10n.onboardingContentCard1,
              width: _card1Width,
              imageWidth: _card1ImageWidth,
              imageHeight: _card1ImageHeight,
            ),
          ),
          // Card 2 - rechts mittig (horizontal: Bild links, Text rechts)
          // NOTE: Full text intentionally kept per Designer decision (Figma v3 review).
          // Width constrained to _card2Width=180 to prevent overflow.
          Positioned(
            right: 0,
            top: _card2TopOffset,
            child: _HorizontalContentCard(
              imagePath: 'assets/images/onboarding/content_card_2.png',
              text: l10n.onboardingContentCard2,
              width: _card2Width,
              height: _card2Height,
              imageWidth: _card2ImageWidth,
              imageHeight: _card2ImageHeight,
            ),
          ),
          // Card 3 - unten links (horizontal: Text links, Bild rechts per Figma)
          Positioned(
            left: _card3LeftOffset,
            bottom: 0,
            child: _HorizontalContentCard(
              imagePath: 'assets/images/onboarding/content_card_3.png',
              text: l10n.onboardingContentCard3,
              width: _card3Width,
              height: _card3Height,
              imageWidth: _card3ImageWidth,
              imageHeight: _card3ImageHeight,
              imageOnRight: true,
            ),
          ),
        ],
      ),
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
        SizedBox(height: Spacing.l),
        Text(
          _getStatusText(l10n),
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontSize: TypographyTokens.size16,
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
class _VerticalContentCard extends StatelessWidget {
  const _VerticalContentCard({
    required this.imagePath,
    required this.text,
    required this.width,
    required this.imageWidth,
    required this.imageHeight,
  });

  final String imagePath;
  final String text;
  final double width;
  final double imageWidth;
  final double imageHeight;

  static const double _textFontSize = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(Spacing.s),
      decoration: DsEffects.successCardGlass,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.radiusCard),
            child: Image.asset(
              imagePath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder: Assets.defaultImageErrorBuilder,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: _textFontSize,
              fontWeight: FontWeight.w500,
              color: DsColors.grayscaleBlack,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal content preview card for O9 Card 2/3
/// Supports image on left (default) or right via [imageOnRight] parameter
class _HorizontalContentCard extends StatelessWidget {
  const _HorizontalContentCard({
    required this.imagePath,
    required this.text,
    this.width,
    required this.height,
    required this.imageWidth,
    required this.imageHeight,
    this.imageOnRight = false,
  });

  final String imagePath;
  final String text;
  final double? width;
  final double height;
  final double imageWidth;
  final double imageHeight;
  final bool imageOnRight;

  static const double _textFontSize = 12.0;

  @override
  Widget build(BuildContext context) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(Sizes.radiusCard),
      child: Image.asset(
        imagePath,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: Assets.defaultImageErrorBuilder,
      ),
    );

    final textWidget = Flexible(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: _textFontSize,
          fontWeight: FontWeight.w500,
          color: DsColors.grayscaleBlack,
        ),
      ),
    );

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(Spacing.s),
      decoration: DsEffects.successCardGlass,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: imageOnRight
            ? [textWidget, const SizedBox(width: Spacing.xs), imageWidget]
            : [imageWidget, const SizedBox(width: Spacing.xs), textWidget],
      ),
    );
  }
}
