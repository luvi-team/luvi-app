import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/core/widgets/link_text.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_blocking_screen.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:luvi_services/supabase_service.dart';

class _ConsentBtnBusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setBusy(bool value) => state = value;
}

final _consentBtnBusyProvider =
    NotifierProvider.autoDispose<_ConsentBtnBusyNotifier, bool>(
  _ConsentBtnBusyNotifier.new,
);

/// Fix 4: Scroll-Gate for "Alles akzeptieren" button (DSGVO UX)
/// Button is disabled until user scrolls to end of content.
class _ScrolledToEndNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setScrolledToEnd(bool value) => state = value;
}

final _scrolledToEndProvider =
    NotifierProvider.autoDispose<_ScrolledToEndNotifier, bool>(
  _ScrolledToEndNotifier.new,
);

/// C2 - Consent Options Screen
///
/// Main consent screen where users accept required and optional consent scopes.
/// Navigates to C3 (blocking) if required consents are not accepted.
///
/// Route: /consent/options
class ConsentOptionsScreen extends ConsumerStatefulWidget {
  const ConsentOptionsScreen({super.key, required this.appLinks});

  static const String routeName = '/consent/options';
  final AppLinksApi appLinks;

  @override
  ConsumerState<ConsentOptionsScreen> createState() =>
      _ConsentOptionsScreenState();
}

