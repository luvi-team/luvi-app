# Risk Memo: consent_logs Identifiability

Version: v1.0 · Date: 2025-11-08 · Author: Privacy/Compliance

Scope
- Table: `consent_logs` (fields: user_id, video_id, decision, ts, locale, client_version, ua_hash, ip_hash).

Assessment
- Residual identifiability risk considered LOW under the following controls:
  - No raw IP/UA stored; only HMAC digests with rotating pepper (`hmac_v1`).
  - RLS owner-based; cross-user access restricted to server-side `audit_role`.
  - Rate limiting and abuse detection use hashed identifiers without reversing.
  - Retention TTL = 12 months; older records purged automatically.

Potential linkability vectors
- Mosaic re-identification across `user_id` + `ts` + `locale` + hashed identifiers.
- Mitigations: truncated IP before HMAC, principle of least privilege, audit logging for admin reads, strict purpose limitation.

Conclusion
- With the above controls and retention limit, identifiability risk is low and proportionate to the purposes (auditability, fraud/abuse prevention). Reassess semi-annually or on scope changes.

