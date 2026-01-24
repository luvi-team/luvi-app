import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

import { VALID_SCOPES } from "./index.ts";

function assertScopeArray(
  value: unknown,
  source: string,
): asserts value is Array<{ id: string }> {
  if (!Array.isArray(value)) {
    throw new Error(`${source} must be a JSON array`);
  }
  const invalidIndex = value.findIndex((item) =>
    typeof item !== "object" ||
    item === null ||
    !("id" in item) ||
    typeof (item as { id: unknown }).id !== "string"
  );
  if (invalidIndex !== -1) {
    throw new Error(
      `${source} contains invalid item at index ${invalidIndex} (expected { id: string })`,
    );
  }
}

Deno.test("SSOT: VALID_SCOPES matches config/consent_scopes.json IDs", async () => {
  // Root config - separate file I/O and JSON parse error handling
  const rootConfigUrl = new URL("../../../config/consent_scopes.json", import.meta.url);
  let rootJsonText: string;
  try {
    rootJsonText = await Deno.readTextFile(rootConfigUrl);
  } catch (e) {
    throw new Error(`Failed to read file ${rootConfigUrl}: ${e instanceof Error ? e.message : e}`);
  }

  let rootScopes: Array<{ id: string }>;
  try {
    rootScopes = JSON.parse(rootJsonText) as Array<{ id: string }>;
  } catch (e) {
    throw new Error(`Failed to parse JSON from ${rootConfigUrl}: ${e instanceof Error ? e.message : e}`);
  }
  assertScopeArray(rootScopes, `Parsed scopes from ${rootConfigUrl}`);
  const rootIds = rootScopes.map((scope) => scope.id).sort();

  // Bundled config - separate file I/O and JSON parse error handling
  const bundledConfigUrl = new URL("./consent_scopes.json", import.meta.url);
  let bundledJsonText: string;
  try {
    bundledJsonText = await Deno.readTextFile(bundledConfigUrl);
  } catch (e) {
    throw new Error(`Failed to read file ${bundledConfigUrl}: ${e instanceof Error ? e.message : e}`);
  }

  let bundledScopes: Array<{ id: string }>;
  try {
    bundledScopes = JSON.parse(bundledJsonText) as Array<{ id: string }>;
  } catch (e) {
    throw new Error(`Failed to parse JSON from ${bundledConfigUrl}: ${e instanceof Error ? e.message : e}`);
  }
  assertScopeArray(bundledScopes, `Parsed scopes from ${bundledConfigUrl}`);
  const bundledIds = bundledScopes.map((scope) => scope.id).sort();

  // Ensure the deployed bundle stays in sync with SSOT.
  assertEquals(bundledIds, rootIds);

  const backendIds = [...VALID_SCOPES].sort();
  assertEquals(backendIds, rootIds);
});
