import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/screens/onboarding_spacing.dart';

String _formatDateGerman(DateTime d) {
  const months = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

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
  DateTime _date = DateTime(2002, 5, 5);

  String get _formattedDate => _formatDateGerman(_date);

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
                    safeBottom + 198 + spacing.ctaToPicker,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          BackButtonCircle(
                            onPressed: () => context.go(Onboarding01Screen.routeName),
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
                                  fontSize: 24,
                                  height: 32 / 24,
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
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: Spacing.s),
                              Expanded(
                                child: Text(
                                  'Dein Alter hilft uns, deine hormonelle Phase besser '
                                  'einzuschätzen.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.calloutToCta),
                      // CTA Button
                      ElevatedButton(
                        onPressed: () {
                          context.push('/onboarding/03');
                        },
                        child: const Text('Weiter'),
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
                    height: 198,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _date,
                      minimumYear: 1900,
                      maximumYear: DateTime.now().year,
                      onDateTimeChanged: (d) => setState(() => _date = d),
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
