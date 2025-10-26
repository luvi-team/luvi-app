import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/services/user_state_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Consent02Screen extends ConsumerWidget {
  const Consent02Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final state = ref.watch(consent02NotifierProvider);
    final notifier = ref.read(consent02NotifierProvider.notifier);
    bool isSelected(ConsentScope scope) => state.choices[scope] == true;

    return Scaffold(
      body: Column(
        children: [
          // TOP zone: Back + H1
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackButtonCircle(
                    onPressed: () {
                      final r = GoRouter.of(context);
                      if (r.canPop()) {
                        context.pop();
                      } else {
                        context.go('/consent/01');
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 7,
                ), // align gap with Consent01 between back and title
                Semantics(
                  header: true,
                  child: Text(
                    'Deine Gesundheit,\ndeine Entscheidung!',
                    textAlign: TextAlign.center,
                    style: t.displaySmall?.copyWith(
                      color: c.onSurface,
                      fontFamily: FontFamilies.playfairDisplay,
                      fontSize: 32,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // MIDDLE zone: scrollable cards constrained between TOP and BOTTOM
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                _ConsentChoiceCard(
                  key: const Key('consent02_card_required_health'),
                  title: 'health_processing',
                  body:
                      'Ich bin damit einverstanden, dass LUVI meine persönlichen Gesundheitsdaten verarbeitet, damit LUVI ihre Funktionen bereitstellen kann.',
                  selected: isSelected(ConsentScope.health_processing),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.health_processing);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  key: const Key('consent02_card_required_terms'),
                  title: 'terms',
                  body: 'Ich erkläre mich mit der',
                  selected: isSelected(ConsentScope.terms),
                  trailing: _buildLinkTrailing(context),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.terms);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  key: const Key('consent02_card_required_ai_journal'),
                  title: 'ai_journal',
                  body:
                      'Ich bin damit einverstanden, dass LUVI künstliche Intelligenz nutzt, um meine Trainings-, Ernährungs- und Regenerationsempfehlungen in einem personalisierten Journal für mich zusammenzufassen.',
                  selected: isSelected(ConsentScope.ai_journal),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.ai_journal);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  title: 'analytics',
                  body:
                      'Ich bin damit einverstanden, dass pseudonymisierte Nutzungs- und Gerätedaten zu Analysezwecken verarbeitet werden, damit LUVI Stabilität und Benutzerfreundlichkeit verbessern kann.*',
                  selected: isSelected(ConsentScope.analytics),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.analytics);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  title: 'marketing',
                  body:
                      'Ich stimme zu, dass LUVI meine persönlichen Daten und Nutzungsdaten verarbeitet, um mir personalisierte Empfehlungen zu relevanten LUVI-Inhalten und Informationen zu Angeboten per In-App-Hinweisen, E-Mail und/oder Push-Mitteilungen zuzusenden.*',
                  selected: isSelected(ConsentScope.marketing),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.marketing);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  title: 'model_training',
                  body:
                      'Ich willige ein, dass pseudonymisierte Nutzungs- und Gesundheitsdaten zur Qualitätssicherung und Verbesserung von Empfehlungen verwendet werden (z. B. Überprüfung der Genauigkeit von Zyklusvorhersagen).*',
                  selected: isSelected(ConsentScope.model_training),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.model_training);
                  },
                ),
              ],
            ),
          ),

          // BOTTOM zone: sticky CTA
          Material(
            color: c.surface,
            elevation: 2,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: _ConsentFooter(
                  key: const Key('consent02_footer'),
                  onAcceptAll: notifier.selectAllOptional,
                  isAcceptAllDisabled: state.allOptionalSelected,
                  onNext: () async {
                    final userState = await tryOrNullAsync(
                      () => ref.read(userStateServiceProvider.future),
                      tag: 'userState',
                    );
                    await userState?.markWelcomeSeen();
                    if (context.mounted) {
                      context.go('/auth/entry');
                    }
                  },
                  nextEnabled: state.requiredAccepted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InlineSpan _buildLinkTrailing(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final baseStyle = textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamilies.figtree,
        ) ??
        TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamilies.figtree,
        );
    final privacyUri = Uri.parse(
      'https://DEINE-DOMAIN.tld/datenschutzerklaerung',
    ); // TODO: replace with real URL
    final termsUri = Uri.parse(
      'https://DEINE-DOMAIN.tld/nutzungsbedingungen',
    ); // TODO: replace with real URL

    Future<void> open(Uri uri) async {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link konnte nicht geöffnet werden')),
        );
      }
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: _LinkText(
        key: const ValueKey('consent02_terms_links'),
        style: baseStyle,
        parts: [
          const LinkTextPart(' '),
          LinkTextPart(
            'Datenschutzerklärung',
            onTap: () => open(privacyUri),
            bold: true,
            color: colorScheme.primary,
          ),
          const LinkTextPart(' sowie den '),
          LinkTextPart(
            'Nutzungsbedingungen',
            onTap: () => open(termsUri),
            bold: true,
            color: colorScheme.primary,
          ),
          const LinkTextPart(' einverstanden.'),
        ],
      ),
    );
  }
}

