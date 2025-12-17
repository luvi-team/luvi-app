import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/onboarding/utils/date_formatters.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
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

  @override
  ConsumerState<Onboarding02Screen> createState() => _Onboarding02ScreenState();
}

class _Onboarding02ScreenState extends ConsumerState<Onboarding02Screen> {
  late DateTime _date;
  bool _hasInteracted = false;

  String _formattedDate(BuildContext context) {
    final localeName = Localizations.localeOf(context).toLanguageTag();
    return DateFormatters.localizedDayMonthYear(
      _date,
      localeName: localeName,
    );
  }

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
    // Default to 25 years old, clamped within Age Policy 16-120
    final now = DateTime.now();
    final targetYear = now.year - 25;
    final month = now.month;
    final daysInMonth = DateTime(targetYear, month + 1, 0).day;
    final clampedDay = now.day > daysInMonth ? daysInMonth : now.day;
    final initialDate = DateTime(targetYear, month, clampedDay);

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
            builder: (context, _) {
              // Stack: Scroll + Picker (keeps CTA visible above picker); padding = picker height (216px) + safeBottom
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildScrollableContent(spacing, safeBottom),
                  _buildDatePicker(safeBottom),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // BirthdatePicker height (280) from birthdate_picker.dart
  static const double _birthdatePickerHeight = 280;

  Widget _buildScrollableContent(OnboardingSpacing spacing, double safeBottom) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        spacing.horizontalPadding,
        spacing.topPadding,
        spacing.horizontalPadding,
        safeBottom + _birthdatePickerHeight + spacing.ctaToPicker,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          SizedBox(height: spacing.headerToDate),
          _buildDateDisplay(),
          SizedBox(height: spacing.dateToUnderline),
          _buildUnderline(spacing),
          SizedBox(height: spacing.underlineToCallout),
          _buildCallout(),
          SizedBox(height: spacing.calloutToCta),
          _buildCta(),
          SizedBox(height: spacing.ctaToPicker),
        ],
      ),
    );
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding01Screen.routeName);
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

  Widget _buildDateDisplay() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final l10n = AppLocalizations.of(context)!;
    final formatted = _formattedDate(context);
    return Semantics(
      label: l10n.selectedDateLabel(formatted),
      child: Text(
        formatted,
        style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUnderline(OnboardingSpacing spacing) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dividerThickness = theme.dividerTheme.thickness ?? 1;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: spacing.underlineWidth,
        child: Divider(
          thickness: dividerThickness,
          color: colorScheme.onSurface.withValues(
            alpha: OpacityTokens.inactive,
          ),
        ),
      ),
    );
  }

  Widget _buildCallout() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dividerThickness = theme.dividerTheme.thickness ?? 1;
    final iconSize = theme.iconTheme.size ?? TypographyTokens.size20;

    final l10n = AppLocalizations.of(context)!;
    final baseTextStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface,
    );

    return Semantics(
      label: l10n.onboarding02CalloutSemantic,
      child: Container(
        padding: const EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(Sizes.radiusM),
          border: Border.all(
            color: colorScheme.primary,
            width: dividerThickness,
          ),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.info_outline,
                color: colorScheme.onSurface,
                size: iconSize,
              ),
            ),
            const SizedBox(width: Spacing.s),
            Expanded(
              child: Text(l10n.onboarding02CalloutBody, style: baseTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCta() {
    final l10n = AppLocalizations.of(context)!;
    return OnboardingButton(
      key: const Key('onb_cta'),
      label: l10n.commonContinue,
      onPressed: () {
        // Save birthDate to OnboardingNotifier
        ref.read(onboardingProvider.notifier).setBirthDate(_date);
        context.pushNamed('onboarding_03_fitness');
      },
      isEnabled: _hasInteracted,
    );
  }

  Widget _buildDatePicker(double safeBottom) {
    // Use custom BirthdatePicker widget (Figma: 333x280px)
    // Age Policy 16-120 is enforced inside BirthdatePicker
    return Positioned(
      left: 0,
      right: 0,
      bottom: safeBottom + Spacing.l,
      child: Center(
        child: BirthdatePicker(
          initialDate: _date,
          onDateChanged: (d) => setState(() {
            _date = d;
            _hasInteracted = true;
          }),
        ),
      ),
    );
  }
}
