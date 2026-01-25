---
name: privacy-audit
description: Use when reviewing code for PII exposure, logging violations, or privacy compliance
---

# Privacy Audit Skill

## When to Use
- Reviewing new features for PII exposure
- Checking logging statements for MUST-07 violations
- Auditing push notification content for health data
- Verifying security compliance (MUST-08)
- Pre-PR privacy review
- Keywords: "privacy", "PII", "log", "logging", "sanitize", "GDPR", "DSGVO", "personal data", "service_role", "push notification"

## When NOT to Use
- Pure implementation tasks (use `ui-frontend` or `dataviz` agents)
- Database RLS policy creation (use `reqing-ball` agent, handled by Codex E)
- Generic code reviews without privacy concerns
- Performance optimization without data handling

## LUVI Privacy Rules

### MUST-07: Privacy Logging

**Rule:** Only use `log` facade with automatic sanitization

**Enforcement:** CI-gate (automated checks)

#### Always Use Logger Facade
```dart
import 'package:luvi_app/core/logging/logger.dart';

// ✅ Correct - uses log facade with automatic sanitization
log.d('User profile loaded', tag: 'profile');
log.i('Navigation to home screen');
log.w('API response delayed', tag: 'api', error: exception);
log.e('Failed to fetch data', tag: 'sync', error: error, stack: stackTrace);
```

#### Never Use Raw Print
```dart
// ❌ Wrong - violates MUST-07
print('Debug message');
debugPrint('User action');
developer.log('Event logged');
```

### MUST-08: Security

**Rule:** No `service_role` key in client code

**Enforcement:** CI-gate (automated checks)

```dart
// ❌ NEVER in lib/ code
supabase.auth.admin                    // Admin API requires service_role
final client = createClient(
  url,
  serviceRoleKey,                      // FORBIDDEN in client
);

// ✅ ALWAYS use anon key + RLS
final client = Supabase.instance.client;  // Uses anon key
final data = await client
  .from('profiles')
  .select()
  .eq('user_id', supabase.auth.currentUser!.id);  // RLS enforces access
```

### PII Categories (NEVER Log)

| PII Type | Examples | Why Forbidden |
|----------|----------|---------------|
| **Email** | `user@example.com` | Direct identifier |
| **Phone** | `+49 123 456789` | Direct identifier |
| **Name** | `Maria Schmidt` | Personal identifier |
| **Health Data** | Cycle day, phase, symptoms | GDPR Art. 9 special category |
| **Location** | GPS coordinates, city | Tracking data |
| **Session Tokens** | JWT, auth tokens | Security risk |
| **Passwords** | Plain or hashed | Security breach |
| **User Input** | Free-form text fields | May contain PII |

### Sanitization API

```dart
import 'package:luvi_app/core/privacy/sanitize.dart';

// Automatic sanitization in log facade
log.i(message);  // Already sanitized

// Manual sanitization (if needed)
final clean = sanitizeForLog(potentiallyUnsafeString);

// Error sanitization
log.e('Operation failed', error: sanitizeError(exception));
```

## Push Notification Privacy (ADR-0005)

### Rule: No Health Data in Push Payloads

**Rationale:**
- Push notifications are visible on lock screens
- Routed through external servers (APNs, FCM) outside EU control
- GDPR Art. 5 (data minimization) and Art. 32 (security)

### Forbidden Content

```dart
// ❌ BAD - exposes cycle information
NotificationPayload(
  title: 'Zyklus-Update',
  body: 'Tag 22 · Lutealphase',  // FORBIDDEN: Health data
);

NotificationPayload(
  title: 'Symptom-Erinnerung',
  body: 'Zeit für dein Symptom-Tracking: Menstruation',  // FORBIDDEN
);

// ❌ BAD - exposes training data
NotificationPayload(
  title: 'Training',
  body: 'Leichte Übungen für die Follikelphase',  // FORBIDDEN: Phase info
);
```

### Allowed Content (Content-First Strategy)

