import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

import { VALID_SCOPES } from "./index.ts";

Deno.test("SSOT: VALID_SCOPES matches config/consent_scopes.json IDs", async () => {
  const configUrl = new URL("../../../config/consent_scopes.json", import.meta.url);
  const jsonText = await Deno.readTextFile(configUrl);
  const scopes = JSON.parse(jsonText) as Array<{ id: string }>;
  const jsonIds = scopes.map((scope) => scope.id).sort();

  const backendIds = [...VALID_SCOPES].sort();

  assertEquals(backendIds, jsonIds);
});
