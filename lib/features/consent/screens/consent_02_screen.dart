import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

class Consent02Screen extends ConsumerWidget {
  const Consent02Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    final state = ref.watch(consent02NotifierProvider);
    final notifier = ref.read(consent02NotifierProvider.notifier);

    Widget indicator(bool selected) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.outline),
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
      return InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          notifier.toggle(scope);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: outlined ? Border.all(color: c.outline) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.titleMedium),
                    const SizedBox(height: 8),
                    if (trailingLinks == null)
                      Text(body, style: t.bodyMedium)
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
      );
    }

    InlineSpan buildLinks() {
      return TextSpan(children: [
        const TextSpan(text: ' '),
        TextSpan(
          text: 'Datenschutzerklärung',
          style: t.bodyMedium?.copyWith(color: c.primary),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // TODO: open Datenschutzerklärung
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datenschutzerklärung (stub)')),
              );
            },
        ),
        const TextSpan(text: ' • '),
        TextSpan(
          text: 'Nutzungsbedingungen',
          style: t.bodyMedium?.copyWith(color: c.primary),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // TODO: open Nutzungsbedingungen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nutzungsbedingungen (stub)')),
              );
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
              Text(
                'Deine Einwilligungen',
                textAlign: TextAlign.center,
                style: t.headlineMedium,
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
                      child: OutlinedButton(
                        onPressed: state.allOptionalSelected
                            ? null
                            : notifier.selectAllOptional,
                        child: const Text('Alle akzeptieren'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
