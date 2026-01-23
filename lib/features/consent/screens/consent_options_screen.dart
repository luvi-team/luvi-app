import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/legal_actions.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/core/widgets/link_text.dart';
import 'package:luvi_app/core/privacy/consent_config.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_app/core/init/session_dependencies.dart';

class _ConsentBtnBusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setBusy(bool value) => state = value;
}

final _consentBtnBusyProvider =
    NotifierProvider.autoDispose<_ConsentBtnBusyNotifier, bool>(
      _ConsentBtnBusyNotifier.new,
    );

/// C2 - Consent Options Screen (Single-Screen Consent Flow)
///
/// Main consent screen where users accept required and optional consent scopes.
/// "Weiter" button is disabled until required consents are accepted.
/// "Alle akzeptieren" button is always active and sets all visible scopes.
///
/// Route: /consent/options
class ConsentOptionsScreen extends ConsumerStatefulWidget {
  const ConsentOptionsScreen({super.key});

  static const String routeName = RoutePaths.consentOptions;

  @override
  ConsumerState<ConsentOptionsScreen> createState() =>
      _ConsentOptionsScreenState();
}

class _ConsentOptionsScreenState extends ConsumerState<ConsentOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consent02Provider);
    final notifier = ref.read(consent02Provider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final isBusy = ref.watch(_consentBtnBusyProvider);

    return Scaffold(
      backgroundColor: DsColors.splashBg,
      body: SafeArea(
        bottom: false, // Footer handles bottom padding manually
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ConsentSpacing.pageHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ConsentHeader(l10n: l10n),

                    // REQUIRED Section
                    _SectionHeader(title: l10n.consentOptionsSectionRequired),
                    const SizedBox(height: Spacing.s),
                    _ConsentCheckboxRow(
                      key: const Key('consent_options_health'),
                      text: l10n.consentOptionsHealthText,
                      selected:
                          state.choices[ConsentScope.health_processing] == true,
                      onTap: () =>
                          notifier.toggle(ConsentScope.health_processing),
                      semanticSection: l10n.consentOptionsSectionRequired,
                      l10n: l10n,
                    ),
                    const SizedBox(height: ConsentSpacing.checkboxItemGap),
                    _ConsentCheckboxRow(
                      key: const Key('consent_options_terms'),
                      text: '',
                      semanticsText:
                          '${l10n.consentOptionsTermsPrefix}'
                          '${l10n.consentOptionsTermsLink}'
                          '${l10n.consentOptionsTermsConjunction}'
                          '${l10n.consentOptionsPrivacyLink}'
                          '${l10n.consentOptionsTermsSuffix}',
                      trailing: _buildTermsLinks(context, l10n),
                      selected: state.choices[ConsentScope.terms] == true,
                      onTap: () => notifier.toggle(ConsentScope.terms),
                      semanticSection: l10n.consentOptionsSectionRequired,
                      l10n: l10n,
                    ),
                    const SizedBox(height: ConsentSpacing.itemToDividerGap),

                    _ConsentDivider(),
                    const SizedBox(height: ConsentSpacing.sectionGap),

                    // OPTIONAL Section
                    _SectionHeader(title: l10n.consentOptionsSectionOptional),
                    const SizedBox(height: Spacing.s),
                    _ConsentCheckboxRow(
                      key: const Key('consent_options_analytics'),
                      text: l10n.consentOptionsAnalyticsText,
                      footnote: l10n.consentOptionsAnalyticsRevoke,
                      selected: state.choices[ConsentScope.analytics] == true,
                      onTap: () => notifier.toggle(ConsentScope.analytics),
                      semanticSection: l10n.consentOptionsSectionOptional,
                      l10n: l10n,
                    ),
                    const SizedBox(height: Spacing.xl),
                  ],
                ),
              ),
            ),

            // Footer with CTA buttons
            _ConsentFooter(
              requiredAccepted: state.requiredAccepted,
              isBusy: isBusy,
              onContinue: () async => _handleContinue(context, ref, l10n),
              onAcceptAll: () async => _handleAcceptAll(context, ref, l10n),
              l10n: l10n,
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
        fontSize: ConsentTypography.bodyFontSize,
        height: ConsentTypography.bodyLineHeight,
      ),
      // Use overflow hit rect instead of inline padding to avoid extra spacing
      allowHorizontalOverflowHitRect: true,
      parts: [
        // Prefix text for inline flow (was previously separate Text widget)
        LinkTextPart(l10n.consentOptionsTermsPrefix),
        LinkTextPart(
          l10n.consentOptionsTermsLink,
          onTap: () => openTerms(context, ref),
          bold: false,
          color: DsColors.buttonPrimary,
        ),
        LinkTextPart(l10n.consentOptionsTermsConjunction),
        LinkTextPart(
          l10n.consentOptionsPrivacyLink,
          onTap: () => openPrivacy(context, ref),
          bold: false,
          color: DsColors.buttonPrimary,
        ),
        LinkTextPart(l10n.consentOptionsTermsSuffix),
      ],
    );
  }

  /// Handles "Alle akzeptieren" button tap.
  /// Sets all visible consent scopes and navigates immediately.
  Future<void> _handleAcceptAll(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    // 1. Set all visible consent scopes (required + optional)
    try {
      ref.read(consent02Provider.notifier).acceptAll();
    } catch (error, stackTrace) {
      log.e(
        'consent_accept_all_failed',
        tag: 'consent_options',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      _showConsentErrorSnackbar(context, l10n.consentSnackbarError);
      return;
    }

    // 2. Navigate (await ensures proper error handling propagation)
    await _handleContinue(context, ref, l10n);
  }

  /// Handles "Weiter" button tap.
  /// Button is already disabled when required consents are not accepted.
  Future<void> _handleContinue(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    // Read fresh state from provider to avoid stale closure captures.
    final currentState = ref.read(consent02Provider);

    if (!_acquireBusy(ref)) {
      return;
    }
    final scopes = _computeScopes(currentState);
    try {
      await _acceptConsent(ref, scopes);
      final welcomeMarked = await _markWelcomeSeen(ref, currentState);

      if (!context.mounted) return;

      // Best-effort: consent is accepted; we warn but do not block navigation.
      if (!welcomeMarked) {
        _showConsentErrorSnackbar(context, l10n.consentErrorSavingConsent);
      }

      if (!context.mounted) return;
      _navigateAfterConsent(context, ref);
    } on ConsentException catch (error) {
      if (!context.mounted) return;
      if (error.code == 'unauthorized' || error.statusCode == 401) {
        // Session abgelaufen → User zu Auth redirecten
        context.go(RoutePaths.authSignIn);
        return;
      }
      final message = switch (error.code) {
        'rate_limit' => l10n.consentSnackbarRateLimited,
        'function_unavailable' => l10n.consentSnackbarServiceUnavailable,
        'server_error' => l10n.consentSnackbarServerError,
        _ => l10n.consentSnackbarError,
      };
      _showConsentErrorSnackbar(context, message);
    } catch (error, stackTrace) {
      if (!context.mounted) return;
      _reportUnexpectedConsentError(error, stackTrace, context, l10n);
    } finally {
      _releaseBusy(ref);
    }
  }
}

