import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/onboarding/utils/date_formatters.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/widgets/onboarding/onboarding_header.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';
import 'package:luvi_app/features/screens/onboarding_05.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';

/// Onboarding04: Last period start date input screen
/// Figma: 04_Onboarding (Wann hat deine letzte Periode angefangen?)
/// nodeId: 68186-8204
class Onboarding04Screen extends StatefulWidget {
  const Onboarding04Screen({super.key});

  static const routeName = '/onboarding/04';

  @override
  State<Onboarding04Screen> createState() => _Onboarding04ScreenState();
}

class _Onboarding04ScreenState extends State<Onboarding04Screen> {
  DateTime _date = DateTime.now().subtract(const Duration(days: 14));
  bool _hasInteracted = false;

  String _formattedDate(BuildContext context) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return DateFormatters.localizedDayMonthYear(
      _date,
      localeName: localeTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = OnboardingSpacing.of(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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
    );
  }

  Widget _buildScrollableContent(OnboardingSpacing spacing, double safeBottom) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        spacing.horizontalPadding,
        spacing.topPadding,
        spacing.horizontalPadding,
        safeBottom + kOnboardingPickerHeight + spacing.ctaToPicker04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingHeader(
            title: AppLocalizations.of(context)!.onboarding04Title,
            step: 4,
            totalSteps: kOnboardingTotalSteps,
            onBack: _handleBack,
          ),
          SizedBox(height: spacing.headerToDate04),
          _buildDateDisplay(),
          SizedBox(height: spacing.dateToUnderline04),
          _buildUnderline(spacing),
          SizedBox(height: spacing.rhythm04),
          _buildCallout(),
          SizedBox(height: spacing.calloutToCta04),
          _buildCta(),
          SizedBox(height: spacing.ctaToPicker04),
        ],
      ),
    );
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding03Screen.routeName);
    }
  }

  Widget _buildDateDisplay() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final formattedDate = _formattedDate(context);

    return Semantics(
      label: l10n.selectedDateLabel(formattedDate),
      child: Text(
        formattedDate,
        style: textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: TypographyTokens.size32,
          height: TypographyTokens.lineHeightRatio40on32,
        ),
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
    final localizations = AppLocalizations.of(context)!;
    final dividerThickness = theme.dividerTheme.thickness ?? 1;
    final iconSize = theme.iconTheme.size ?? TypographyTokens.size20;

    return Semantics(
      label: localizations.onboarding04CalloutSemantics,
      child: Container(
        padding: const EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(Sizes.radiusL),
          border: Border.all(
            color: colorScheme.primary,
            width: dividerThickness,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              child: RichText(
                text: TextSpan(
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: TypographyTokens.size16,
                    height: TypographyTokens.lineHeightRatio24on16,
                  ),
                  children: [
                    TextSpan(text: localizations.onboarding04CalloutPrefix),
                    TextSpan(
                      text: localizations.onboarding04CalloutHighlight,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: TypographyTokens.size16,
                        height: TypographyTokens.lineHeightRatio24on16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: localizations.onboarding04CalloutSuffix),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCta() {
    final localizations = AppLocalizations.of(context)!;

    return Semantics(
      label: localizations.commonContinue,
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: _hasInteracted
            ? () {
                context.push(Onboarding05Screen.routeName);
              }
            : null,
        child: Text(localizations.commonContinue),
      ),
    );
  }

  Widget _buildDatePicker(double safeBottom) {
    final maxDate = onboardingPeriodStartMaxDate();
    final minDate = onboardingPeriodStartMinDate(maxDate);
    return Positioned(
      left: 0,
      right: 0,
      bottom: safeBottom + Spacing.l,
      child: SizedBox(
        height: kOnboardingPickerHeight,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _date,
          minimumDate: minDate,
          maximumDate: maxDate,
          onDateTimeChanged: (d) => setState(() {
            _date = d;
            _hasInteracted = true;
          }),
        ),
      ),
    );
  }
}