class LinkTextPart {
  final String text;
  final VoidCallback? onTap;
  final bool bold;
  final Color? color;

  const LinkTextPart(
    this.text, {
    this.onTap,
    this.bold = false,
    this.color,
  });
}

class _LinkText extends StatelessWidget {
  final TextStyle style;
  final List<LinkTextPart> parts;

  const _LinkText({
    super.key,
    required this.style,
    required this.parts,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: parts.map((part) {
          final weightStyle = part.bold
              ? style.copyWith(fontWeight: FontWeight.w700)
              : style;
          if (part.onTap == null) {
            return TextSpan(
              text: part.text,
              style: weightStyle,
            );
          }
          return WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: InkWell(
              onTap: part.onTap,
              child: Semantics(
                link: true,
                button: true,
                child: Text(
                  part.text,
                  style: weightStyle.copyWith(color: part.color),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ConsentChoiceCard extends StatelessWidget {
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;
  final InlineSpan? trailing;

  const _ConsentChoiceCard({
    super.key,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ds = theme.extension<DsTokens>();
    final borderRadius = BorderRadius.circular(Sizes.radiusL);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamilies.figtree,
        ) ??
        TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamilies.figtree,
        );

    return Semantics(
      button: true,
      toggled: selected,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: (ds?.cardSurface) ?? colorScheme.surfaceContainer,
              borderRadius: borderRadius,
              border: selected
                  ? Border.all(
                      color: (ds?.cardBorderSelected) ?? colorScheme.onSurface,
                      width: 1,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 35,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: trailing == null
                        ? Text(body, style: textStyle)
                        : RichText(
                            text: TextSpan(
                              style: textStyle,
                              children: [
                                TextSpan(text: body),
                                trailing!,
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(width: 20),
                  Semantics(
                    label: selected ? 'Ausgewählt' : 'Nicht ausgewählt',
                    selected: selected,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 2,
                        ),
                        color: Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: selected
                          ? Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentFooter extends StatelessWidget {
  final VoidCallback onAcceptAll;
  final bool isAcceptAllDisabled;
  final VoidCallback? onNext;
  final bool nextEnabled;

  const _ConsentFooter({
    super.key,
    required this.onAcceptAll,
    required this.isAcceptAllDisabled,
    required this.onNext,
    required this.nextEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Deine Zustimmung kannst du jederzeit in der App oder unter hello@getluvi.com widerrufen.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 14,
            height: 1.28,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isAcceptAllDisabled ? null : onAcceptAll,
            child: const Text('Alle akzeptieren'),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            key: const Key('consent02_btn_next'),
            onPressed: nextEnabled ? onNext : null,
            child: const Text('Weiter'),
          ),
        ),
      ],
    );
  }
}
