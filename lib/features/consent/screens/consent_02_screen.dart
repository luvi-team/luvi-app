import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_tokens/sizes.dart';

class Consent02Screen extends ConsumerWidget {
  const Consent02Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

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
            border: Border.all(
              color: c.outline,
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
                    color: c.primary,
                  ),
                )
              : null,
        ),
      );
    }

    Widget scopeCard({
      required String title,
      required String body,
      required ConsentScope scope,
      bool outlined = false,
      InlineSpan? trailingLinks,
    }) {
      final selected = state.choices[scope] == true;
      return Semantics(
        label: title,
        button: true,
        toggled: selected,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            notifier.toggle(scope);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: outlined
                  ? Border.all(
                      color: c.outline,
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: t.titleMedium?.copyWith(color: c.onSurface),
                      ),
                      const SizedBox(height: 8),
                      if (trailingLinks == null)
                        Text(
                          body,
                          style:
                              t.bodyMedium?.copyWith(color: c.onSurface),
                        )
                      else
                        RichText(
                          text: TextSpan(
                            style: t.bodyMedium?.copyWith(color: c.onSurface),
                            children: [TextSpan(text: body), trailingLinks],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                indicator(selected),
              ],
            ),
          ),
        ),
      );
    }

    InlineSpan buildLinks() {
      final privacyUri =
          Uri.parse('https://example.com/datenschutzerklaerung'); // TODO: replace with real URL
      final termsUri =
          Uri.parse('https://example.com/nutzungsbedingungen'); // TODO: replace with real URL

      Future<void> open(Uri uri) async {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link konnte nicht geöffnet werden')),
          );
        }
      }
      return TextSpan(children: [
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
        const TextSpan(text: ' • '),
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
      ]);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Back button (positioned top-left)
          Positioned(
            left: 8,
            top: MediaQuery.of(context).padding.top + 8,
            child: BackButtonCircle(onPressed: () => context.pop()),
          ),

          // Scrollable content
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 160),
            children: [
              const SizedBox(height: 32),
              Semantics(
                header: true,
                child: Text(
                  'Deine Einwilligungen',
                  textAlign: TextAlign.center,
                  style: t.headlineMedium?.copyWith(color: c.onSurface),
                ),
              ),
              const SizedBox(height: 24),

              // Cards
              // 1) Gesundheitsdaten (required)
              scopeCard(
                title: 'Gesundheitsdaten',
                body:
                    'Ich willige in die Verarbeitung meiner Gesundheitsdaten ein.',
                scope: ConsentScope.health_processing,
                outlined: false,
              ),
              const SizedBox(height: 20),
              // 2) PP + AGB (required) with outline and links
              scopeCard(
                title: 'Datenschutzerklärung & Nutzungsbedingungen',
                body:
                    'Ich habe die Datenschutzerklärung und die Nutzungsbedingungen gelesen und akzeptiere sie.',
                scope: ConsentScope.terms,
                outlined: true, // card 2 gets outline
                trailingLinks: buildLinks(),
              ),
              const SizedBox(height: 20),
              scopeCard(
                title: 'Analytik',
                body: 'Optionale Nutzungsanalytik zur Verbesserung der App.',
                scope: ConsentScope.analytics,
              ),
              const SizedBox(height: 20),
              scopeCard(
                title: 'Marketing',
                body: 'Optionale personalisierte Tipps und Angebote.',
                scope: ConsentScope.marketing,
              ),
              const SizedBox(height: 20),
              scopeCard(
                title: 'Modelltraining',
                body:
                    'Optional: anonyme Nutzung meiner Daten zum Modelltraining.',
                scope: ConsentScope.model_training,
              ),
            ],
          ),

          // Bottom sticky CTA area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: Sizes.buttonHeight,
                        child: OutlinedButton(
                          onPressed: state.allOptionalSelected
                              ? null
                              : notifier.selectAllOptional,
                          child: const Text('Alle akzeptieren'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: Sizes.buttonHeight,
                        child: ElevatedButton(
                          onPressed: state.requiredAccepted
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Weiter (stub)')),
                                  );
                                }
                              : null,
                          child: const Text('Weiter'),
                        ),
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
