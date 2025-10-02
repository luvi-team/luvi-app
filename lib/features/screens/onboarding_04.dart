import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/utils/date_formatters.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';
import 'package:luvi_app/features/screens/onboarding_05.dart';
import 'package:luvi_app/core/constants/onboarding_constants.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';

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

  String get _formattedDate => DateFormatters.germanDayMonthYear(_date);

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
          _buildHeader(),
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

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        BackButtonCircle(
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              context.pop();
            } else {
              context.go(Onboarding03Screen.routeName);
            }
          },
          iconColor: colorScheme.onSurface,
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n?.onboarding04Title ?? 'Wann hat deine letzte Periode angefangen?',
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: TypographyTokens.size24,
                height: TypographyTokens.lineHeightRatio32on24,
              ),
            ),
          ),
        ),
        Semantics(
          label: 'Schritt 4 von 7',
          child: Text(
            '4/7',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateDisplay() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n?.selectedDateLabel(_formattedDate) ?? 'Ausgewähltes Datum: $_formattedDate',
      child: Text(
        _formattedDate,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: spacing.underlineWidth,
        child: Divider(
          thickness: 1,
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
    final localizations = AppLocalizations.of(context);

    return Semantics(
      label: localizations?.onboarding04CalloutSemantics ?? 'Hinweis: Mach dir keine Sorgen, wenn du den exakten Tag nicht mehr weißt. Eine ungefähre Schätzung reicht für den Start völlig aus.',
      child: Container(
        padding: const EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(Sizes.radiusL),
          border: Border.all(
            color: colorScheme.primary,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.info_outline,
                color: colorScheme.onSurface,
                size: 24,
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
                    TextSpan(
                      text: localizations?.onboarding04CalloutPrefix ?? 'Mach dir keine Sorgen, wenn du den ',
                    ),
                    TextSpan(
                      text: localizations?.onboarding04CalloutHighlight ?? 'exakten Tag nicht mehr weißt',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: TypographyTokens.size16,
                        height: TypographyTokens.lineHeightRatio24on16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: localizations?.onboarding04CalloutSuffix ?? '. Eine ungefähre Schätzung reicht für den Start völlig aus.',
                    ),
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
    final localizations = AppLocalizations.of(context);

    return Semantics(
      label: localizations?.commonContinue ?? 'Weiter',
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: _hasInteracted
            ? () {
                context.push(Onboarding05Screen.routeName);
              }
            : null,
        child: Text(localizations?.commonContinue ?? 'Weiter'),
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
