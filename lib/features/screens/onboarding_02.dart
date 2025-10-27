import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/onboarding/utils/date_formatters.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding02: Birthday input screen
/// Figma: 02_Onboarding (Geburtstag)
/// nodeId: 68219-6350
class Onboarding02Screen extends StatefulWidget {
  const Onboarding02Screen({super.key});

  static const routeName = '/onboarding/02';

  @override
  State<Onboarding02Screen> createState() => _Onboarding02ScreenState();
}

class _Onboarding02ScreenState extends State<Onboarding02Screen> {
  late DateTime _date;
  bool _hasInteracted = false;

  String get _formattedDate => DateFormatters.germanDayMonthYear(_date);

  @override
  void initState() {
    super.initState();
    _date = _computeInitialBirthDate();
  }

  DateTime _computeInitialBirthDate() {
    final now = DateTime.now();
    final targetYear = now.year - 25;
    final month = now.month;
    final daysInMonth = DateTime(targetYear, month + 1, 0).day;
    final clampedDay = now.day > daysInMonth ? daysInMonth : now.day;
    return DateTime(targetYear, month, clampedDay);
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
        safeBottom + kOnboardingPickerHeight + spacing.ctaToPicker,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingHeader(
            title: AppLocalizations.of(context)!.onboarding02Title,
            step: 2,
            totalSteps: kOnboardingTotalSteps,
            onBack: _handleBack,
          ),
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

  Widget _buildDateDisplay() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.selectedDateLabel(_formattedDate),
      child: Text(
        _formattedDate,
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
    return Semantics(
      label: l10n.commonContinue,
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: _hasInteracted
            ? () {
                context.push(Onboarding03Screen.routeName);
              }
            : null,
        child: Text(l10n.commonContinue),
      ),
    );
  }

  Widget _buildDatePicker(double safeBottom) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      left: 0,
      right: 0,
      bottom: safeBottom + Spacing.l,
      child: SizedBox(
        height: kOnboardingPickerHeight,
        child: Semantics(
          label: l10n.onboarding02PickerSemantic,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _date,
            minimumYear: kOnboardingMinBirthYear,
            maximumYear: kOnboardingMaxBirthYear,
            onDateTimeChanged: (d) => setState(() {
              _date = d;
              _hasInteracted = true;
            }),
          ),
        ),
      ),
    );
  }
}
