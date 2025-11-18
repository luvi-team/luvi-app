import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
import 'package:luvi_app/features/shared/utils/run_catching.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/widgets/link_text.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
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
  /// Requires explicit [appLinks] to make the dependency visible and testable.
  const Consent02Screen({super.key, required this.appLinks});

  static const String routeName = '/consent/02';
  final AppLinksApi appLinks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consent02Provider);
    final notifier = ref.read(consent02Provider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final isNextBusy = ref.watch(_consentBtnBusyProvider);
    final items = _buildConsentItems(context, l10n);
    final footer = _ConsentFooter(
      key: const Key('consent02_footer'),
      l10n: l10n,
      onSelectAll: notifier.selectAllOptional,
      onClearAll: notifier.clearAllOptional,
      allOptionalSelected: state.allOptionalSelected,
      onNext: () async => _handleNext(context, ref, state, l10n),
      nextEnabled: state.requiredAccepted && !isNextBusy,
    );

    return _Consent02Layout(
      title: l10n.consent02Title,
      items: items,
      selectedLabel: l10n.consent02SemanticSelected,
      unselectedLabel: l10n.consent02SemanticUnselected,
      isSelected: (scope) => state.choices[scope] == true,
      onToggle: notifier.toggle,
      footer: footer,
    );
  }

  List<ConsentChoiceListItem> _buildConsentItems(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
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
      ConsentChoiceListItem(
        key: const Key('consent02_card_optional_ai_journal'),
        body: l10n.consent02CardAiJournal,
        scope: ConsentScope.ai_journal,
      ),
    ];
  }

  Future<void> _handleNext(
    BuildContext context,
    WidgetRef ref,
    Consent02State state,
    AppLocalizations l10n,
  ) async {
    final busyNotifier = ref.read(_consentBtnBusyProvider.notifier);
    if (ref.read(_consentBtnBusyProvider)) {
      return;
    }
    busyNotifier.setBusy(true);
    try {
      final consentService = ref.read(consentServiceProvider);
      final scopes = _scopeIdsFor(state);
      await consentService.accept(
        version: ConsentConfig.currentVersion,
        scopes: scopes,
      );

      Object? markError;
      final userState = await tryOrNullAsync(
        () => ref.read(userStateServiceProvider.future),
        tag: 'userState',
      );

      if (userState != null) {
        await tryOrNullAsync(
          () async {
            await userState.markWelcomeSeen();
          },
          tag: 'markWelcomeSeen',
          onError: (error, stack) {
            markError = error;
          },
        );
      }

      if (!context.mounted) return;

      if (markError != null) {
        _showConsentErrorSnackbar(
          context,
          l10n.consentSnackbarError,
        );
        return;
      }

      context.go(AuthEntryScreen.routeName);
    } on ConsentException catch (error) {
      if (!context.mounted) return;
      final message = error.code == 'rate_limit'
          ? l10n.consentSnackbarRateLimited
          : l10n.consentSnackbarError;
      _showConsentErrorSnackbar(context, message);
    } catch (_) {
      if (!context.mounted) return;
      _showConsentErrorSnackbar(
        context,
        l10n.consentSnackbarError,
      );
    } finally {
      busyNotifier.setBusy(false);
    }
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
  final base = textTheme.bodyMedium ?? const TextStyle();
  return base.copyWith(
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
              semanticLabel: AppLocalizations.of(context)!.authBackSemantic,
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

class _Consent02Layout extends StatelessWidget {
  final String title;
  final List<ConsentChoiceListItem> items;
  final bool Function(ConsentScope scope) isSelected;
  final ValueChanged<ConsentScope> onToggle;
  final String selectedLabel;
  final String unselectedLabel;
  final Widget footer;

  const _Consent02Layout({
    required this.title,
    required this.items,
    required this.isSelected,
    required this.onToggle,
    required this.selectedLabel,
    required this.unselectedLabel,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          _ConsentTopBar(title: title),
          Expanded(
            child: ConsentChoiceList(
              items: items,
              isSelected: isSelected,
              onToggle: onToggle,
              semanticSelectedLabel: selectedLabel,
              semanticUnselectedLabel: unselectedLabel,
            ),
          ),
          Material(
            color: colorScheme.surface,
            elevation: 2,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: ConsentSpacing.footerPadding,
                child: footer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsentChoiceListItem {
  final Key? key;
  final String body;
  final ConsentScope scope;
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
                    child: SizedBox(
                      width: Sizes.touchTargetMin,
                      height: Sizes.touchTargetMin,
                      child: Align(
                        alignment: Alignment.topCenter,
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
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.consent02RevokeHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
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
          height: Sizes.buttonHeight,
          child: ElevatedButton(
            key: const Key('consent02_btn_next'),
            onPressed: nextEnabled ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(l10n.commonContinue),
          ),
        ),
      ],
    );
  }
}

List<String> _scopeIdsFor(Consent02State state) {
  final choices = state.choices;
  return [
    for (final scope in ConsentScope.values)
      if (kRequiredConsentScopes.contains(scope) || choices[scope] == true)
        scope.name,
  ];
}

void _showConsentErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
