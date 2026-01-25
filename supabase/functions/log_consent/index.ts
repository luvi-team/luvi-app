import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.57.0";
import { parseVersion } from "../_shared/version_parser.ts";
import consentScopesConfig from "./consent_scopes.json" assert { type: "json" };

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`Missing required environment variable: ${name} must be set`);
  }
  return value;
}

// Salt used to pseudonymize consent/user identifiers in metrics logs.
// If not provided, we fall back to an unsalted SHA-256 hash to avoid logging PII
// while keeping metrics functional in lower environments.
const CONSENT_METRIC_SALT = Deno.env.get("CONSENT_METRIC_SALT");
// Pepper for UA/IP hashing (HMAC-SHA256). Defaults to CONSENT_METRIC_SALT so
// that environments with a single secret keep a consistent pseudonymization
// story while still avoiding raw IP/UA in logs.
const CONSENT_HASH_PEPPER = Deno.env.get("CONSENT_HASH_PEPPER") ??
  CONSENT_METRIC_SALT ??
  "";
const CONSENT_HASH_VERSION = CONSENT_HASH_PEPPER ? "hmac_v1" : "sha256_v0";
// Observability & protection controls (overridable via env, safe defaults)
const RATE_LIMIT_WINDOW_SEC = parseInt(
  Deno.env.get("CONSENT_RATE_LIMIT_WINDOW_SEC") ?? "60",
);
if (isNaN(RATE_LIMIT_WINDOW_SEC) || RATE_LIMIT_WINDOW_SEC <= 0 || RATE_LIMIT_WINDOW_SEC > 3600) {
  throw new Error("CONSENT_RATE_LIMIT_WINDOW_SEC must be between 1 and 3600");
}
const RATE_LIMIT_MAX_REQUESTS = parseInt(
  Deno.env.get("CONSENT_RATE_LIMIT_MAX_REQUESTS") ?? "5",
);
if (isNaN(RATE_LIMIT_MAX_REQUESTS) || RATE_LIMIT_MAX_REQUESTS <= 0 || RATE_LIMIT_MAX_REQUESTS > 1000) {
  throw new Error("CONSENT_RATE_LIMIT_MAX_REQUESTS must be between 1 and 1000");
}
const RATE_LIMIT_BURST = parseInt(
  Deno.env.get("CONSENT_RATE_LIMIT_BURST") ?? "3",
);
if (isNaN(RATE_LIMIT_BURST) || RATE_LIMIT_BURST < 0 || RATE_LIMIT_BURST > 1000) {
  throw new Error("CONSENT_RATE_LIMIT_BURST must be between 0 and 1000");
}
// Optional webhook to raise alerts on notable events (errors/spikes). This should
// point to your alerting system (e.g. Slack incoming webhook, Log Ingest, etc.).
const ALERT_WEBHOOK_URL = Deno.env.get("CONSENT_ALERT_WEBHOOK_URL");
// Sample alerts to avoid flooding (0.0–1.0). Default: 0.1 (10%).
const rawAlertSampleRate = Deno.env.get("CONSENT_ALERT_SAMPLE_RATE");
const parsedAlertSampleRate = Number(rawAlertSampleRate ?? "0.1");
if (!Number.isFinite(parsedAlertSampleRate)) {
  throw new Error("CONSENT_ALERT_SAMPLE_RATE must be a finite number between 0 and 1");
}
const ALERT_SAMPLE_RATE = Math.max(0, Math.min(1, parsedAlertSampleRate));
const MAX_LOGGED_INVALID_SCOPES = 10;
const MAX_INVALID_SCOPE_STRING_LENGTH = 200;
// ---------------------------------------------------------------------------
// Consent Scopes Configuration
// ---------------------------------------------------------------------------
// SSOT: `config/consent_scopes.json` is the canonical scope list (shared with the app).
// For Edge deployments, we include a copy in this function directory:
// `supabase/functions/log_consent/consent_scopes.json`.
// The SSOT test (consent_scopes_ssot.test.ts) validates:
// - function copy matches `config/consent_scopes.json`
// - VALID_SCOPES export matches that list
// Dart enum is at lib/core/privacy/consent_types.dart.
// ---------------------------------------------------------------------------