```dart
// ✅ GOOD - generic content teaser
NotificationPayload(
  title: 'Neuer Artikel für dich',
  body: '💡 5 Lebensmittel für mehr Energie',  // Generic wellness content
);

NotificationPayload(
  title: 'Tipp des Tages',
  body: '🌿 Entspannungsübung: 5-Minuten Meditation',  // No personal data
);

NotificationPayload(
  title: 'LUVI Update',
  body: 'Neue Inhalte verfügbar',  // Generic update
);
```

**Personalization:** Only after app is opened (in-app), never in push payload

## Audit Checklists

### 1. Logging Audit (MUST-07)

- [ ] No raw PII in log statements (email, phone, name, health data)
- [ ] Using `log` facade (`log.d`, `log.i`, `log.w`, `log.e`)
- [ ] No `print()`, `debugPrint()`, or `developer.log()` calls
- [ ] `sanitizeForLog()` used for user-related data (if manual sanitization needed)
- [ ] Error sanitization for exceptions (`sanitizeError()`)
- [ ] Structured logging with appropriate tags
- [ ] No logging of session tokens, passwords, or auth credentials

### 2. Security Audit (MUST-08)

- [ ] No `service_role` references in `lib/` code
- [ ] Supabase calls use `Supabase.instance.client` (anon key)
- [ ] No hardcoded API keys or secrets in client code
- [ ] No `supabase.auth.admin` usage in client
- [ ] RLS policies handle authorization (not client-side checks)
- [ ] Environment variables used for sensitive config (not in code)

### 3. Push Notification Privacy (ADR-0005)

- [ ] No cycle phase information in push payloads
- [ ] No symptom data in notifications
- [ ] No training recommendations with phase context
- [ ] No "Day X of cycle" references
- [ ] Generic titles and content only
- [ ] Content-first strategy (wellness tips, not personal data)
- [ ] Personalization deferred to in-app experience

### 4. General Privacy

- [ ] No user input directly logged without sanitization
- [ ] No location data in logs or push notifications
- [ ] No identifiable information in analytics events (if consent granted)
- [ ] Free-form text fields sanitized before logging
- [ ] Error messages don't expose PII in stack traces

## Audit Commands (Grep)

### Find Potential PII Logging
```bash
# Search for potential email/phone/name logging
grep -rn "log\.\|print(" lib/ | grep -iE "email|phone|name|password|token|session"

# Find raw print/debugPrint statements (MUST-07 violation - BOTH are forbidden)
grep -rn -E "print\(|debugPrint\(" lib/ --include="*.dart"

# Find developer.log usage (should use log facade)
grep -rn "developer\.log(" lib/ --include="*.dart"
```

### Find service_role Usage (MUST-08 violation)
```bash
# Search for service_role in client code
grep -rn "service_role\|serviceRole" lib/ --include="*.dart"

# Search for admin API usage
grep -rn "supabase\.auth\.admin\|\.admin\." lib/ --include="*.dart"

# Find hardcoded keys/secrets
grep -rn "apiKey\|secretKey\|API_KEY" lib/ --include="*.dart"
```

### Find Push Privacy Violations
```bash
# Search for phase references in notification code
grep -rn "NotificationPayload\|pushNotification" lib/ -A 5 | grep -iE "phase|zyklus|menstruation|ovulation|luteal|follicular"

# Find symptom references in push code
grep -rn "NotificationPayload" lib/ -A 5 | grep -iE "symptom|tracking|tag [0-9]"
```

## Audit Output Format

When performing a privacy audit, structure findings as:

| File:Line | Issue | Severity | Fix |
|-----------|-------|----------|-----|
| `lib/features/profile/screens/profile_screen.dart:45` | Raw email logged | **Critical** | Use `log.i('Profile loaded', tag: 'profile')` without email |
| `lib/core/api/client.dart:89` | service_role in client | **Critical** | Remove, use anon key + RLS |
| `lib/features/notifications/push_handler.dart:123` | Cycle phase in push | **High** | Use generic content: "Neuer Tipp für dich" |
| `lib/features/auth/login_screen.dart:67` | print() statement | **Medium** | Replace with `log.d(...)` |

