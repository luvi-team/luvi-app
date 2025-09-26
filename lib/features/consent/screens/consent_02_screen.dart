import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';

class Consent02Screen extends ConsumerWidget {
  const Consent02Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final ds = Theme.of(context).extension<DsTokens>();

    final state = ref.watch(consent02NotifierProvider);
    final notifier = ref.read(consent02NotifierProvider.notifier);

    Widget indicator(bool selected) {
      return Semantics(
        label: selected ? 'Ausgewählt' : 'Nicht ausgewählt',
        selected: selected,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.outline, width: 2),
            color: Colors.transparent,
          ),
          alignment: Alignment.center,
          child: selected
              ? Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.primary,
                  ),
                )
              : null,
        ),
      );
    }

    Widget scopeCard({
      required String body,
      required ConsentScope scope,
      InlineSpan? trailingLinks,
      Key? cardKey,
    }) {
      final selected = state.choices[scope] == true;
      final borderRadius = BorderRadius.circular(Sizes.radiusL);
      return Semantics(
        button: true,
        toggled: selected,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            key: cardKey,
            borderRadius: borderRadius,
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.toggle(scope);
            },
            child: Ink(
              decoration: BoxDecoration(
                color: (ds?.cardSurface) ?? c.surfaceContainer,
                borderRadius: borderRadius,
                border: selected
                    ? Border.all(
                        color: (ds?.cardBorderSelected) ?? c.onSurface,
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
                      child: trailingLinks == null
                          ? Text(
                              body,
                              style: t.bodyMedium?.copyWith(
                                color: c.onSurface,
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Figtree',
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                style: t.bodyMedium?.copyWith(
                                  color: c.onSurface,
                                  fontSize: 16,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Figtree',
                                ),
                                children: [
                                  TextSpan(text: body),
                                  trailingLinks,
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(width: 20),
                    indicator(selected),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    InlineSpan buildLinks() {
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

      return TextSpan(
        children: [
          const TextSpan(text: ' '),
          TextSpan(
            text: 'Datenschutzerklärung',
            style: t.bodyMedium?.copyWith(
              color: c.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                open(privacyUri);
              },
          ),
          const TextSpan(text: ' sowie den '),
          TextSpan(
            text: 'Nutzungsbedingungen',
            style: t.bodyMedium?.copyWith(
              color: c.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                open(termsUri);
              },
          ),
          const TextSpan(text: ' einverstanden.'),
        ],
      );
    }

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
                      fontFamily: 'Playfair Display',
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
                scopeCard(
                  body:
                      'Ich willige in die Verarbeitung meiner personenbezogenen Daten einschließlich meiner Gesundheitsdaten zur Bereitstellung personalisierter LUVI-Services ein.',
                  scope: ConsentScope.health_processing,
                  cardKey: const Key('consent02_card_required_health'),
                ),
                const SizedBox(height: 20),
                scopeCard(
                  body: 'Ich erkläre mich mit der',
                  scope: ConsentScope.terms,
                  trailingLinks: buildLinks(),
                  cardKey: const Key('consent02_card_required_terms'),
                ),
                const SizedBox(height: 20),
                scopeCard(
                  body:
                      'Ich bin damit einverstanden, dass pseudonymisierte Nutzungs- und Gerätedaten zu Analysezwecken verarbeitet werden, damit LUVI Stabilität und Benutzerfreundlichkeit verbessern kann.',
                  scope: ConsentScope.analytics,
                ),
                const SizedBox(height: 20),
                scopeCard(
                  body:
                      'Ich bin damit einverstanden, dass LUVI meine Kontakt- und Nutzungsdaten – und nur wenn notwendig auch bestimmte Gesundheitsdaten – verarbeitet, um mir personalisierte Empfehlungen zu relevanten LUVI-Inhalten und Informationen zu Angeboten per In-App-Hinweisen, E-Mail und/oder Push-Mitteilungen zu senden.',
                  scope: ConsentScope.marketing,
                ),
                const SizedBox(height: 20),
                scopeCard(
                  body:
                      'Ich willige ein, dass pseudonymisierte Nutzungs- und Gesundheitsdaten zusätzlich zur Verbesserung der LUVI-Modelle/Algorithmen verwendet werden (z. B. zur Qualitätssicherung von Vorhersagen und Empfehlungen).',
                  scope: ConsentScope.model_training,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Deine Zustimmung kannst du jederzeit in der App oder unter hello@getluvi.com widerrufen.',
                      textAlign: TextAlign.center,
                      style: t.bodySmall?.copyWith(
                        color: c.onSurface,
                        fontSize: 14,
                        height: 1.28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.allOptionalSelected
                            ? null
                            : notifier.selectAllOptional,
                        child: const Text('Alle akzeptieren'),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        key: const Key('consent02_btn_next'),
                        onPressed: state.requiredAccepted
                            ? () => context.go('/auth/login')
                            : null,
                        child: const Text('Weiter'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