// If true, missing bundled config should fail fast to prevent scope drift.
// Set CONSENT_SCOPES_REQUIRE_BUNDLE=false to allow fallback in local/dev.
const REQUIRE_CONSENT_SCOPES_BUNDLE =
  (Deno.env.get("CONSENT_SCOPES_REQUIRE_BUNDLE") ?? "true") === "true";

// Fallback scopes used if config file cannot be read (deployment resilience)
const FALLBACK_SCOPES = [
  "terms",
  "health_processing",
  "ai_journal",
  "analytics",
  "marketing",
  "model_training",
] as const;

/** Regex pattern for valid scope IDs: lowercase alphanumeric + underscore, 1-50 chars */
const SCOPE_ID_PATTERN = /^[a-z][a-z0-9_]{0,49}$/;

/** Type guard for consent scope config items. */
function isValidScopeItem(item: unknown): item is { id: string } {
  if (typeof item !== "object" || item === null || !("id" in item)) {
    return false;
  }
  const id = (item as { id: unknown }).id;
  if (typeof id !== "string") {
    return false;
  }
  // Validate format: lowercase alphanumeric + underscore, starts with letter
  return SCOPE_ID_PATTERN.test(id);
}

async function loadConsentScopes(): Promise<readonly string[]> {
  try {
    // Import JSON directly so the bundle always includes consent_scopes.json.
    // CI guardrail: `.github/workflows/ci.yml` runs
    // `deno test supabase/functions/log_consent/consent_scopes_ssot.test.ts`
    // which fails if this file is missing or out of sync with SSOT.
    const parsed: unknown = consentScopesConfig;

    // Runtime validation: expect versioned object format { version, scopes }
    if (
      typeof parsed !== 'object' ||
      parsed === null ||
      !('scopes' in parsed) ||
      !Array.isArray((parsed as { scopes: unknown }).scopes) ||
      !('version' in parsed) ||
      typeof (parsed as { version: unknown }).version !== 'string'
    ) {
      console.warn(
        JSON.stringify({
          severity: "warning",
          ts: new Date().toISOString(),
          event: "consent_scopes_load",
          status: "invalid_structure",
          message: "consent_scopes.json must be { version, scopes: [...] }, using fallback",
          receivedType: typeof parsed,
        })
      );
      return FALLBACK_SCOPES;
    }

    const scopeArray = (parsed as { scopes: unknown[] }).scopes;

    // Validate each element and extract valid IDs (deduplicated)
    const validIdsSet = new Set<string>();
    const duplicateIds: string[] = [];
    let invalidCount = 0;

    for (const item of scopeArray) {
      if (isValidScopeItem(item)) {
        if (validIdsSet.has(item.id)) {
          duplicateIds.push(item.id);
        } else {
          validIdsSet.add(item.id);
        }
      } else {
        invalidCount++;
      }
    }

    // Log warning if duplicate IDs were found
    if (duplicateIds.length > 0) {
      console.warn(
        JSON.stringify({
          severity: "warning",
          ts: new Date().toISOString(),
          event: "consent_scopes_load",
          status: "duplicate_ids",
          message: `${duplicateIds.length} duplicate ID(s) found in consent_scopes.json`,
          duplicateIds,
          duplicateCount: duplicateIds.length,
        })
      );
    }

    const validIds = Array.from(validIdsSet);

    // Log warning if any invalid items were found
    if (invalidCount > 0) {
      console.warn(
        JSON.stringify({
          severity: "warning",
          ts: new Date().toISOString(),
          event: "consent_scopes_load",
          status: "partial_validation",
          message: `${invalidCount} invalid item(s) filtered out from consent_scopes.json`,
          invalidCount,
          validCount: validIds.length,
        })
      );
    }

    // Return fallback if no valid scopes found
    if (validIds.length === 0) {
      console.warn(
        JSON.stringify({
          severity: "warning",
          ts: new Date().toISOString(),
          event: "consent_scopes_load",
          status: "empty_config",
          message: "No valid scopes found in consent_scopes.json, using fallback",
        })
      );
      return FALLBACK_SCOPES;
    }

    return validIds;
  } catch (error) {
    // ERROR level: unexpected runtime failure; treat as deployment issue.
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error(
      JSON.stringify({
        severity: "error",
        ts: new Date().toISOString(),
        event: "consent_scopes_load",
        status: "fallback",
        message: "Failed to load consent_scopes.json, using fallback - check deployment bundle",
        error: errorMessage,
      })
    );
    if (REQUIRE_CONSENT_SCOPES_BUNDLE) {
      throw new Error(
        "consent_scopes.json missing from deployment bundle (CONSENT_SCOPES_REQUIRE_BUNDLE=true)",
      );
    }
    return FALLBACK_SCOPES;
  }
}