/// Divider line (Teal: #1B9BA4, 2px)
class _ConsentDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ConsentSpacing.dividerHeight,
      color: DsColors.authRebrandRainbowTeal,
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
        fontVariations: const [FontVariations.bold],
        fontSize: ConsentTypography.bodyFontSize,
        height: ConsentTypography.sectionHeaderLineHeight,
        letterSpacing: 0.7,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Consent checkbox row (Text + Checkbox on right)
class _ConsentCheckboxRow extends StatelessWidget {
  final String text;
  final String? semanticsText;
  // C12: Optional footnote text (e.g. revoke instructions)
  final String? footnote;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;
  final String semanticSection;
  final AppLocalizations l10n;

  const _ConsentCheckboxRow({
    super.key,
    required this.text,
    this.semanticsText,
    this.footnote,
    this.trailing,
    required this.selected,
    required this.onTap,
    required this.semanticSection,
    required this.l10n,
  });

  /// Builds the row content based on text and trailing widget presence.
  /// Handles three cases: text-only, trailing-only, and text+trailing.
  Widget _buildRowContent(TextStyle textStyle) {
    if (trailing == null) {
      return ExcludeSemantics(child: Text(text, style: textStyle));
    }
    if (text.isEmpty) {
      return trailing!; // Links remain focusable for VoiceOver
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Text(text, style: textStyle)),
        trailing!, // Links remain focusable for VoiceOver
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: ConsentTypography.bodyFontSize,
      height: ConsentTypography.bodyLineHeight,
      color: theme.colorScheme.onSurface,
    );

