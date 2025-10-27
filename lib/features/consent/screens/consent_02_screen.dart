import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/shared/utils/run_catching.dart';
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes.dart';

class Consent02Screen extends ConsumerWidget {
  const Consent02Screen({super.key});

  static const String routeName = ConsentRoutes.consent02;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final state = ref.watch(consent02Provider);
    final notifier = ref.read(consent02Provider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final selectedLabel = l10n.consent02SemanticSelected;
    final unselectedLabel = l10n.consent02SemanticUnselected;
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
                        context.go(ConsentRoutes.consent01);
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
                    l10n.consent02Title,
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
                  body: l10n.consent02CardHealth,
                  selected: isSelected(ConsentScope.health_processing),
                  semanticSelectedLabel: selectedLabel,
                  semanticUnselectedLabel: unselectedLabel,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.health_processing);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  key: const Key('consent02_card_required_terms'),
                  title: 'terms',
                  body: l10n.consent02CardTermsPrefix,
                  selected: isSelected(ConsentScope.terms),
                  trailing: _buildLinkTrailing(context, l10n),
                  semanticSelectedLabel: selectedLabel,
                  semanticUnselectedLabel: unselectedLabel,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.terms);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  key: const Key('consent02_card_required_ai_journal'),
                  title: 'ai_journal',
                  body: l10n.consent02CardAiJournal,
                  selected: isSelected(ConsentScope.ai_journal),
                  semanticSelectedLabel: selectedLabel,
                  semanticUnselectedLabel: unselectedLabel,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.ai_journal);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  title: 'analytics',
                  body: l10n.consent02CardAnalytics,
                  selected: isSelected(ConsentScope.analytics),
                  semanticSelectedLabel: selectedLabel,
                  semanticUnselectedLabel: unselectedLabel,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.analytics);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  title: 'marketing',
                  body: l10n.consent02CardMarketing,
                  selected: isSelected(ConsentScope.marketing),
                  semanticSelectedLabel: selectedLabel,
                  semanticUnselectedLabel: unselectedLabel,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggle(ConsentScope.marketing);
                  },
                ),
                const SizedBox(height: 20),
                _ConsentChoiceCard(
                  title: 'model_training',
                  body: l10n.consent02CardModelTraining,
                  selected: isSelected(ConsentScope.model_training),
                  semanticSelectedLabel: selectedLabel,
                  semanticUnselectedLabel: unselectedLabel,
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
                  l10n: l10n,
                  onAcceptAll: notifier.selectAllOptional,
                  isAcceptAllDisabled: state.allOptionalSelected,
                  onNext: () async {
                    final userState = await tryOrNullAsync(
                      () => ref.read(userStateServiceProvider.future),
                      tag: 'userState',
                    );
                    await userState?.markWelcomeSeen();
                    if (context.mounted) {
                      context.go(AuthEntryScreen.routeName);
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

  InlineSpan _buildLinkTrailing(
    BuildContext context,
    AppLocalizations l10n,
  ) {
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
    final privacyUri = AppLinks.privacyPolicy;
    final termsUri = AppLinks.termsOfService;

    Future<void> open(Uri uri) async {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.consent02LinkError)),
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
          LinkTextPart(
            l10n.consent02LinkPrivacyLabel,
            onTap: () => open(privacyUri),
            bold: true,
            color: colorScheme.primary,
          ),
          LinkTextPart(l10n.consent02LinkConjunction),
          LinkTextPart(
            l10n.consent02LinkTermsLabel,
            onTap: () => open(termsUri),
            bold: true,
            color: colorScheme.primary,
          ),
          LinkTextPart(l10n.consent02LinkSuffix),
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
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
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
  final String semanticSelectedLabel;
  final String semanticUnselectedLabel;

  const _ConsentChoiceCard({
    super.key,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
    required this.semanticSelectedLabel,
    required this.semanticUnselectedLabel,
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
                    label: selected
                        ? semanticSelectedLabel
                        : semanticUnselectedLabel,
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
  final AppLocalizations l10n;
  final VoidCallback onAcceptAll;
  final bool isAcceptAllDisabled;
  final VoidCallback? onNext;
  final bool nextEnabled;

  const _ConsentFooter({
    super.key,
    required this.l10n,
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
          l10n.consent02RevokeHint,
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
            child: Text(l10n.consent02AcceptAll),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            key: const Key('consent02_btn_next'),
            onPressed: nextEnabled ? onNext : null,
            child: Text(l10n.commonContinue),
          ),
        ),
      ],
    );
  }
}
