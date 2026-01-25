---
name: consent-flow
description: Use when implementing or modifying GDPR consent screens, logging, or privacy flows
---

# Consent Flow Skill

## When to Use
- Implementing new consent screens or modifying existing ones
- Adding new consent scopes or changing consent logic
- Implementing consent logging via Edge Functions
- Debugging consent-related navigation or guards
- Keywords: "consent", "GDPR", "DSGVO", "privacy", "Einwilligung", "opt-in", "opt-out"

## When NOT to Use
- Pure analytics implementation (use analytics docs directly)
- Generic privacy checks (use `qa-reviewer` agent)
- Database RLS policies (Codex E handles migrations)
- Non-consent related user preferences

## LUVI Consent Architecture (ADR-0009)

### Single-Screen Flow
**Route:** `/consent/options` (only consent screen)

**Legacy Redirects:**
- `/consent/intro` → `/consent/options`
- `/consent/blocking` → `/consent/options`
- `/consent/02` → `/consent/options`

**Design Principles:**
- ✅ Privacy-by-Default: Analytics gated until explicit opt-in
- ✅ Append-only log: Consent changes create new records (UPDATE blocked)
- ✅ Owner-based: Each user sees only their own consents
- ✅ Fail-safe: Loading/error states → no analytics

### CTA Logic (Button Behavior)

| Button | State | Color | Behavior |
|--------|-------|-------|----------|
| **"Weiter"** | Required not accepted | Gray (disabled) | Disabled until `health_processing` + `terms` accepted |
| **"Weiter"** | Required accepted | Pink `#E91E63` | Enabled, navigates to `/auth` |
| **"Alle akzeptieren"** | Always | Teal `#1B9BA4` | Always enabled, accepts all visible scopes |

**Required Scopes:** `health_processing`, `terms` (must be accepted to proceed)

## Consent Scopes (SSOT)

**Location:** `config/consent_scopes.json` (canonical), mirrored in Edge Function

```dart
enum ConsentScope {
  terms,               // Required: Terms of Service
  health_processing,   // Required: Health data processing
  ai_journal,          // Optional: AI-powered journal recommendations
  analytics,           // Optional: PostHog tracking
  marketing,           // Optional: Push notifications
  model_training,      // Optional: Anonymous data for ML training
}
```

**Scope Classification:**
- **Required:** User must accept to proceed (disabled navigation otherwise)
- **Optional:** User can decline without blocking app functionality

## Screen Implementation Pattern

### Basic Structure
```dart
// lib/features/consent/screens/consent_options_screen.dart
class ConsentOptionsScreen extends ConsumerStatefulWidget {
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

    return Scaffold(
      backgroundColor: DsColors.splashBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Semantics
            Semantics(
              header: true,
              label: l10n.consentOptionsTitle,
              child: Text(l10n.consentOptionsTitle),
            ),

            // Consent checkboxes
            _ConsentCheckboxRow(
              text: l10n.consentOptionsHealthText,
              selected: state.choices[ConsentScope.health_processing] == true,
              onTap: () => notifier.toggle(ConsentScope.health_processing),
            ),

            // CTAs
            _buildCTAs(state, notifier, l10n, context),
          ],
        ),
      ),
    );
  }
}
```

### State Management Pattern
```dart
// Use Riverpod provider for consent state
final consent02Provider = StateNotifierProvider.autoDispose<
    ConsentNotifier, ConsentState>((ref) => ConsentNotifier());

// Local cache persistence (fail-safe)
await userState.setAcceptedConsentScopes({'health_processing', 'terms', 'analytics'});
```

### Analytics Consent Gating
```dart
// Provider checks consent before each analytics event
final analyticsConsentGateProvider = Provider<bool>((ref) {
  final userStateAsync = ref.watch(userStateServiceProvider);
  return userStateAsync.maybeWhen(
    data: (userState) {
      final scopes = userState.acceptedConsentScopesOrNull;
      return scopes?.contains('analytics') ?? false;
    },
    orElse: () => false, // Fail-safe: no consent = no analytics
  );
});
```

## Edge Function Pattern (Consent Logging)

### Calling from Flutter
```dart
// Always use Edge Function for consent logging (never direct DB write)
try {
  final response = await supabase.functions.invoke(
    'log_consent',
    body: {
      'scopes': ['health_processing', 'terms', 'analytics'], // Current scopes
      'action': 'grant', // or 'revoke'
      'version': 'v1.2', // Consent policy version
    },
  );
  if (response.status != 201) {
    log.e('consent_log_failed', error: sanitizeError(response.data));
  }
} catch (e) {
  log.e('consent_log_error', error: sanitizeError(e));
}
```

### Edge Function Features
- **Auth Check:** Requires valid JWT in `Authorization` header
- **Rate Limiting:** 5 requests per 60 seconds (configurable)
- **Scope Validation:** Rejects invalid scope IDs
- **Pseudonymization:** Uses `CONSENT_METRIC_SALT` for metrics
- **Append-only:** Creates new consent record (never updates existing)

### Configuration (Environment Variables)
```bash
CONSENT_METRIC_SALT=<secret>           # For pseudonymization
CONSENT_RATE_LIMIT_WINDOW_SEC=60      # Rate limit window
CONSENT_RATE_LIMIT_MAX_REQUESTS=5     # Max requests per window
```

## Privacy Rules (CRITICAL)

