import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.57.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");
// Observability & protection controls (overridable via env, safe defaults)
const RATE_LIMIT_WINDOW_SEC = parseInt(
  Deno.env.get("CONSENT_RATE_LIMIT_WINDOW_SEC") ?? "60",
);
const RATE_LIMIT_MAX_REQUESTS = parseInt(
  Deno.env.get("CONSENT_RATE_LIMIT_MAX_REQUESTS") ?? "20",
);
// Optional webhook to raise alerts on notable events (errors/spikes). This should
// point to your alerting system (e.g. Slack incoming webhook, Log Ingest, etc.).
const ALERT_WEBHOOK_URL = Deno.env.get("CONSENT_ALERT_WEBHOOK_URL");
// Sample alerts to avoid flooding (0.0–1.0). Default: 0.1 (10%).
const ALERT_SAMPLE_RATE = Math.max(
  0,
  Math.min(1, Number(Deno.env.get("CONSENT_ALERT_SAMPLE_RATE") ?? 0.1)),
);

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error("Missing required environment variables: SUPABASE_URL and SUPABASE_ANON_KEY must be set");
}
const VALID_SCOPES = [
  "health",
  "analytics",
  "marketing",
  "ai_journal",
  "terms",
] as const;

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
    // @ts-ignore Deno runtime provides crypto.randomUUID
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

function validateScopes(raw: unknown): { valid: string[]; invalid: unknown[] } {
  if (!Array.isArray(raw)) return { valid: [], invalid: [] };
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

serve(async (req) => {
  const started = Date.now();
  const requestId = getRequestId(req);
  if (req.method !== "POST") {
    logMetric(requestId, "method_not_allowed", { method: req.method });
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  const authorization = req.headers.get("Authorization");
  if (!authorization) {
    logMetric(requestId, "unauthorized", { reason: "missing_authorization" });
    return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
      status: 401,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  let body: ConsentRequestPayload = {};
  try {
    body = await req.json();
  } catch (error) {
    console.error("Invalid request body parse error", error);
    logMetric(requestId, "invalid", { reason: "invalid_json" });
    return new Response(JSON.stringify({ error: "Invalid request body" }), {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  let policyVersion: string | undefined;
  if (typeof body.policy_version === "string") {
    policyVersion = body.policy_version;
  } else if (typeof body.version === "string") {
    policyVersion = body.version;
  } else {
    policyVersion = undefined;
  }
  const rawScopes = Array.isArray(body.scopes) ? body.scopes : undefined;
  if (!policyVersion) {
    logMetric(requestId, "invalid", { reason: "missing_policy_version" });
    return new Response(JSON.stringify({ error: "policy_version is required" }), {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  if (!rawScopes || rawScopes.length === 0) {
    logMetric(requestId, "invalid", { reason: "missing_scopes" });
    return new Response(JSON.stringify({ error: "scopes must be a non-empty array" }), {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  const { valid: validatedScopes, invalid: invalidScopes } = validateScopes(
    rawScopes,
  );

  if (invalidScopes.length > 0) {
    logMetric(requestId, "invalid", { reason: "invalid_scopes", invalidScopes });
    return new Response(JSON.stringify({ error: "Invalid scopes provided", invalidScopes }), {
      status: 400,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: {
      headers: {
        Authorization: authorization,
      },
    },
  });

  const { data: userResult, error: authError } = await supabase.auth.getUser();
  if (authError || !userResult?.user) {
    logMetric(requestId, "unauthorized", { reason: "auth_failed" });
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  const payload = {
    user_id: userResult.user.id,
    version: policyVersion,
    scopes: validatedScopes,
  };

  // Per-user sliding-window rate limit using existing consents timestamps
  try {
    const windowStartIso = new Date(Date.now() - RATE_LIMIT_WINDOW_SEC * 1000).toISOString();
    const { count, error: rlError } = await supabase
      .from("consents")
      .select("id", { count: "exact", head: true })
      .eq("user_id", payload.user_id)
      .gt("created_at", windowStartIso);

    if (rlError) {
      console.error("rate_limit_count_error", rlError);
      logMetric(requestId, "error", { where: "rate_limit_count", code: rlError.code ?? "unknown" });
      await maybeAlert(requestId, "error", { where: "rate_limit_count" });
    } else if ((count ?? 0) >= RATE_LIMIT_MAX_REQUESTS) {
      const elapsed = Date.now() - started;
      logMetric(requestId, "rate_limited", {
        user_id: payload.user_id,
        count,
        window_sec: RATE_LIMIT_WINDOW_SEC,
        max: RATE_LIMIT_MAX_REQUESTS,
        duration_ms: elapsed,
      });
      await maybeAlert(requestId, "rate_limited", {
        user_id: payload.user_id,
        in_window: count ?? 0,
        window_sec: RATE_LIMIT_WINDOW_SEC,
      });
      return new Response(JSON.stringify({ error: "Rate limit exceeded" }), {
        status: 429,
        headers: {
          "Content-Type": "application/json",
          "Retry-After": `${RATE_LIMIT_WINDOW_SEC}`,
          "X-RateLimit-Limit": `${RATE_LIMIT_MAX_REQUESTS}`,
          "X-RateLimit-Remaining": "0",
          "X-Request-Id": requestId,
        },
      });
    }
  } catch (e) {
    console.error("rate_limit_check_exception", e);
    logMetric(requestId, "error", { where: "rate_limit_exception" });
    await maybeAlert(requestId, "error", { where: "rate_limit_exception" });
  }

  const { error } = await supabase
    .from("consents")
    .insert(payload);

  if (error) {
    console.error("consents insert failed", error?.code ?? "unknown");
    const elapsed = Date.now() - started;
    logMetric(requestId, "error", {
      where: "consents_insert",
      code: error.code ?? "unknown",
      user_id: payload.user_id,
      duration_ms: elapsed,
    });
    await maybeAlert(requestId, "error", {
      where: "consents_insert",
      code: error.code ?? "unknown",
      user_id: payload.user_id,
    });
    return new Response(JSON.stringify({ error: "Failed to log consent" }), {
      status: 500,
      headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
    });
  }

  const elapsed = Date.now() - started;
  logMetric(requestId, "success", {
    user_id: payload.user_id,
    scopes_count: payload.scopes.length,
    duration_ms: elapsed,
    version: payload.version,
    source: (typeof body.source === "string" ? body.source : undefined) ?? null,
    appVersion: (typeof body.appVersion === "string" ? body.appVersion : undefined) ?? null,
  });

  // Audit (info-level): minimal, structured log that confirms consent was recorded.
  // Do not log full scopes or other sensitive data.
  try {
    console.info("consent_recorded", {
      user_id: payload.user_id,
      version: payload.version,
      scope_count: payload.scopes.length,
    });
  } catch (_) {
    // Ignore logging failures to avoid impacting the response path
  }

  return new Response(JSON.stringify({ ok: true, request_id: requestId }), {
    status: 201,
    headers: { "Content-Type": "application/json", "X-Request-Id": requestId },
  });
});
