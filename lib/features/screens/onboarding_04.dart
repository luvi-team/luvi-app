import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';
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
  DateTime _date = DateTime(2002, 5, 5);
  bool _hasInteracted = false;

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
                    safeBottom + 198 + spacing.ctaToPicker04,
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
                                context.go(Onboarding03Screen.routeName);
                              }
                            },
                            iconColor: colorScheme.onSurface,
                          ),
                          Expanded(
                            child: Semantics(
                              header: true,
                              label: 'Erzähl mir von dir, Schritt 4 von 7',
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
                            label: 'Schritt 4 von 7',
                            child: Text(
                              '4/7',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.rhythm04),
                      // Question text
                      Semantics(
                        label: 'Wann hat deine letzte Periode angefangen?',
                        child: Text(
                          'Wann hat deine letzte Periode\nangefangen?',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: spacing.rhythm04),
                      // Date display
                      Semantics(
                        label: 'Ausgewähltes Datum: $_formattedDate',
                        child: Text(
                          _formattedDate,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 32,
                            height: 40 / 32,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: spacing.dateToUnderline04),
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
                      SizedBox(height: spacing.rhythm04),
                      // Info callout box
                      Semantics(
                        label:
                            'Hinweis: Mach dir keine Sorgen, wenn du den exakten Tag nicht mehr weißt. '
                            'Eine ungefähre Schätzung reicht für den Start völlig aus.',
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
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.onSurface,
                                size: 24,
                              ),
                              const SizedBox(width: Spacing.s),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontSize: 16,
                                      height: 24 / 16,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text:
                                            'Mach dir keine Sorgen, wenn du den ',
                                      ),
                                      TextSpan(
                                        text: 'exakten Tag nicht mehr weißt',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontSize: 16,
                                          height: 24 / 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            '. Eine ungefähre Schätzung reicht für den Start völlig aus.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.calloutToCta04),
                      // CTA Button
                      Semantics(
                        label: 'Weiter',
                        button: true,
                        child: ElevatedButton(
                          onPressed: _hasInteracted
                              ? () {
                                  // Temporary stub navigation until ONB_05 is implemented
                                  context.push('/onboarding/05');
                                }
                              : null,
                          child: const Text('Weiter'),
                        ),
                      ),
                      SizedBox(height: spacing.ctaToPicker04),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: safeBottom + 32,
                  child: SizedBox(
                    height: 198,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _date,
                      minimumYear: 1900,
                      maximumYear: DateTime.now().year,
                      onDateTimeChanged: (d) => setState(() {
                        _date = d;
                        _hasInteracted = true;
                      }),
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
