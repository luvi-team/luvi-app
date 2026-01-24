import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

import { VALID_SCOPES } from "./index.ts";

Deno.test("SSOT: VALID_SCOPES matches config/consent_scopes.json IDs", async () => {
  const rootConfigUrl = new URL("../../../config/consent_scopes.json", import.meta.url);
  const rootJsonText = await Deno.readTextFile(rootConfigUrl);
  const rootScopes = JSON.parse(rootJsonText) as Array<{ id: string }>;
  const rootIds = rootScopes.map((scope) => scope.id).sort();

  // The Edge Function must ship with its own bundled copy.
  const bundledConfigUrl = new URL("./consent_scopes.json", import.meta.url);
  const bundledJsonText = await Deno.readTextFile(bundledConfigUrl);
  const bundledScopes = JSON.parse(bundledJsonText) as Array<{ id: string }>;
  const bundledIds = bundledScopes.map((scope) => scope.id).sort();

  // Ensure the deployed bundle stays in sync with SSOT.
  assertEquals(bundledIds, rootIds);

  const backendIds = [...VALID_SCOPES].sort();
  assertEquals(backendIds, rootIds);
});