**Severity Levels:**
- **Critical:** Direct PII exposure or security breach (email, service_role, health data in push)
- **High:** Privacy violation with indirect PII (cycle context, location, session data)
- **Medium:** MUST rule violation without immediate privacy impact (print() instead of log)
- **Low:** Best practice deviation (missing tags, verbose logging)

## Common Mistakes

| Mistake | Violation | Fix |
|---------|-----------|-----|
| `log.i('User: ${user.email}')` | MUST-07, PII logging | `log.i('User authenticated')` |
| `print('Debug: $data')` | MUST-07, raw print | `log.d('Data loaded', tag: 'feature')` |
| `supabase.auth.admin.listUsers()` | MUST-08, service_role | Move to Edge Function |
| `final key = 'secret_abc123'` | MUST-08, hardcoded secret | Use `Deno.env.get('SECRET')` in Edge Function |
| Push: "Tag 14 · Eisprung" | ADR-0005, health data | "💡 Neue Energie-Tipps" |
| `log.w('Error for ${user.name}')` | MUST-07, PII logging | `log.w('Operation failed', error: sanitizedError)` |
| Logging raw Exception with PII | MUST-07, indirect PII | `log.e('Failed', error: sanitizeError(e))` |

## Integration with Agents

This skill works in conjunction with:

- **`qa-reviewer` agent:** Use this skill's checklist as input for qa-reviewer's comprehensive GDPR audit
- **`ui-frontend` agent:** Cross-check UI implementations for logging patterns
- **Pre-PR workflow:** Run audit commands before submitting PRs with user data handling

## Quick Reference: File Locations

### Logging Infrastructure
- **Logger Facade:** [lib/core/logging/logger.dart](../../lib/core/logging/logger.dart)
- **Sanitization:** [lib/core/privacy/sanitize.dart](../../lib/core/privacy/sanitize.dart)
- **Services Logger:** [services/lib/logger.dart](../../services/lib/logger.dart) (backend)

### Rules & Governance
- **MUST-07:** [CLAUDE.md](../../CLAUDE.md) Line 237 (Privacy logging)
- **MUST-08:** [CLAUDE.md](../../CLAUDE.md) Line 238 (No service_role)
- **ADR-0005:** [context/ADR/0005-push-privacy.md](../../context/ADR/0005-push-privacy.md) (Push privacy)

### Agents
- **Privacy Agent:** [.claude/agents/qa-reviewer.md](../../.claude/agents/qa-reviewer.md)
- **Security Validation:** [.claude/agents/reqing-ball.md](../../.claude/agents/reqing-ball.md)

### CI Enforcement
- **Privacy Gate:** [.github/workflows/privacy-gate.yml](../../.github/workflows/privacy-gate.yml)
- **Analyze & Test:** [.github/workflows/analyze-test.yml](../../.github/workflows/analyze-test.yml)

## Reference Files (SSOT)

**Primary Sources:**
- MUST Rules: [CLAUDE.md](../../CLAUDE.md) (MUST-07, MUST-08)
- Logger Implementation: [lib/core/logging/logger.dart](../../lib/core/logging/logger.dart)
- Push Privacy: [context/ADR/0005-push-privacy.md](../../context/ADR/0005-push-privacy.md)
- Privacy Agent: [.claude/agents/qa-reviewer.md](../../.claude/agents/qa-reviewer.md)

**Related:**
- Sanitization Utils: [lib/core/privacy/sanitize.dart](../../lib/core/privacy/sanitize.dart)
- Services Logger: [services/lib/logger.dart](../../services/lib/logger.dart)
- ADR-0002: Least-Privilege (RLS patterns referenced in MUST-08)
- ADR-0009: Consent Flow (analytics consent gating)

## External References
- [GDPR Art. 5 - Grundsätze](https://dsgvo-gesetz.de/art-5-dsgvo/) (Data minimization)
- [GDPR Art. 9 - Besondere Kategorien](https://dsgvo-gesetz.de/art-9-dsgvo/) (Health data)
- [GDPR Art. 32 - Sicherheit](https://dsgvo-gesetz.de/art-32-dsgvo/) (Security measures)