// Top-level await (supported in Deno Edge Functions)
export const VALID_SCOPES: readonly string[] = await loadConsentScopes();

interface ConsentRequestPayload {
  policy_version?: unknown;
  version?: unknown;
  scopes?: unknown;
  source?: unknown;
  appVersion?: unknown;
}

function getRequestId(req: Request): string {
  const headers = req.headers;
  const candidates = [
    "x-request-id",
    "x-cf-ray",
    "x-amzn-trace-id",
    "x-correlation-id",
  ];
  for (const h of candidates) {
    const v = headers.get(h);
    if (v && v.length > 0) return v;
  }
  try {
    return crypto.randomUUID();
  } catch {
    return `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
  }
}

type MetricOutcome =
  | "success"
  | "rate_limited"
  | "invalid"
  | "unauthorized"
  | "error"
  | "method_not_allowed";

async function hmacSha256Hex(key: string, message: string): Promise<string> {
  const enc = new TextEncoder();
  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    enc.encode(key),
    { name: "HMAC", hash: { name: "SHA-256" } },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", cryptoKey, enc.encode(message));
  return [...new Uint8Array(sig)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function sha256Hex(message: string): Promise<string> {
  const enc = new TextEncoder();
  const digest = await crypto.subtle.digest("SHA-256", enc.encode(message));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

function getClientIp(req: Request): string | undefined {
  const headers = req.headers;
  const xff = headers.get("x-forwarded-for");
  if (xff) {
    const first = xff.split(",")[0]?.trim();
    if (first) return first;
  }
  const realIp = headers.get("x-real-ip");
  if (realIp && realIp.trim().length > 0) {
    return realIp.trim();
  }
  const cf = headers.get("cf-connecting-ip");
  if (cf && cf.trim().length > 0) {
    return cf.trim();
  }
  return undefined;
}

// Normalize IP to a coarser CIDR-style representation before hashing.
// - IPv4: truncate to /24 (zero out last octet)
// - IPv6: approximate /64 by keeping the first 4 hextets
function normalizeIpForHash(ip: string | undefined | null): string | undefined {
  if (!ip) return undefined;
  const trimmed = ip.trim();
  if (!trimmed) return undefined;
  if (trimmed.includes(":")) {
    const parts = trimmed.split(":");
    const prefix = parts.slice(0, 4).join(":");
    return `${prefix}::`;
  }
  const parts = trimmed.split(".");
  if (parts.length === 4) {
    return `${parts[0]}.${parts[1]}.${parts[2]}.0`;
  }
  return trimmed;
}

function normalizeUserAgent(ua: string | undefined | null): string | undefined {
  if (!ua) return undefined;
  const trimmed = ua.trim();
  if (!trimmed) return undefined;
  return trimmed.replace(/\s+/g, " ");
}

async function computePseudonymousHash(
  input: string | undefined | null,
): Promise<string | null> {
  if (!input) return null;
  if (CONSENT_HASH_PEPPER) {
    return await hmacSha256Hex(CONSENT_HASH_PEPPER, input);
  }
  return await sha256Hex(input);
}

function logMetric(
  requestId: string,
  outcome: MetricOutcome,
  extra: Record<string, unknown> = {},
) {
  const entry = {
    ts: new Date().toISOString(),
    request_id: requestId,
    event: "consent_log",
    outcome,
    ...extra,
  };
  // Basic severity routing for log drains / alerts.
  const severity =
    outcome === "success" ? "info" :
    outcome === "error" ? "error" :
    "warning";
  const line = JSON.stringify({ severity, ...entry });
  if (severity === "error") console.error(line);
  else if (severity === "warning") console.warn(line);
  else console.log(line);
}





async function maybeAlert(
  requestId: string,
  outcome: MetricOutcome,
  payload: Record<string, unknown>,
) {
  if (!ALERT_WEBHOOK_URL) return;
  // Only alert for notable non-success outcomes; sample to limit volume.
  if (outcome === "success") return;
  if (Math.random() > ALERT_SAMPLE_RATE) return;
  const body = {
    ts: new Date().toISOString(),
    request_id: requestId,
    endpoint: "log_consent",
    outcome,
    ...payload,
  };
  try {
    await fetch(ALERT_WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(5000), // 5 second timeout
    });
  } catch (e) {
    // Swallow to avoid affecting the main path; still log for forensics.
    console.warn(
      JSON.stringify({
        severity: "warning",
        ts: new Date().toISOString(),
        event: "consent_alert_failed",
        request_id: requestId,
        reason: "webhook_failed",
        message: (e as Error)?.message ?? String(e),
      }),
    );
  }
}

function validateScopes(raw: unknown[]): { valid: string[]; invalid: unknown[] } {
  const invalid: unknown[] = [];
  const valid: string[] = [];
  for (const scope of raw) {
    if (typeof scope !== "string") {
      invalid.push(scope);
      continue;
    }
    if (!(VALID_SCOPES as readonly string[]).includes(scope)) {
      invalid.push(scope);
      continue;
    }
    valid.push(scope);
  }
  return { valid, invalid };
}

function clampInvalidScopes(scopes: unknown[]): string[] {
  return scopes.slice(0, MAX_LOGGED_INVALID_SCOPES).map((item) => {
    if (typeof item === "string") {
      return item.length > MAX_INVALID_SCOPE_STRING_LENGTH
        ? `${item.substring(0, MAX_INVALID_SCOPE_STRING_LENGTH)}...`
        : item;
    }
    if (item === null) return "[null]";
    if (Array.isArray(item)) return "[array]";
    if (typeof item === "object") return "[object]";
    if (typeof item === "number") return "[number]";
    if (typeof item === "boolean") return "[boolean]";
    if (typeof item === "undefined") return "[undefined]";
    return "[unknown]";
  });
}

function summarizeInvalidScopes(scopes: unknown[]): Record<string, number> {
  const summary: Record<string, number> = {};
  for (const scope of scopes) {
    const key = scope === null
      ? "null"
      : Array.isArray(scope)
      ? "array"
      : typeof scope;
    summary[key] = (summary[key] ?? 0) + 1;
  }
  return summary;
}

if (import.meta.main) {
  serve(async (req) => {
  const started = Date.now();
  const requestId = getRequestId(req);
  const clientIp = getClientIp(req);
  const ipForHash = normalizeIpForHash(clientIp);
  const uaForHash = normalizeUserAgent(req.headers.get("user-agent"));
  const [ipHash, uaHash] = await Promise.all([
    computePseudonymousHash(ipForHash),
    computePseudonymousHash(uaForHash),
  ]);
  if (req.method !== "POST") {
    logMetric(requestId, "method_not_allowed", {
      method: req.method,
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(JSON.stringify({ error: "Method not allowed", request_id: requestId }), {
      status: 405,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  const authorization = req.headers.get("Authorization");
  if (!authorization) {
    logMetric(requestId, "unauthorized", {
      reason: "missing_authorization",
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(
      JSON.stringify({ error: "Missing Authorization header", request_id: requestId }),
      {
      status: 401,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
      },
    );
  }

  let body: ConsentRequestPayload = {};
  try {
    body = await req.json();
  } catch (error) {
    console.error("Invalid request body parse error", error instanceof Error ? error.message : "parse_failed");
    logMetric(requestId, "invalid", {
      reason: "invalid_json",
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(JSON.stringify({ error: "Invalid request body", request_id: requestId }), {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }
  const policyVersion = typeof body.policy_version === "string"
    ? body.policy_version
    : typeof body.version === "string"
    ? body.version
    : undefined;
  if (!policyVersion) {
    logMetric(requestId, "invalid", {
      reason: "missing_policy_version",
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(
      JSON.stringify({ error: "policy_version is required", request_id: requestId }),
      {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
      },
    );
  }

  // Validate version format using shared parser
  const versionValidation = parseVersion(policyVersion);
  if (!versionValidation.valid) {
    logMetric(requestId, "invalid", {
      reason: "invalid_version_format",
      version: policyVersion,
      error: versionValidation.error,
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(
      JSON.stringify({
        error: "invalid_version_format",
        message: versionValidation.error,
        request_id: requestId,
      }),
      {
        status: 400,
        headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
      },
    );
  }

  const rawScopes = body.scopes;
  if (rawScopes == null) {
    logMetric(requestId, "invalid", {
      reason: "missing_scopes",
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(JSON.stringify({ error: "scopes must be provided", request_id: requestId }), {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  let normalizedScopes: unknown[];
  if (Array.isArray(rawScopes)) {
    normalizedScopes = rawScopes;
  } else if (
    typeof rawScopes === "object" &&
    rawScopes !== null &&
    !Array.isArray(rawScopes)
  ) {
    const scopeMap = rawScopes as Record<string, unknown>;
    const scopeKeyCount = Object.keys(scopeMap).length;
    // Use Object.entries() to correctly detect non-boolean values including undefined
    // (Object.values().find() returns undefined for undefined values, causing false negatives)
    const invalidEntry = Object.entries(scopeMap).find(
      ([, v]) => typeof v !== "boolean"
    );
    if (invalidEntry) {
      const [, invalidValue] = invalidEntry;
      logMetric(requestId, "invalid", {
        reason: "invalid_scopes_value_type",
        providedType: typeof invalidValue,
        scopeKeyCount,
        ip_hash: ipHash,
        ua_hash: uaHash,
        hash_version: CONSENT_HASH_VERSION,
      });
      return new Response(
        JSON.stringify({ error: "scopes object values must be boolean", request_id: requestId }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            "X-Request-Id": requestId,
          },
        },
      );
    }
    normalizedScopes = Object.keys(scopeMap).filter((key) => scopeMap[key] === true);
  } else {
    logMetric(requestId, "invalid", {
      reason: "invalid_scopes_type",
      providedType: typeof rawScopes,
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
      return new Response(
      JSON.stringify({
        error: "scopes must be provided as an array or object of boolean flags",
        request_id: requestId,
      }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "X-Request-Id": requestId,
        },
      },
    );
  }

  if (normalizedScopes.length === 0) {
    logMetric(requestId, "invalid", {
      reason: "missing_scopes",
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(JSON.stringify({ error: "scopes must be non-empty", request_id: requestId }), {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  const { valid: validatedScopes, invalid: invalidScopes } = validateScopes(
    normalizedScopes,
  );

  if (invalidScopes.length > 0) {
    // Clamp invalidScopes for client response without leaking raw input to logs.
    const clampedInvalidScopes = clampInvalidScopes(invalidScopes);
    const invalidScopeTypes = summarizeInvalidScopes(invalidScopes);
    logMetric(requestId, "invalid", {
      reason: "invalid_scopes",
      invalidScopesCount: invalidScopes.length,
      invalidScopeTypes,
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(
      JSON.stringify({
        error: "Invalid scopes provided",
        invalidScopes: clampedInvalidScopes,
        invalidScopesCount: invalidScopes.length,
        request_id: requestId,
      }),
      {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
      },
    );
  }

  const supabase = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
    global: {
      headers: {
        Authorization: authorization,
      },
    },
  });

  const { data: userResult, error: authError } = await supabase.auth.getUser();
  if (authError || !userResult?.user) {
    logMetric(requestId, "unauthorized", {
      reason: "auth_failed",
      code: authError?.code ?? "unknown",
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
    });
    return new Response(JSON.stringify({ error: "Unauthorized", request_id: requestId }), {
      status: 401,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  const payload = {
    user_id: userResult.user.id,
    version: policyVersion,
    scopes: Object.fromEntries(validatedScopes.map((s) => [s, true] as const)),
    scope_count: validatedScopes.length,
  } as const;

  // Compute a deterministic pseudonym for metrics: prefer HMAC(user_id, salt)
  // and fall back to plain SHA-256 when salt is not provided (lower envs).
  const consentIdHash = CONSENT_METRIC_SALT
    ? await hmacSha256Hex(CONSENT_METRIC_SALT, payload.user_id)
    : await sha256Hex(payload.user_id);

  // Atomic rate-limit check + insert wrapped in a per-user advisory lock via RPC
  const t0Rpc = Date.now();
  const { data: allowed, error: rpcError } = await supabase.rpc(
    "log_consent_if_allowed",
    {
      p_user_id: payload.user_id,
      p_version: payload.version,
      p_scopes: payload.scopes,
      p_window_sec: RATE_LIMIT_WINDOW_SEC,
      p_max_requests: RATE_LIMIT_MAX_REQUESTS,
      p_burst_max_requests: RATE_LIMIT_BURST,
    },
  );
  const rpcDuration = Date.now() - t0Rpc;

  if (rpcError) {
    console.error("consent_rpc_failed", rpcError?.code ?? "unknown");
    const elapsed = Date.now() - started;
    logMetric(requestId, "error", {
      where: "consent_rpc",
      code: rpcError?.code ?? "unknown",
      consent_id_hash: consentIdHash,
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
      duration_ms: elapsed,
      rpc_latency_ms: rpcDuration,
    });
    // Fire-and-forget: do not block response path on alert delivery
    maybeAlert(requestId, "error", { where: "consent_rpc" });
    return new Response(JSON.stringify({ error: "Failed to log consent", request_id: requestId }), {
      status: 500,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  if (allowed === false) {
    const elapsed = Date.now() - started;
    logMetric(requestId, "rate_limited", {
      consent_id_hash: consentIdHash,
      window_sec: RATE_LIMIT_WINDOW_SEC,
      max: RATE_LIMIT_MAX_REQUESTS,
      burst_max: RATE_LIMIT_BURST,
      ip_hash: ipHash,
      ua_hash: uaHash,
      hash_version: CONSENT_HASH_VERSION,
      duration_ms: elapsed,
      rpc_latency_ms: rpcDuration,
    });
    // Fire-and-forget: do not block response path on alert delivery
    maybeAlert(requestId, "rate_limited", {
      consent_id_hash: consentIdHash,
      window_sec: RATE_LIMIT_WINDOW_SEC,
    });
    return new Response(JSON.stringify({ error: "Rate limit exceeded", request_id: requestId }), {
      status: 429,
      headers: {
      "Content-Type": "application/json",
      "Retry-After": `${RATE_LIMIT_WINDOW_SEC}`,
      "X-RateLimit-Limit": `${RATE_LIMIT_MAX_REQUESTS}`,
      "X-RateLimit-Burst": `${RATE_LIMIT_BURST}`,
      "X-RateLimit-Remaining": "0",
      "X-Request-Id": requestId,
    },
  });
  }

  const elapsed = Date.now() - started;
  logMetric(requestId, "success", {
    consent_id_hash: consentIdHash,
    scope_count: payload.scope_count,
    duration_ms: elapsed,
    rpc_latency_ms: rpcDuration,
    version: payload.version,
    source: typeof body.source === "string" ? body.source : null,
    appVersion: typeof body.appVersion === "string" ? body.appVersion : null,
    ip_hash: ipHash,
    ua_hash: uaHash,
    hash_version: CONSENT_HASH_VERSION,
  });

  // Audit (info-level): minimal, structured log that confirms consent was recorded.
  // Do not log full scopes or other sensitive data.
  try {
    console.info("consent_recorded", {
      consent_id_hash: consentIdHash,
      version: payload.version,
      scope_count: payload.scope_count,
    });
  } catch (_) {
    // Ignore logging failures to avoid impacting the response path
  }

  return new Response(JSON.stringify({ ok: true, request_id: requestId }), {
    status: 201,
    headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
  });
  });
}
