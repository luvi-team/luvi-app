# Consent Revocation Flow (Art. 7(3) DSGVO)

Version: v1.0 · Applies to: external media consent (YouTube), other opt-ins

Principles
- As easy as giving consent: toggle-based UI in Settings → Datenschutz → Consent-Management.
- Auditability: use INSERT-only log entries (no UPDATE/DELETE) to maintain a complete history.
- Immediate effect: revocation disables gated features and suppresses external loads until re-consent.

UI
- Entry point: App → Settings → Datenschutz → Consent-Management.
- Controls: per-scope toggles (e.g., `external_media_youtube`).
- Copy: explains consequences (e.g., “Externe Inhalte werden nicht geladen”).
- Optional prompt to delete related optional data (if applicable to scope).

Events
- `video_consent_shown`, `video_consent_accept`, `video_consent_reject` (for in-player overlay).
- `consent_revoked` (Settings toggle off), `consent_granted` (Settings toggle on).

DB Behaviour (`consent_logs`)
- Model: append-only; latest row defines current scope state for evaluation.
- Opt-in: INSERT with `scopes` containing the enabled scope(s) and `version`.
- Opt-out: INSERT with `scopes` reflecting removal of the scope; previous entries remain intact.
- No DELETE of historical rows. RLS owner-based; audit_role for compliance.

Impact on existing logs
- Historical logs remain immutable and available for audit under appropriate access controls.
- Feature evaluation references the latest record only; revocation take effect prospectively.

Related
- Runbook: `docs/runbooks/verify-consent-flow.md`
- Roadmap section: `docs/product/roadmap.md` (S2 GDPR/Privacy)