    final resolvedSemanticText = semanticsText ?? text;
    final semanticLabel = selected
        ? l10n.consentOptionsCheckboxSelectedSemantic(
            semanticSection,
            resolvedSemanticText,
          )
        : l10n.consentOptionsCheckboxUnselectedSemantic(
            semanticSection,
            resolvedSemanticText,
          );

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Sizes.touchTargetMin),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRowContent(textStyle)),
                    const SizedBox(width: Spacing.m),
                    // Checkbox (Figma: 24x24, Circle)
                    _ConsentCircleCheckbox(selected: selected),
                  ],
                ),
                // C12: Optional footnote displayed below the checkbox row
                if (footnote != null)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.xs),
                    child: Text(
                      footnote!,
                      style: TextStyle(
                        fontFamily: FontFamilies.figtree,
                        fontSize: ConsentTypography.footnoteFontSize,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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

/// Header section: Shield Icon + Title + Subtitle
class _ConsentHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const _ConsentHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: Spacing.xl),
        // Shield Icon (Figma: 209 x 117 px)
        Center(
          child: Semantics(
            label: l10n.consentOptionsShieldSemantic,
            child: Image.asset(
              Assets.consentImages.consentShield,
              width: ConsentSpacing.shieldIconWidth,
              height: ConsentSpacing.shieldIconHeight,
              fit: BoxFit.contain,
              errorBuilder: Assets.defaultImageErrorBuilder,
            ),
          ),
        ),
        const SizedBox(height: Spacing.l),
        // Title (Figma: Playfair Display Bold 28px, line-height 34px)
        Semantics(
          header: true,
          child: Text(
            l10n.consentOptionsTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontFamily: FontFamilies.playfairDisplay,
              fontWeight: FontWeight.w700,
              fontSize: ConsentTypography.headerFontSize,
              height: ConsentTypography.headerLineHeight,
            ),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        // Subtitle (Figma: Playfair Display SemiBold 17px, line-height 24px)
        Text(
          l10n.consentOptionsSubtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: DsColors.consentSubheaderText,
            fontFamily: FontFamilies.playfairDisplay,
            fontWeight: FontWeight.w600,
            fontSize: ConsentTypography.subheaderFontSize,
            height: ConsentTypography.subheaderLineHeight,
          ),
        ),
        const SizedBox(height: ConsentSpacing.sectionGap),
        // Divider
        _ConsentDivider(),
        const SizedBox(height: ConsentSpacing.sectionGap),
      ],
    );
  }
}

/// Footer with CTA buttons
class _ConsentFooter extends StatelessWidget {
  final bool requiredAccepted;
  final bool isBusy;
  final VoidCallback onContinue;
  final VoidCallback onAcceptAll;
  final AppLocalizations l10n;

  const _ConsentFooter({
    required this.requiredAccepted,
    required this.isBusy,
    required this.onContinue,
    required this.onAcceptAll,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        ConsentSpacing.pageHorizontal,
        ConsentSpacing.footerPaddingTop,
        ConsentSpacing.pageHorizontal,
        mediaQuery.padding.bottom + ConsentSpacing.ctaBottomInset,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ConsentSpacing.ctaButtonMaxWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ContinueButton(
                enabled: requiredAccepted && !isBusy,
                onPressed: onContinue,
                label: l10n.consentOptionsCtaContinue,
              ),
              const SizedBox(
                key: Key('consent_options_button_gap'),
                height: ConsentSpacing.buttonGapC2,
              ),
              _AcceptAllButton(
                enabled: !isBusy,
                onPressed: onAcceptAll,
                label: l10n.consentOptionsCtaAcceptAll,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Weiter" Button - disabled until required consents accepted
class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  final String label;

  const _ContinueButton({
    required this.enabled,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        key: const Key('consent_options_btn_continue'),
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: DsColors.buttonPrimary,
          foregroundColor: DsColors.grayscaleWhite,
          disabledBackgroundColor: DsColors.gray300,
          disabledForegroundColor: DsColors.gray500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radiusM),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontVariations: const [FontVariations.bold],
            fontSize: ConsentTypography.buttonFontSize,
            height: ConsentTypography.buttonLineHeight,
          ),
        ),
      ),
    );
  }
}

/// "Alle akzeptieren" Button - always active (Teal), except when busy
class _AcceptAllButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  final String label;

  const _AcceptAllButton({
    required this.enabled,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        key: const Key('consent_options_btn_accept_all'),
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: DsColors.authRebrandRainbowTeal,
          foregroundColor: DsColors.grayscaleWhite,
          disabledBackgroundColor:
              DsColors.authRebrandRainbowTeal.withValues(alpha: 0.5),
          disabledForegroundColor:
              DsColors.grayscaleWhite.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radiusM),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontVariations: const [FontVariations.bold],
            fontSize: ConsentTypography.buttonFontSize,
            height: ConsentTypography.buttonLineHeight,
          ),
        ),
      ),
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
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

