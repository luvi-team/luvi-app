import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_03_fitness.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/birthdate_picker.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding02: Birthday input screen
/// Figma: 02_Onboarding (Geburtstag)
/// nodeId: 68219-6350
class Onboarding02Screen extends ConsumerStatefulWidget {
  const Onboarding02Screen({super.key});

  static const routeName = '/onboarding/02';

  /// GoRoute name for pushNamed navigation
  static const navName = 'onboarding_02';

  @override
  ConsumerState<Onboarding02Screen> createState() => _Onboarding02ScreenState();
}

class _Onboarding02ScreenState extends ConsumerState<Onboarding02Screen> {
  late DateTime _date;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    // Restore from OnboardingNotifier if available (back navigation)
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.birthDate != null) {
      _date = onboardingState.birthDate!;
      _hasInteracted = true;
    } else {
      _date = _computeInitialBirthDate();
    }
  }

  DateTime _computeInitialBirthDate() {
    // Figma default: June 8, 1992, clamped within Age Policy 16-120
    final initialDate = DateTime(1992, 6, 8);

    // Clamp within Age Policy bounds
    final minDate = onboardingBirthdateMinDate();
    final maxDate = onboardingBirthdateMaxDate();
    if (initialDate.isBefore(minDate)) return minDate;
    if (initialDate.isAfter(maxDate)) return maxDate;
    return initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = OnboardingSpacing.of(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: DsGradients.onboardingStandard,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.horizontalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: Spacing.m),
                        _buildHeader(),
                        SizedBox(height: spacing.headerToSubtitle),
                        _buildSubtitle(),
                        // Picker directly after subtitle (closer, as per Figma)
                        SizedBox(height: Spacing.l),
                        BirthdatePicker(
                          initialDate: _date,
                          onDateChanged: (d) => setState(() {
                            _date = d;
                            _hasInteracted = true;
                          }),
                        ),
                        // Flexible spacer pushes CTA to bottom on tall screens
                        const Spacer(),
                        SizedBox(height: Spacing.m),
                        // CTA Button UNDER Picker (Figma v2)
                        Center(child: _buildCta()),
                        SizedBox(height: Spacing.xl + safeBottom),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.onboarding01);
    }
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingProvider);
    final displayName = onboardingState.name ?? l10n.onboardingDefaultName;

    return OnboardingHeader(
      title: l10n.onboarding02Title(displayName),
      step: 2,
      totalSteps: kOnboardingTotalSteps,
      onBack: _handleBack,
    );
  }

  /// Subtitle text without box or icon (Figma v2)
  /// Font: bodySmall, 14px (smaller than O1)
  Widget _buildSubtitle() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.onboarding02CalloutSemantic,
      child: ExcludeSemantics(
        child: Text(
          l10n.onboarding02CalloutBody,
          style: textTheme.bodySmall?.copyWith(
            fontSize: TypographyTokens.size16,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCta() {
    final l10n = AppLocalizations.of(context)!;
    return OnboardingButton(
      key: const Key(TestKeys.onbCta),
      label: l10n.commonContinue,
      onPressed: () {
        // Save birthDate to OnboardingNotifier
        ref.read(onboardingProvider.notifier).setBirthDate(_date);
        context.pushNamed(Onboarding03FitnessScreen.navName);
      },
      isEnabled: _hasInteracted,
    );
  }
}
