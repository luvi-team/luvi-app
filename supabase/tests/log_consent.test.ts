// Contract tests for the log_consent Edge Function.
// These tests assert the current contract (request payload + responses).

import { assertEquals, assertExists } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.57.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://localhost:54321";
const FUNCTION_URL = Deno.env.get("LOG_CONSENT_FUNCTION_URL") ??
  `${SUPABASE_URL.replace(/\/$/, "")}/functions/v1/log_consent`;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const TEST_EMAIL = Deno.env.get("LOG_CONSENT_TEST_EMAIL") ?? "log-consent-contract@example.com";
const TEST_PASSWORD = Deno.env.get("LOG_CONSENT_TEST_PASSWORD") ?? "Testpass123!";
let cachedAccessToken: string | null = null;

function buildHeaders(accessToken?: string): Record<string, string> {
  const headers: Record<string, string> = {};
  headers["Content-Type"] = "application/json";
  if (SUPABASE_ANON_KEY) {
    headers["apikey"] = SUPABASE_ANON_KEY;
  }
  if (accessToken) {
    headers["Authorization"] = `Bearer ${accessToken}`;
  }
  return headers;
}

async function ensureTestUserAccessToken(): Promise<string> {
  if (cachedAccessToken) return cachedAccessToken;
  if (!SUPABASE_ANON_KEY) {
    throw new Error("SUPABASE_ANON_KEY must be set for log_consent contract tests.");
  }

  const client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  let { data, error } = await client.auth.signInWithPassword({
    email: TEST_EMAIL,
    password: TEST_PASSWORD,
  });

  if (error) {
    if (error.message?.toLowerCase().includes("invalid login credentials")) {
      if (!SUPABASE_SERVICE_ROLE_KEY) {
        throw new Error(
          "Test user is missing and SUPABASE_SERVICE_ROLE_KEY is not set to create it.",
        );
      }
      const adminClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
        auth: { persistSession: false, autoRefreshToken: false },
      });
      const { error: createError } = await adminClient.auth.admin.createUser({
        email: TEST_EMAIL,
        password: TEST_PASSWORD,
        email_confirm: true,
      });
      if (createError && createError.status !== 422) {
        throw new Error(`Failed to create log_consent test user: ${createError.message}`);
      }
      ({ data, error } = await client.auth.signInWithPassword({
        email: TEST_EMAIL,
        password: TEST_PASSWORD,
      }));
      if (error) {
        throw new Error(`Failed to sign in created test user: ${error.message}`);
      }
    } else {
      throw new Error(`Failed to sign in log_consent test user: ${error.message}`);
    }
  }

  const accessToken = data.session?.access_token;
  if (!accessToken) {
    throw new Error("Missing access token for log_consent contract tests.");
  }
  cachedAccessToken = accessToken;
  return accessToken;
}

Deno.test("log_consent: accepts valid POST requests", async () => {
  const accessToken = await ensureTestUserAccessToken();
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: JSON.stringify({
      policy_version: "v1.0.0",
      scopes: ["analytics", "marketing"],
      source: "contract-test",
      appVersion: "1.0.0-test",
    }),
  });

  assertEquals(response.status, 201);
  const data = await response.json();
  assertEquals(data.ok, true);
  assertExists(data.request_id);
  assertEquals(typeof data.request_id, "string");
});

Deno.test("log_consent: accepts canonical scopes object format with version alias", async () => {
  const accessToken = await ensureTestUserAccessToken();
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: JSON.stringify({
      version: "v1.0.0", // App sends "version", not "policy_version" - test alias
      scopes: { terms: true, analytics: true }, // CANONICAL Object-Format
      source: "contract-test-canonical",
      appVersion: "1.0.0-test",
    }),
  });

  assertEquals(response.status, 201);
  const data = await response.json();
  assertEquals(data.ok, true);
  assertExists(data.request_id);
  assertEquals(typeof data.request_id, "string");
});

Deno.test("log_consent: rejects non-POST methods", async () => {
  const response = await fetch(FUNCTION_URL, {
    method: "GET",
    headers: buildHeaders(),
  });

  assertEquals(response.status, 405);
  const data = await response.json();
  assertEquals(data.error, "Method not allowed");
  assertExists(data.request_id);
  assertEquals(typeof data.request_id, "string");
  assertEquals(response.headers.get("x-request-id"), data.request_id);
});

