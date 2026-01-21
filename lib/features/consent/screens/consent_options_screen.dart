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
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: DsColors.splashBg,
      body: SafeArea(
        bottom: false, // Footer handles bottom padding manually to avoid double SafeArea
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
                    const SizedBox(height: Spacing.xl),

                    // Shield Icon (Figma: 209 x 117 px)
                    Center(
                      child: Semantics(
                        label: l10n.consentOptionsShieldSemantic,
                        child: Image.asset(
                          Assets.consentImages.consentShield,
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

                    // Analytics Consent (C12: footnote for revoke instructions)
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
                  // "Weiter" Button - disabled until required consents accepted
                  SizedBox(
                    width: double.infinity,
                    height: Sizes.buttonHeight,
                    child: ElevatedButton(
                      key: const Key('consent_options_btn_continue'),
                      onPressed: (state.requiredAccepted && !isBusy)
                          ? () async => _handleContinue(context, ref, l10n)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.requiredAccepted
                            ? DsColors.buttonPrimary
                            : DsColors.gray300,
                        foregroundColor: state.requiredAccepted
                            ? DsColors.grayscaleWhite
                            : DsColors.gray500,
                        disabledBackgroundColor: DsColors.gray300,
                        disabledForegroundColor: DsColors.gray500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.radiusXL),
                        ),
                        elevation: 0,
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
                  const SizedBox(height: ConsentSpacing.buttonGapC2),

                  // "Alle akzeptieren" Button - always active (Teal), except when busy
                  SizedBox(
                    width: double.infinity,
                    height: Sizes.buttonHeight,
                    child: ElevatedButton(
                      key: const Key('consent_options_btn_accept_all'),
                      onPressed: isBusy
                          ? null
                          : () => _handleAcceptAll(context, ref, l10n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DsColors.authRebrandRainbowTeal,
                        foregroundColor: DsColors.grayscaleWhite,
                        disabledBackgroundColor:
                            DsColors.authRebrandRainbowTeal.withValues(alpha: 0.5),
                        disabledForegroundColor:
                            DsColors.grayscaleWhite.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.radiusXL),
                        ),
                        elevation: 0,
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
          onTap: () => openTerms(context, ref),
          bold: true,
          color: DsColors.signature,
        ),
        LinkTextPart(l10n.consentOptionsTermsConjunction),
        LinkTextPart(
          l10n.consentOptionsPrivacyLink,
          onTap: () => openPrivacy(context, ref),
          bold: true,
          color: DsColors.signature,
        ),
        LinkTextPart(l10n.consentOptionsTermsSuffix),
      ],
    );
  }

  /// Handles "Alle akzeptieren" button tap.
  /// Sets all visible consent scopes and navigates immediately.
  void _handleAcceptAll(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    // 1. Set all visible consent scopes (required + optional)
    ref.read(consent02Provider.notifier).acceptAll();

    // 2. Navigate immediately (state is synchronously updated)
    _handleContinue(context, ref, l10n);
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

/// Divider line (Teal: #1B9BA4, 1px)
class _ConsentDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
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
  final String? footnote; // C12: Optional footnote text (e.g. revoke instructions)
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;
  final String semanticSection;
  final AppLocalizations l10n;

  const _ConsentCheckboxRow({
    super.key,
    required this.text,
    this.footnote,
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
          // A11y-Fix: Mindesthöhe ≥44px (WCAG/iOS HIG) statt ~32px mit Spacing.xs
          padding: EdgeInsets.symmetric(vertical: Spacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              // C12: Optional footnote displayed below the checkbox row
              if (footnote != null)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: Text(
                    footnote!,
                    style: TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
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

Future<bool> _markWelcomeSeen(WidgetRef ref, Consent02State currentState) async {
  // Point 12: Explicit success tracking for each operation
  var serverSucceeded = true;
  var localSucceeded = true;

  // 1. Server SSOT: write gate state when authenticated + initialized.
  // In tests (or very early init) Supabase may not be ready; don't throw.
  if (SupabaseService.isInitialized && SupabaseService.currentUser != null) {
    try {
      await SupabaseService.upsertConsentGate(
        acceptedConsentVersion: ConsentConfig.currentVersionInt,
        markWelcomeSeen: true,
      );
    } catch (error, stackTrace) {
      serverSucceeded = false;
      log.w(
        'consent_gate_upsert_failed',
        tag: 'consent_options',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
    }
  }

  // 2. Local cache: best-effort write if user ID available.
  try {
    final userState = await ref.read(userStateServiceProvider.future);
    final uid = SupabaseService.currentUser?.id;
    if (uid != null) {
      // bindUser MUST complete first - sets _boundUserId needed by other methods
      await userState.bindUser(uid);

      // Derive accepted scopes from current state (for analytics consent gating)
      final acceptedScopes = currentState.choices.entries
          .where((e) => e.value)
          .map((e) => e.key.name)
          .toSet();

      // These three are now independent and can run in parallel
      await Future.wait([
        userState.markWelcomeSeen(),
        userState.setAcceptedConsentVersion(ConsentConfig.currentVersionInt),
        userState.setAcceptedConsentScopes(acceptedScopes),
      ]);
    } else {
      // Debug: track edge case where uid is null (auth state race or test env).
      log.d('consent_cache_skip_no_uid', tag: 'consent_options');
    }
  } catch (error, stackTrace) {
    localSucceeded = false;
    log.e(
      'consent_mark_welcome_failed',
      tag: 'consent_options',
      error: sanitizeError(error) ?? error.runtimeType,
      stack: stackTrace,
    );
  }

  // Best-effort semantics: return true if AT LEAST ONE operation succeeded.
  // This allows navigation to continue even if server or local cache fails temporarily.
  // The caller shows a warning snackbar if this returns false, but does NOT block navigation.
  if (serverSucceeded != localSucceeded) {
    log.w(
      'consent_persistence_partial: server=$serverSucceeded local=$localSucceeded',
      tag: 'consent_options',
    );
  }
  return serverSucceeded || localSucceeded;
}

/// Navigate to Onboarding after consent is accepted.
void _navigateAfterConsent(BuildContext context) {
  final isAuth = SupabaseService.isAuthenticated;
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