class _ConsentOptionsScreenState extends ConsumerState<ConsentOptionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fix 4 Edge-Case: Check after first frame if content is scrollable
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInitialScroll());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Edge-Case 1: If content fits on screen (maxScrollExtent == 0),
  /// enable button immediately since there's nothing to scroll.
  void _checkInitialScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (_isScrolledToEnd(maxScroll, 0)) {
      ref.read(_scrolledToEndProvider.notifier).setScrolledToEnd(true);
    }
  }

  /// DRY: Checks if user scrolled to end (within 20px) or content not scrollable.
  bool _isScrolledToEnd(double maxScroll, double currentScroll) {
    return maxScroll <= 0 || (maxScroll - currentScroll < 20);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (_isScrolledToEnd(maxScroll, currentScroll)) {
      ref.read(_scrolledToEndProvider.notifier).setScrolledToEnd(true);
    }
  }

  /// Gap 2: Handle layout changes (e.g., screen rotation).
  bool _handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    final maxScroll = notification.metrics.maxScrollExtent;
    final currentScroll = notification.metrics.pixels;
    if (_isScrolledToEnd(maxScroll, currentScroll)) {
      ref.read(_scrolledToEndProvider.notifier).setScrolledToEnd(true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consent02Provider);
    final notifier = ref.read(consent02Provider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final isNextBusy = ref.watch(_consentBtnBusyProvider);
    final hasScrolledToEnd = ref.watch(_scrolledToEndProvider);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: DsColors.bgCream,
      body: SafeArea(
        bottom: false, // Footer handles bottom padding manually to avoid double SafeArea
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              // Gap 2: NotificationListener for screen rotation handling
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: _handleScrollMetricsNotification,
                child: SingleChildScrollView(
                  controller: _scrollController, // Fix 4: Scroll-gate tracking
                  padding: EdgeInsets.symmetric(
                  horizontal: ConsentSpacing.pageHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Spacing.xl),

                    // Shield Icon (Figma: 209 x 117 px)
                    Center(
                      child: Semantics(
                        label: l10n.consentOptionsShieldSemantic,
                        child: Image.asset(
                          Assets.consentIcons.shield1,
                          width: 209,
                          height: 117,
                          fit: BoxFit.contain,
                          errorBuilder: Assets.defaultImageErrorBuilder,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.l),

                    // Title (Figma: Playfair Display SemiBold 28px)
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.consentOptionsTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontFamily: FontFamilies.playfairDisplay,
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          height: 38 / 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),

                    // Subtitle (Figma: Figtree Regular 16px)
                    Text(
                      l10n.consentOptionsSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontFamily: FontFamilies.figtree,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 26 / 16,
                      ),
                    ),
                    const SizedBox(height: ConsentSpacing.sectionGap),

                    // Divider
                    _ConsentDivider(),
                    const SizedBox(height: ConsentSpacing.sectionGap),

                    // REQUIRED Section
                    _SectionHeader(title: l10n.consentOptionsSectionRequired),
                    const SizedBox(height: Spacing.s),

                    // Health Processing Consent
                    _ConsentCheckboxRow(
                      key: const Key('consent_options_health'),
                      text: l10n.consentOptionsHealthText,
                      selected: state.choices[ConsentScope.health_processing] == true,
                      onTap: () => notifier.toggle(ConsentScope.health_processing),
                      semanticSection: l10n.consentOptionsSectionRequired,
                      l10n: l10n,
                    ),
                    const SizedBox(height: ConsentSpacing.sectionGap),

                    // Terms Consent (with links)
                    _ConsentCheckboxRow(
                      key: const Key('consent_options_terms'),
                      text: l10n.consentOptionsTermsPrefix,
                      trailing: _buildTermsLinks(context, l10n),
                      selected: state.choices[ConsentScope.terms] == true,
                      onTap: () => notifier.toggle(ConsentScope.terms),
                      semanticSection: l10n.consentOptionsSectionRequired,
                      l10n: l10n,
                    ),
                    const SizedBox(height: ConsentSpacing.sectionGap),

                    // Divider
                    _ConsentDivider(),
                    const SizedBox(height: ConsentSpacing.sectionGap),

                    // OPTIONAL Section
                    _SectionHeader(title: l10n.consentOptionsSectionOptional),
                    const SizedBox(height: Spacing.s),

                    // Analytics Consent
                    _ConsentCheckboxRow(
                      key: const Key('consent_options_analytics'),
                      text: l10n.consentOptionsAnalyticsText,
                      selected: state.choices[ConsentScope.analytics] == true,
                      onTap: () => notifier.toggle(ConsentScope.analytics),
                      semanticSection: l10n.consentOptionsSectionOptional,
                      l10n: l10n,
                    ),
                    const SizedBox(height: Spacing.xl),
                  ],
                ),
              ),
              ), // Closes NotificationListener (Gap 2)
            ),

            // Footer with buttons - positioned near bottom per Figma
            Container(
              padding: EdgeInsets.fromLTRB(
                ConsentSpacing.pageHorizontal,
                ConsentSpacing.footerPaddingTop, // 8px - minimal top padding
                ConsentSpacing.pageHorizontal,
                // Buttons sit just above safe area (home indicator)
                mediaQuery.padding.bottom + ConsentSpacing.ctaBottomInset,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primary: Weiter (IMMER tappbar - navigiert zu C3 wenn Required ❌)
                  SizedBox(
                    width: double.infinity,
                    height: Sizes.buttonHeight,
                    child: ElevatedButton(
                      key: const Key('consent_options_btn_continue'),
                      onPressed: !isNextBusy
                          ? () async => _handleContinue(context, ref, state, l10n)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DsColors.buttonPrimary,
                        foregroundColor: DsColors.grayscaleWhite,
                        disabledBackgroundColor: DsColors.buttonPrimary.withValues(alpha: 0.5),
                        disabledForegroundColor: DsColors.grayscaleWhite.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.radiusXL),
                        ),
                      ),
                      child: Text(
                        l10n.consentOptionsCtaContinue,
                        style: TextStyle(
                          fontFamily: FontFamilies.figtree,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  // Fix 6: Use correct design token for button gap (64px per Figma)
                  const SizedBox(height: ConsentSpacing.buttonGapC2),

                  // Secondary: Alles akzeptieren
                  // Fix 4: Button disabled until user scrolls to end (DSGVO UX)
                  SizedBox(
                    width: double.infinity,
                    height: Sizes.buttonHeight,
                    child: ElevatedButton(
                      key: const Key('consent_options_btn_accept_all'),
                      onPressed: hasScrolledToEnd
                          ? () async {
                              // DSGVO: Only select VISIBLE optional scopes
                              notifier.selectAllVisibleOptional();
                              // Also select required
                              if (state.choices[ConsentScope.health_processing] !=
                                  true) {
                                notifier.toggle(ConsentScope.health_processing);
                              }
                              if (state.choices[ConsentScope.terms] != true) {
                                notifier.toggle(ConsentScope.terms);
                              }
                              // Navigate to onboarding after accepting all
                              await _handleContinue(context, ref, state, l10n);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        // Fix 4: Dynamic color based on scroll state
                        backgroundColor: hasScrolledToEnd
                            ? DsColors.buttonPrimary // #A8406F (rot) when enabled
                            : DsColors.gray300, // #DCDCDC (grau) when disabled
                        foregroundColor: hasScrolledToEnd
                            ? DsColors.grayscaleWhite
                            : DsColors.gray500,
                        disabledBackgroundColor: DsColors.gray300,
                        disabledForegroundColor: DsColors.gray500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.radiusXL),
                        ),
                      ),
                      child: Text(
                        l10n.consentOptionsCtaAcceptAll,
                        style: TextStyle(
                          fontFamily: FontFamilies.figtree,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsLinks(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return LinkText(
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontFamily: FontFamilies.figtree,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 22.75 / 14,
      ),
      parts: [
        LinkTextPart(
          l10n.consentOptionsTermsLink,
          onTap: () => openTerms(context, appLinks: widget.appLinks),
          bold: true,
          color: DsColors.signature,
        ),
        LinkTextPart(l10n.consentOptionsTermsConjunction),
        LinkTextPart(
          l10n.consentOptionsPrivacyLink,
          onTap: () => openPrivacy(context, appLinks: widget.appLinks),
          bold: true,
          color: DsColors.signature,
        ),
        LinkTextPart(l10n.consentOptionsTermsSuffix),
      ],
    );
  }

  Future<void> _handleContinue(
    BuildContext context,
    WidgetRef ref,
    Consent02State state,
    AppLocalizations l10n,
  ) async {
    // CRITICAL: Read FRESH state from provider, not the stale parameter.
    // This fixes race condition when "Alles akzeptieren" mutates state
    // immediately before calling this function.
    final currentState = ref.read(consent02Provider);

    // Check if required consents are accepted (using fresh state)
    if (!currentState.requiredAccepted) {
      // Navigate to blocking screen (C3)
      if (context.mounted) {
        context.push(ConsentBlockingScreen.routeName);
      }
      return;
    }

    if (!_acquireBusy(ref)) {
      return;
    }
    final scopes = _computeScopes(currentState);
    try {
      await _acceptConsent(ref, scopes);
      final welcomeMarked = await _markWelcomeSeen(ref);

      if (!context.mounted) return;

      // Best-effort: consent is accepted; we warn but do not block navigation.
      if (!welcomeMarked) {
        _showConsentErrorSnackbar(
          context,
          l10n.consentErrorSavingConsent,
        );
      }

      if (!context.mounted) return;
      _navigateAfterConsent(context);
    } on ConsentException catch (error) {
      if (!context.mounted) return;
      if (error.code == 'unauthorized' || error.statusCode == 401) {
        // FTUE: Consent happens before auth; defer server log until after login.
        await _cachePreAuthConsent(ref, scopes: scopes);
        if (!context.mounted) return;
        _navigateAfterConsent(context);
        return;
      }
      final message = error.code == 'rate_limit'
          ? l10n.consentSnackbarRateLimited
          : l10n.consentSnackbarError;
      _showConsentErrorSnackbar(context, message);
    } catch (error, stackTrace) {
      if (!context.mounted) return;
      _reportUnexpectedConsentError(error, stackTrace, context, l10n);
    } finally {
      _releaseBusy(ref);
    }
  }
}

/// Divider line (Figma: #A1A1A1, 1px)
class _ConsentDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: DsColors.divider,
    );
  }
}