### 1. No PII in Logs (MUST-07)
```dart
// ❌ BAD
log.d('Consent granted by user: ${user.email}');

// ✅ GOOD
log.i(sanitizeForLog('Consent scopes updated'));
```

**Never log:** email, phone, name, health data, cycle data

### 2. No service_role in Client (MUST-08)
```dart
// ❌ NEVER in lib/ code
supabase.auth.admin
service_role_key

// ✅ ALWAYS use anon key + RLS
final client = Supabase.instance.client;
```

### 3. No Health Data in Push (ADR-0005)
```dart
// ❌ BAD - exposes cycle phase
NotificationPayload(body: 'Tag 22 · Lutealphase')

// ✅ GOOD - generic content
NotificationPayload(body: '💡 5 Lebensmittel für mehr Energie')
```

### 4. Append-only Audit Trail
- **UPDATE blocked:** Trigger `consent_no_update` prevents modifications
- **DELETE reserved:** Only for account erasure (ON DELETE CASCADE)
- **Rationale:** GDPR Art. 7 requires demonstrable proof of consent

## Navigation Guards

### Home Guard (Consent Check)
```dart
// lib/core/navigation/routes.dart
String? homeGuardRedirectWithConsent(BuildContext context, GoRouterState state, WidgetRef ref) {
  final userState = ref.read(userStateServiceProvider);

  return userState.maybeWhen(
    data: (user) {
      if (user.acceptedConsentScopesOrNull == null) {
        return '/consent/options'; // Redirect to consent
      }
      return null; // Allow navigation
    },
    orElse: () => '/splash', // Loading or error
  );
}
```

## Test Requirements

### Consent Options Screen Tests
- [ ] Renders without errors
- [ ] Supports DE/EN localization
- [ ] "Weiter" disabled without required scopes
- [ ] "Weiter" enabled after required scopes accepted
- [ ] "Alle akzeptieren" always enabled
- [ ] Semantics header for accessibility
- [ ] Handles unauthorized consent submission

### Analytics Gating Tests
- [ ] Loading state → no analytics (fail-safe)
- [ ] Error state → no analytics (fail-safe)
- [ ] Null scopes → no analytics (fail-safe)
- [ ] No `analytics` scope → no analytics
- [ ] `analytics` scope present → analytics enabled

### Routing Tests
- [ ] Legacy routes redirect to `/consent/options`
- [ ] Home guard blocks unauthenticated access
- [ ] Post-auth guard bypasses consent check if already granted

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Direct DB write for consent | Use `supabase.functions.invoke('log_consent', ...)` |
| Hardcoded scope list in multiple places | Import from `config/consent_scopes.json` SSOT |
| Logging user email in consent flow | Use `sanitizeForLog()`, never log PII |
| Missing fail-safe for analytics gate | Always return `false` in `orElse` case |
| Allowing navigation without required scopes | Guard checks `health_processing` + `terms` |
| Using `service_role` in client | Only use `anon` key + RLS |
| Health data in push notifications | Generic titles only (ADR-0005) |

## Quick Reference: File Locations

### Screens
- `lib/features/consent/screens/consent_options_screen.dart` - Main consent UI

### State Management
- `lib/features/consent/state/consent02_state.dart` - Consent state provider
- `lib/features/consent/state/consent_service.dart` - Consent service layer
- `services/lib/user_state_service.dart` - Scope persistence (local cache)

### Configuration
- `config/consent_scopes.json` - SSOT for consent scopes
- `lib/core/privacy/consent_config.dart` - Dart configuration
- `lib/core/privacy/consent_types.dart` - ConsentScope enum

### Edge Function
- `supabase/functions/log_consent/index.ts` - Consent logging endpoint
- `supabase/functions/log_consent/consent_scopes.json` - Mirrored scope config

### Navigation
- `lib/router.dart` - Consent guards and legacy redirects
- `lib/core/navigation/routes.dart` - `homeGuardRedirectWithConsent`
- `lib/core/navigation/route_paths.dart` - Route constants

### Analytics
- `lib/core/analytics/analytics_recorder.dart` - Consent gate integration

### Database
- `supabase/migrations/20260121120000_consent_log_append_only.sql` - Append-only enforcement

## Reference Files (SSOT)

**Primary Sources:**
- ADR: [docs/adr/ADR-0009-consent-redesign.md](../../docs/adr/ADR-0009-consent-redesign.md)
- ADR (Canonical): [context/ADR/0009-consent-redesign-2026-01.md](../../context/ADR/0009-consent-redesign-2026-01.md)
- Screen: [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart)
- Edge Function: [supabase/functions/log_consent/index.ts](../../supabase/functions/log_consent/index.ts)

**Related:**
- Privacy Agent: [.claude/agents/qa-reviewer.md](../agents/qa-reviewer.md)
- ADR-0005: [docs/adr/ADR-0005-push-privacy.md](../../docs/adr/ADR-0005-push-privacy.md)
- ADR-0002: Least-Privilege RLS (referenced in append-only enforcement)
- MUST-07: Logging (CLAUDE.md)
- MUST-08: Security (CLAUDE.md)

## External References
- [DSGVO Art. 7 (Einwilligung)](https://dsgvo-gesetz.de/art-7-dsgvo/)
- [Privacy by Default (Art. 25)](https://dsgvo-gesetz.de/art-25-dsgvo/)
