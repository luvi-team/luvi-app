import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/shared/utils/run_catching.dart';
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/widgets/link_text.dart';
import 'package:luvi_services/user_state_service.dart';

import 'consent_01_screen.dart';

class _ConsentBtnBusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setBusy(bool value) => state = value;
}

final _consentBtnBusyProvider =
    NotifierProvider.autoDispose<_ConsentBtnBusyNotifier, bool>(
      _ConsentBtnBusyNotifier.new,
    );

class Consent02Screen extends ConsumerWidget {
  const Consent02Screen({super.key, this.appLinks = const ProdAppLinks()});

  static const String routeName = '/consent/02';
  final AppLinksApi appLinks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(consent02Provider);
    final notifier = ref.read(consent02Provider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final selectedLabel = l10n.consent02SemanticSelected;
    final unselectedLabel = l10n.consent02SemanticUnselected;
    final isNextBusy = ref.watch(_consentBtnBusyProvider);
    final items = [
      ConsentChoiceListItem(
        key: const Key('consent02_card_required_health'),
        body: l10n.consent02CardHealth,
        scope: ConsentScope.health_processing,
      ),
      ConsentChoiceListItem(
        key: const Key('consent02_card_required_terms'),
        body: l10n.consent02CardTermsPrefix,
        scope: ConsentScope.terms,
        trailing: _buildLinkTrailing(context, l10n),
      ),
      ConsentChoiceListItem(
        key: const Key('consent02_card_required_ai_journal'),
        body: l10n.consent02CardAiJournal,
        scope: ConsentScope.ai_journal,
      ),
      ConsentChoiceListItem(
        body: l10n.consent02CardAnalytics,
        scope: ConsentScope.analytics,
      ),
      ConsentChoiceListItem(
        body: l10n.consent02CardMarketing,
        scope: ConsentScope.marketing,
      ),
      ConsentChoiceListItem(
        body: l10n.consent02CardModelTraining,
        scope: ConsentScope.model_training,
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          _ConsentTopBar(title: l10n.consent02Title),
          // MIDDLE zone: scrollable cards constrained between TOP and BOTTOM
          Expanded(
            child: ConsentChoiceList(
              items: items,
              isSelected: (scope) => state.choices[scope] == true,
              onToggle: notifier.toggle,
              semanticSelectedLabel: selectedLabel,
              semanticUnselectedLabel: unselectedLabel,
            ),
          ),

          // BOTTOM zone: sticky CTA
          Material(
            color: colorScheme.surface,
            elevation: 2,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: ConsentSpacing.footerPadding,
                child: _ConsentFooter(
                  key: const Key('consent02_footer'),
                  l10n: l10n,
                  onSelectAll: notifier.selectAllOptional,
                  onClearAll: notifier.clearAllOptional,
                  allOptionalSelected: state.allOptionalSelected,
                  onNext: () async {
                    if (ref.read(_consentBtnBusyProvider)) {
                      return;
                    }
                    final busyNotifier = ref.read(
                      _consentBtnBusyProvider.notifier,
                    );
                    busyNotifier.setBusy(true);
                    try {
                      final userState = await tryOrNullAsync(
                        () => ref.read(userStateServiceProvider.future),
                        tag: 'userState',
                      );
                      try {
                        await userState?.markWelcomeSeen();
                      } catch (error, stackTrace) {
                        debugPrint(
                          'markWelcomeSeen failed: $error\n$stackTrace',
                        );
                      }
                      if (context.mounted) {
                        context.go(AuthEntryScreen.routeName);
                      }
                    } finally {
                      busyNotifier.setBusy(false);
                    }
                  },
                  nextEnabled: state.requiredAccepted && !isNextBusy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InlineSpan _buildLinkTrailing(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = _consentBodyTextStyle(theme);
    // Use helper functions in app_links.dart to open externally when valid
    // and fall back to the in-app Markdown viewer when not available.

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: LinkText(
        key: const ValueKey('consent02_terms_links'),
        style: baseStyle,
        parts: [
          LinkTextPart(
            l10n.consent02LinkPrivacyLabel,
            onTap: () => openPrivacy(context, appLinks: appLinks),
            bold: true,
            color: colorScheme.primary,
          ),
          LinkTextPart(l10n.consent02LinkConjunction),
          LinkTextPart(
            l10n.consent02LinkTermsLabel,
            onTap: () => openTerms(context, appLinks: appLinks),
            bold: true,
            color: colorScheme.primary,
          ),
          LinkTextPart(l10n.consent02LinkSuffix),
        ],
      ),
    );
  }
}

TextStyle _consentBodyTextStyle(ThemeData theme) {
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;
  return textTheme.bodyMedium?.copyWith(
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
}

class _ConsentTopBar extends StatelessWidget {
  final String title;

  const _ConsentTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: mediaQuery.padding.top + ConsentSpacing.topBarSafeAreaOffset,
        left: ConsentSpacing.pageHorizontal,
        right: ConsentSpacing.pageHorizontal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: BackButtonCircle(
              onPressed: () {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  context.pop();
                } else {
                  context.go(Consent01Screen.routeName);
                }
              },
            ),
          ),
          const SizedBox(height: ConsentSpacing.topBarButtonToTitle),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(
                color: colorScheme.onSurface,
                fontFamily: FontFamilies.playfairDisplay,
                fontSize: 32,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsentChoiceList extends StatelessWidget {
  final List<ConsentChoiceListItem> items;
  final bool Function(ConsentScope scope) isSelected;
  final ValueChanged<ConsentScope> onToggle;
  final String semanticSelectedLabel;
  final String semanticUnselectedLabel;

  const ConsentChoiceList({
    super.key,
    required this.items,
    required this.isSelected,
    required this.onToggle,
    required this.semanticSelectedLabel,
    required this.semanticUnselectedLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: ConsentSpacing.listPadding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ConsentChoiceCard(
          key: item.key,
          body: item.body,
          selected: isSelected(item.scope),
          trailing: item.trailing,
          semanticSelectedLabel: semanticSelectedLabel,
          semanticUnselectedLabel: semanticUnselectedLabel,
          onTap: () => onToggle(item.scope),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: ConsentSpacing.cardGap),
    );
  }
}

class ConsentChoiceListItem {
  final Key? key;
  final ConsentScope scope;
  final String body;
  final InlineSpan? trailing;

  const ConsentChoiceListItem({
    this.key,
    required this.scope,
    required this.body,
    this.trailing,
  });
}

class _ConsentChoiceCard extends StatelessWidget {
  final String body;
  final bool selected;
  final VoidCallback onTap;
  final InlineSpan? trailing;
  final String semanticSelectedLabel;
  final String semanticUnselectedLabel;

  const _ConsentChoiceCard({
    super.key,
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
    final textStyle = _consentBodyTextStyle(theme);

    return Semantics(
      button: true,
      toggled: selected,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
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
              padding: ConsentSpacing.cardPadding,
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
                  const SizedBox(width: ConsentSpacing.cardGap),
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
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;
  final bool allOptionalSelected;
  final VoidCallback? onNext;
  final bool nextEnabled;

  const _ConsentFooter({
    super.key,
    required this.l10n,
    required this.onSelectAll,
    required this.onClearAll,
    required this.allOptionalSelected,
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
        const SizedBox(height: ConsentSpacing.footerHintToPrimaryCta),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('consent02_btn_toggle_optional'),
            onPressed: allOptionalSelected ? onClearAll : onSelectAll,
            child: Text(
              allOptionalSelected
                  ? l10n.consent02DeselectAll
                  : l10n.consent02AcceptAll,
            ),
          ),
        ),
        const SizedBox(height: ConsentSpacing.footerPrimaryToSecondaryCta),
        SizedBox(
          width: double.infinity,
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
