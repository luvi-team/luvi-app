import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/utils/date_formatters.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/constants/onboarding_constants.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, _) {
            final spacing = OnboardingSpacing.of(context);
            final safeBottom = MediaQuery.of(context).padding.bottom;
            return Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    spacing.horizontalPadding,
                    spacing.topPadding,
                    spacing.horizontalPadding,
                    safeBottom + kOnboardingPickerHeight + spacing.ctaToPicker,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          BackButtonCircle(
                            onPressed: () {
                              final router = GoRouter.of(context);
                              if (router.canPop()) {
                                context.pop();
                              } else {
                                context.go(Onboarding01Screen.routeName);
                              }
                            },
                            iconColor: Theme.of(context).colorScheme.onSurface,
                          ),
                          Expanded(
                            child: Semantics(
                              header: true,
                              child: Text(
                                'Erzähl mir von dir 💜',
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontSize: TypographyTokens.size24,
                                  height: TypographyTokens.lineHeightRatio32on24,
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Schritt 2 von 7',
                            child: Text(
                              '2/7',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.headerToInstruction),
                      // Instruction text
                      Text(
                        'Wann hast du Geburtstag',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing.instructionToDate),
                      // Date display
                      Semantics(
                        label: 'Ausgewähltes Datum',
                        child: Text(
                          _formattedDate,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: spacing.dateToUnderline),
                      // Underline divider
                      Align(
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
                      ),
                      SizedBox(height: spacing.underlineToCallout),
                      // Info callout box
                      Semantics(
                        label:
                            'Hinweis: Dein Alter hilft uns, deine hormonelle Phase '
                            'besser einzuschätzen.',
                        child: Container(
                          padding: const EdgeInsets.all(Spacing.m),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(Sizes.radiusM),
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ExcludeSemantics(
                                child: Icon(
                                  Icons.info_outline,
                                  color: colorScheme.onSurface,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: Spacing.s),
                              Expanded(
                                child: Text(
                                  'Dein Alter hilft uns, deine hormonelle Phase besser '
                                  'einzuschätzen.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: TypographyTokens.size14,
                                    height: TypographyTokens.lineHeightRatio24on14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.calloutToCta),
                      // CTA Button
                      Semantics(
                        label: 'Weiter',
                        button: true,
                        child: ElevatedButton(
                          key: const Key('onb_cta'),
                          onPressed: _hasInteracted
                              ? () {
                                  context.push(Onboarding03Screen.routeName);
                                }
                              : null,
                          child: const Text('Weiter'),
                        ),
                      ),
                      SizedBox(height: spacing.ctaToPicker),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: safeBottom + Spacing.l,
                  child: SizedBox(
                    height: kOnboardingPickerHeight,
                    child: Semantics(
                      label: 'Geburtsdatum auswählen',
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
