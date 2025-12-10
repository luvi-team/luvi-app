# Supabase Auth Settings (LUVI)

Authoritative snapshot of the values we have configured in the Supabase Dashboard → Authentication. This file is intentionally public (no secrets) and acts as the review artifact for callback/redirect drift.

## Project metadata

- **Project name:** `luvi-dev`
- **Project ref:** `cwloioweaqvhibuzdwpi`
- **Supabase URL:** `https://cwloioweaqvhibuzdwpi.supabase.co`

## URL configuration

| Setting | Value | Notes |
| --- | --- | --- |
| **Site URL** | `https://luvi-app.vercel.app` | Primary production frontend & redirect target used in transactional emails. |
| **Additional Redirect URLs** | 1. `https://luvi-app.vercel.app/auth/password/new`<br>2. `https://luvi-app.vercel.app/api/auth/callback`<br>3. `https://cwloioweaqvhibuzdwpi.supabase.co/auth/v1/callback` (Supabase default)<br>4. `luvi://auth-callback` | Keep this list in sync with Flutter deep links (`AppLinks.authCallbackUri`) and any preview URLs. |

`luvi://auth-callback` must always stay on the allow list because both password recovery and OAuth flows rely on it inside the mobile apps.

## Provider configuration summary

### Apple Sign In

| Field | Value | Notes |
| --- | --- | --- |
| **Bundle ID** | `app.luvi.luviApp` | Matches `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj`. |
| **Service ID (Client ID)** | `app.luvi.luviApp` | Public identifier used in the Apple Developer portal & Supabase dashboard. Secrets/keys are stored outside this repo. |
| **Redirect URIs** | `https://cwloioweaqvhibuzdwpi.supabase.co/auth/v1/callback`, `luvi://auth-callback` | Supabase automatically appends state parameters. |

### Google Sign In

| Field | Value | Notes |
| --- | --- | --- |
| **Android package name** | `app.luvi.luvi_app` | Defined in `android/app/build.gradle.kts`. |
| **iOS bundle ID** | `app.luvi.luviApp` | Matches Info.plist/Runner target. |
| **Redirect URIs** | `https://cwloioweaqvhibuzdwpi.supabase.co/auth/v1/callback`, `luvi://auth-callback` | Both platforms rely on the same Supabase-managed callback plus the deep link. |
| **OAuth Client IDs (public)** | Documented in 1Password entry **"LUVI – Google OAuth"** (web + iOS + Android). Add new IDs here when rotated; do **not** copy client secrets. |

## Maintenance checklist

1. After changing anything under Supabase → Authentication → URL Configuration, update the tables above and run `flutter test test/dev/supabase_auth_settings_doc_guard_test.dart`.
2. Whenever Apple/Google client IDs rotate, paste the new public IDs into the table (never commit secrets) and link to the vault location.
3. When introducing new deep links, add them to the Additional Redirect URLs list and update `AppLinks` in Flutter so the doc guard stays green.