/// Section header (Figma: Figtree Bold 14px, 0.7 letter-spacing)
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: FontFamilies.figtree,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.7,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Consent checkbox row (Text + Checkbox on right)
class _ConsentCheckboxRow extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;
  final String semanticSection;
  final AppLocalizations l10n;

  const _ConsentCheckboxRow({
    super.key,
    required this.text,
    this.trailing,
    required this.selected,
    required this.onTap,
    required this.semanticSection,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 22.75 / 14,
      color: theme.colorScheme.onSurface,
    );

    final semanticLabel = selected
        ? l10n.consentOptionsCheckboxSelectedSemantic(semanticSection, text)
        : l10n.consentOptionsCheckboxUnselectedSemantic(semanticSection, text);

    return Semantics(
      label: semanticLabel,
      button: true,
      toggled: selected,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(Sizes.radiusM),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: trailing == null
                    ? Text(text, style: textStyle)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(text, style: textStyle),
                          trailing!,
                        ],
                      ),
              ),
              const SizedBox(width: Spacing.m),
              // Checkbox (Figma: 24x24, Circle)
              _ConsentCircleCheckbox(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circle checkbox (Figma design)
class _ConsentCircleCheckbox extends StatelessWidget {
  final bool selected;

  const _ConsentCircleCheckbox({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ConsentSpacing.checkboxSize,
      height: ConsentSpacing.checkboxSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DsColors.consentCheckboxBackground,
        border: Border.all(
          color: DsColors.consentCheckboxBorder,
          width: ConsentSpacing.checkboxBorderWidth,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: ConsentSpacing.checkboxInnerSize,
                height: ConsentSpacing.checkboxInnerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DsColors.consentCheckboxSelected,
                ),
              ),
            )
          : null,
    );
  }
}

