# AUTH + CONSENT Audit

## Matrix
| Screen/File | Connected? | Supabase calls | Table/EdgeFn | Tests present? path |
| --- | --- | --- | --- | --- |
| lib/main.dart | Direct | `SupabaseService.tryInitialize` → `Supabase.initialize` | — | — |
| lib/services/supabase_service.dart | Direct | `Supabase.initialize`; `client.auth.currentUser`; `client.auth.signOut`; `client.from('cycle_data').upsert/select`; `client.from('email_preferences').upsert/select` | `cycle_data`, `email_preferences` | test/cycle_api_supabase_test.dart (outside `test/features`, covers `cycle_data` contract) |
| lib/core/navigation/routes.dart | Direct | `SupabaseService.client.auth.currentSession` inside `supabaseRedirect` guard | — | test/features/auth/create_new_route_test.dart; test/features/auth/forgot_route_test.dart; test/features/auth/success_route_test.dart |
| lib/features/auth/screens/auth_entry_screen.dart | None | None (UI only) | — | test/features/auth/auth_entry_screen_test.dart; test/features/auth/auth_entry_contract_test.dart |
| lib/features/auth/screens/auth_signup_screen.dart | Missing | None (`onPressed` empty; expected `supabase.auth.signUp`) | — | test/features/auth/signup_widget_test.dart; test/features/auth/signup_route_test.dart; test/features/auth/signup_nav_widget_test.dart |
| lib/features/auth/screens/create_new_password_screen.dart | Missing | None (`onPressed` empty; expected `supabase.auth.updateUser`) | — | test/features/auth/create_new_render_test.dart; test/features/auth/create_new_scroll_contract_test.dart |
| lib/features/auth/screens/login_screen.dart | Indirect | `loginSubmitProvider` → `AuthRepository.signInWithPassword` → `supabase.auth.signInWithPassword` | — | test/features/auth/login_screen_widget_test.dart; test/features/auth/screens/login_screen_test.dart |
| lib/features/auth/screens/reset_password_screen.dart | Stub | None (uses `ResetSubmitNotifier` delay; `supabase.auth.resetPasswordForEmail` absent) | — | test/features/auth/forgot_flow_widget_test.dart; test/features/auth/forgot_nav_widget_test.dart |
| lib/features/auth/screens/success_screen.dart | None | None (CTA navigates only) | — | test/features/auth/success_render_test.dart; test/features/auth/success_forgot_render_test.dart |
| lib/features/auth/screens/verification_screen.dart | Missing | None (`onConfirm` no-op; `supabase.auth.verifyOtp` absent) | — | test/features/auth/verify_render_test.dart; test/features/auth/verify_route_test.dart; test/features/auth/verify_otp_widget_test.dart |
| lib/features/consent/state/consent_service.dart | Direct | `Supabase.instance.client.functions.invoke('log_consent')` | Edge Function `log_consent` | unknown (no dedicated unit test found) |
| lib/features/consent/widgets/consent_button.dart | Indirect | Calls `ConsentService.accept` on tap | Edge Function `log_consent` | unknown |
| lib/features/consent/screens/* (all) | None | None (UI, navigation, and form state only) | — | test/features/consent/navigation_consent01_to_consent02_test.dart; test/features/consent/navigation_consent02_to_auth_entry_test.dart; test/features/consent/consent02_screen_enable_test.dart |

### Supabase call detection checklist
- `supabase.auth.signInWithPassword`: **present** (`lib/features/data/auth_repository.dart:9`).
- `supabase.auth.signUp`: **not found** (signup CTA empty).
- `supabase.auth.signOut`: **present** (`lib/features/data/auth_repository.dart:12`) but no UI wiring.
- `supabase.auth.verifyOtp`: **not found**; verification flow currently UI-only.
- `supabase.auth.resetPasswordForEmail`: **not found** (reset flow stubbed).
- `supabase.auth.updateUser`: **not found** (new password flow stubbed).
- `functions.invoke('log_consent')`: **present** (`lib/features/consent/state/consent_service.dart:8`).
- `.from('consents')`: **not found**.
- `.from('profiles')`: **not found**.
- `.from('cycle_data')`: **present** (`lib/services/supabase_service.dart:43`, `lib/features/cycle/data/cycle_api_supabase.dart:24`).

### Test coverage notes (`test/features/*`)
| Test File | Supabase interaction | Notes |
| --- | --- | --- |
| test/features/auth/auth_repository_test.dart | Mocks `SupabaseClient.auth.signInWithPassword` | Verifies credentials forwarded to Supabase auth API. |
| test/features/auth/login_screen_widget_test.dart | Mocks `AuthRepository.signInWithPassword` throwing `AuthException` | Exercises error handling for Supabase auth failures. |
| test/features/auth/screens/login_screen_test.dart | Uses mocked repository | Confirms login UI reacts to auth state but no real Supabase call. |
| test/features/auth/forgot_flow_widget_test.dart | No Supabase | Highlights absence of `resetPasswordForEmail` logic. |
| test/features/auth/*verify*_tests | No Supabase | OTP confirm/resend handlers unimplemented. |
| test/features/consent/* | No Supabase | Navigation/state only; no coverage for `ConsentService.accept`. |

## DB schema snapshot (`consents`, `profiles`)
| Table | Columns |
| --- | --- |
| consents | unknown — `supabase db query` subcommand unavailable in CLI 2.40.7 (see command log). |
| profiles | unknown — same limitation. |

## RLS policy snapshot (`consents`, `profiles`)
| Table | Policy details |
| --- | --- |
| consents | unknown — `supabase db query` not supported; no alternative read-only access configured. |
| profiles | unknown — same limitation. |

## Supabase CLI command log
```text
$ supabase --version
2.40.7

$ test -f supabase/config.toml && cat supabase/config.toml || true
(no output)

$ supabase db query "select to_regclass('public.profiles') as profiles;" || true
Manage Postgres databases
Usage: supabase db [command]
... (CLI 2.40.7 lacks `db query` subcommand)

$ supabase db query "select column_name,data_type from information_schema.columns where table_name='consents' order by ordinal_position;" || true
Manage Postgres databases
Usage: supabase db [command]

$ supabase db query "select schemaname,tablename,policyname,cmd,roles,qual,with_check from pg_policies where tablename in ('consents','profiles') order by tablename,policyname;" || true
Manage Postgres databases
Usage: supabase db [command]

$ supabase functions list || true
Access token not provided. Supply an access token by running supabase login or setting the SUPABASE_ACCESS_TOKEN environment variable.
```

## Tests & CI snapshot
- `flutter analyze` → No issues found (dependencies resolved with multiple outdated packages noted).
- `flutter test --reporter=expanded` → 90 tests executed; all passed.

## Quick Wins

> **Note:** The following suggestions are minimal implementations to establish backend connectivity. Production code should include comprehensive error handling, loading states, input validation, and proper user feedback mechanisms.

1. **lib/features/auth/screens/auth_signup_screen.dart:178** — Replace the empty signup handler with a Supabase sign-up call so the CTA actually registers users.
