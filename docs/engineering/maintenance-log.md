# Maintenance Log

Audit trail für wiederkehrende Infra-/CI-Überprüfungen (Quartalsrhythmus, mindestens Jan/Apr/Jul/Okt). Neue Einträge anhängen, keine Historie löschen.

## GitHub Actions Pin Review

| Date (UTC) | Workflow | Actions Reviewed | Outcome | Next Review |
|------------|----------|------------------|---------|-------------|
| 2025-11-11 | `.github/workflows/supabase-db-dry-run.yml` | `actions/checkout@v4`, `dorny/paths-filter@v3`, `supabase/setup-cli@v1` | Release Notes bis 2025-11-11 geprüft, keine sicherheitsrelevanten Updates nötig → Pinnings unverändert lassen | 2026-02-11 |

**Notes:** falls neue Sicherheits-Patches erscheinen, zuerst Wartungs-Branch anlegen, Aktion aktualisieren, `docs/engineering/maintenance-log.md` ergänzen und Link zur Validierung in der PR nennen.