// ─── Helper Functions (unchanged from original) ───

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

bool _acquireBusy(WidgetRef ref) {
  if (ref.read(_consentBtnBusyProvider)) {
    return false;
  }
  ref.read(_consentBtnBusyProvider.notifier).setBusy(true);
  return true;
}

void _releaseBusy(WidgetRef ref) {
  try {
    ref.read(_consentBtnBusyProvider.notifier).setBusy(false);
  } on StateError catch (_) {
    // Provider may be disposed if the widget unmounted mid-flight.
  }
}

List<String> _computeScopes(Consent02State state) => _scopeIdsFor(state);

Future<void> _acceptConsent(WidgetRef ref, List<String> scopes) {
  final consentService = ref.read(consentServiceProvider);
  return consentService.accept(
    version: ConsentConfig.currentVersion,
    scopes: scopes,
  );
}

Future<bool> _markWelcomeSeen(WidgetRef ref) async {
  var ok = true;

  // Server SSOT: write gate state when authenticated + initialized.
  // In tests (or very early init) Supabase may not be ready; don't throw.
  if (SupabaseService.isInitialized && SupabaseService.currentUser != null) {
    try {
      await SupabaseService.upsertConsentGate(
        acceptedConsentVersion: ConsentConfig.currentVersionInt,
        markWelcomeSeen: true,
      );
    } catch (error, stackTrace) {
      ok = false;
      log.w(
        'consent_gate_upsert_failed',
        tag: 'consent_options',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
    }
  }

  // Local cache (best-effort). Only write if we have a valid user ID.
  try {
    final userState = await ref.read(userStateServiceProvider.future);
    final uid = SupabaseService.currentUser?.id;
    if (uid != null) {
      await userState.bindUser(uid);
      await userState.markWelcomeSeen();
      await userState.setAcceptedConsentVersion(ConsentConfig.currentVersionInt);
    } else {
      // Debug: track edge case where uid is null (auth state race or test env).
      log.d('consent_cache_skip_no_uid', tag: 'consent_options');
    }
  } catch (error, stackTrace) {
    ok = false;
    log.e(
      'consent_mark_welcome_failed',
      tag: 'consent_options',
      error: sanitizeError(error) ?? error.runtimeType,
      stack: stackTrace,
    );
  }

  return ok;
}

/// Navigate to Onboarding after consent is accepted.
void _navigateAfterConsent(BuildContext context) {
  final isAuth = SupabaseService.isInitialized && SupabaseService.currentUser != null;
  context.go(isAuth ? Onboarding01Screen.routeName : AuthSignInScreen.routeName);
}

void _reportUnexpectedConsentError(
  Object error,
  StackTrace stackTrace,
  BuildContext context,
  AppLocalizations l10n,
) {
  log.e(
    'consent_next_unexpected',
    error: sanitizeError(error) ?? error.runtimeType,
    stack: stackTrace,
  );
  _showConsentErrorSnackbar(context, l10n.consentSnackbarError);
}

Future<void> _cachePreAuthConsent(
  WidgetRef ref, {
  required List<String> scopes,
}) async {
  try {
    final userState = await ref.read(userStateServiceProvider.future);
    await userState.setPreAuthConsent(
      acceptedConsentVersion: ConsentConfig.currentVersionInt,
      policyVersion: ConsentConfig.currentVersion,
      scopes: scopes,
    );
  } catch (error, stackTrace) {
    log.w(
      'consent_preauth_cache_failed',
      tag: 'consent_options',
      error: sanitizeError(error) ?? error.runtimeType,
      stack: stackTrace,
    );
  }
}