Deno.test("log_consent: rejects malformed JSON payloads", async () => {
  const accessToken = await ensureTestUserAccessToken();
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: "{ invalid json }",
  });

  assertEquals(response.status, 400);
  const data = await response.json();
  assertEquals(data.error, "Invalid request body");
  assertExists(data.request_id);
  assertEquals(typeof data.request_id, "string");
  assertEquals(response.headers.get("x-request-id"), data.request_id);
});

// ============================================================================
// Contract Tests: Error Cases (P2.1 Erweiterung)
// ============================================================================

Deno.test("log_consent: rejects requests without authentication (401)", async () => {
  // No Authorization header, only apikey
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(), // No accessToken → no Authorization header
    body: JSON.stringify({
      policy_version: "v1.0.0",
      scopes: ["analytics"],
    }),
  });

  assertEquals(response.status, 401);
  const data = await response.json();
  assertEquals(data.error, "Missing Authorization header");
  assertExists(data.request_id);
});

Deno.test("log_consent: rejects invalid access token (401)", async () => {
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders("invalid-token-that-is-not-jwt"),
    body: JSON.stringify({
      policy_version: "v1.0.0",
      scopes: ["analytics"],
    }),
  });

  assertEquals(response.status, 401);
  const data = await response.json();
  assertEquals(data.error, "Unauthorized");
  assertExists(data.request_id);
});

Deno.test("log_consent: rejects empty scopes array (400)", async () => {
  const accessToken = await ensureTestUserAccessToken();
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: JSON.stringify({
      policy_version: "v1.0.0",
      scopes: [], // Empty array
    }),
  });

  assertEquals(response.status, 400);
  const data = await response.json();
  assertEquals(data.error, "scopes must be non-empty");
  assertExists(data.request_id);
});

Deno.test("log_consent: rejects empty scopes object (400)", async () => {
  const accessToken = await ensureTestUserAccessToken();
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: JSON.stringify({
      policy_version: "v1.0.0",
      scopes: {}, // Empty object
    }),
  });

  assertEquals(response.status, 400);
  const data = await response.json();
  assertEquals(data.error, "scopes must be non-empty");
  assertExists(data.request_id);
});

Deno.test("log_consent: rejects invalid scopes (400)", async () => {
  const accessToken = await ensureTestUserAccessToken();
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: JSON.stringify({
      policy_version: "v1.0.0",
      scopes: ["invalid_scope_name", "another_invalid"],
    }),
  });

  assertEquals(response.status, 400);
  const data = await response.json();
  assertEquals(data.error, "Invalid scopes provided");
  assertExists(data.invalidScopes);
  assertExists(data.invalidScopesCount);
  assertEquals(data.invalidScopesCount, 2);
  assertExists(data.request_id);
});

Deno.test("log_consent: rejects missing policy_version (400)", async () => {
  const accessToken = await ensureTestUserAccessToken();
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: JSON.stringify({
      // No policy_version or version
      scopes: ["analytics"],
    }),
  });

  assertEquals(response.status, 400);
  const data = await response.json();
  assertEquals(data.error, "policy_version is required");
  assertExists(data.request_id);
});

Deno.test("log_consent: rejects non-boolean values in scopes object (400)", async () => {
  const accessToken = await ensureTestUserAccessToken();
  const response = await fetch(FUNCTION_URL, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: JSON.stringify({
      policy_version: "v1.0.0",
      scopes: { analytics: "yes", terms: 123 }, // Non-boolean values
    }),
  });

  assertEquals(response.status, 400);
  const data = await response.json();
  // Should reject or treat non-booleans as invalid
  assertExists(data.request_id);
});

// Note: 429 Rate Limit test is commented out as it requires hitting the rate limit
// which could be disruptive in CI. Enable manually for integration testing.
// Deno.test("log_consent: returns 429 when rate limited", async () => {
//   const accessToken = await ensureTestUserAccessToken();
//   // Would need to send many requests quickly to trigger rate limit
//   // This is intentionally left as documentation for manual testing
// });