/// Orchestrates consent persistence to server and local cache.
/// Returns true if at least one operation succeeded (best-effort semantics).
Future<bool> _markWelcomeSeen(
  WidgetRef ref,
  Consent02State currentState,
) async {
  final serverSucceeded = await _persistConsentGateToServer();
  final localSucceeded = await _persistConsentToLocalCache(ref, currentState);

  // Log partial success for debugging
  if (serverSucceeded != localSucceeded) {
    log.w(
      'consent_persistence_partial: server=$serverSucceeded local=$localSucceeded',
      tag: 'consent_options',
    );
  }

  // Best-effort: navigation continues if at least one operation succeeded
  return serverSucceeded || localSucceeded;
}

/// Persists consent gate state to server (SSOT).
/// Returns true on success, false on skip or failure.
Future<bool> _persistConsentGateToServer() async {
  // Skip if Supabase not initialized
  if (!SupabaseService.isInitialized) {
    log.d(
      'consent_gate_skipped: supabase_not_initialized',
      tag: 'consent_options',
    );
    return false; // Skipped, not success
  }

  // Skip if no current user (test env, early init)
  if (SupabaseService.currentUser == null) {
    log.d(
      'consent_gate_skipped: no_current_user',
      tag: 'consent_options',
    );
    return false; // Skipped, not success
  }

  try {
    await SupabaseService.upsertConsentGate(
      acceptedConsentVersion: ConsentConfig.currentVersionInt,
      markWelcomeSeen: true,
    );
    return true;
  } catch (error, stackTrace) {
    log.w(
      'consent_gate_upsert_failed',
      tag: 'consent_options',
      error: sanitizeError(error) ?? error.runtimeType,
      stack: stackTrace,
    );
    return false;
  }
}

/// Persists consent state to local cache for offline access and analytics gating.
/// Returns true on success, false on failure or skip.
///
/// Returns false if provider resolution fails (graceful degradation).
Future<bool> _persistConsentToLocalCache(
  WidgetRef ref,
  Consent02State currentState,
) async {
  // Issue 3: Wrap provider resolution in try-catch for graceful failure.
  // Explicit type annotation required (Dart cannot infer from try-block assignment).
  final UserStateService userState;
  try {
    userState = await ref.read(userStateServiceProvider.future);
  } catch (error, stackTrace) {
    log.e(
      'consent_user_state_provider_failed',
      tag: 'consent_options',
      error: sanitizeError(error) ?? error.runtimeType,
      stack: stackTrace,
    );
    return false;
  }

  final uid = SupabaseService.currentUser?.id;

  if (uid == null) {
    // Skipped - returning false for consistency with server-side skips
    log.d('consent_cache_skip_no_uid: returning false', tag: 'consent_options');
    return false;
  }

  // Separate try/catch for bindUser to distinguish binding failures
  try {
    await userState.bindUser(uid);
  } catch (error, stackTrace) {
    log.e(
      'consent_bind_user_failed',
      tag: 'consent_options',
      error: sanitizeError(error) ?? error.runtimeType,
      stack: stackTrace,
    );
    return false;
  }

  // Derive accepted scopes from current state (for analytics consent gating)
  final acceptedScopes = currentState.choices.entries
      .where((e) => e.value)
      .map((e) => e.key.name)
      .toSet();

  // Parallel writes for efficiency.
  // Issue 5: Use .wait extension to capture all errors via ParallelWaitError
  try {
    await [
      userState.markWelcomeSeen(),
      userState.setAcceptedConsentVersion(ConsentConfig.currentVersionInt),
      userState.setAcceptedConsentScopes(acceptedScopes),
    ].wait;
    return true;
  } on ParallelWaitError catch (e, stackTrace) {
    // Log all errors occurred during parallel execution
    for (final error in e.errors) {
      if (error != null) {
        // Issue 7: Unwrap AsyncError to extract underlying error and stack trace
        final actualError = error is AsyncError ? error.error : error;
        final actualStack = error is AsyncError ? error.stackTrace : stackTrace;

        log.e(
          'consent_persistence_parallel_error',
          tag: 'consent_options',
          error: sanitizeError(actualError) ?? actualError.runtimeType,
          stack: actualStack,
        );
      }
    }
    return false;
  } catch (error, stackTrace) {
    log.e(
      'consent_mark_welcome_failed',
      tag: 'consent_options',
      error: sanitizeError(error) ?? error.runtimeType,
      stack: stackTrace,
    );
    return false;
  }
}

/// Navigate to Onboarding after consent is accepted.
/// Uses isAuthenticatedFnProvider for testability (not static SupabaseService).
void _navigateAfterConsent(BuildContext context, WidgetRef ref) {
  final isAuth = ref.read(isAuthenticatedFnProvider)();
  context.go(isAuth ? RoutePaths.onboarding01 : RoutePaths.authSignIn);
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
