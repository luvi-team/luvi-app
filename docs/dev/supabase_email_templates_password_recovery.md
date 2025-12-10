# Password Recovery Email Template

This mirrors the configuration under Supabase Dashboard → Authentication → Email Templates → **Password Recovery**. Only public copy lives here—no API keys or SMTP creds.

- **Subject:** `LUVI – Setze dein Passwort zurück`
- **Body:**

```
Hi {{ .User.email }},

du (oder jemand anderes) hast angefragt, das Passwort deines LUVI Accounts zu ändern.
Tippe auf den Button, um dein neues Passwort festzulegen:

{{ .ConfirmationURL }}

Wenn du keine Änderung angefordert hast, kannst du diese Mail ignorieren. Dein Konto bleibt unverändert.

Herzliche Grüße
Team LUVI
```

## Pflegehinweise

- `{{ .ConfirmationURL }}` öffnet `luvi://auth-callback` → `/auth/password/new` in der App.
- Passe Änderungen immer doppelt an: im Supabase Dashboard **und** hier.
- Keine Secrets oder SMTP-Header committen – nur Subjekt + Body Copy.
- Doc-Guard-Test: `flutter test test/dev/password_recovery_email_template_doc_guard_test.dart`
