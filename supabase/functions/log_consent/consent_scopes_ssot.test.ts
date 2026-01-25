import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

import { VALID_SCOPES } from "./index.ts";

interface VersionedScopeConfig {
  version: number;
  scopes: Array<{ id: string }>;
}

function assertVersionedConfig(
  value: unknown,
  source: string,
): asserts value is VersionedScopeConfig {
  if (typeof value !== 'object' || value === null) {
    throw new Error(`${source} must be an object`);
  }
  if (!('version' in value) || typeof (value as { version: unknown }).version !== 'number') {
    throw new Error(`${source} must have numeric 'version' field`);
  }
  if (!('scopes' in value) || !Array.isArray((value as { scopes: unknown }).scopes)) {
    throw new Error(`${source} must have 'scopes' array`);
  }
  const scopes = (value as VersionedScopeConfig).scopes;
  const invalidIndex = scopes.findIndex((item) =>
    typeof item !== "object" ||
    item === null ||
    !("id" in item) ||
    typeof (item as { id: unknown }).id !== "string"
  );
  if (invalidIndex !== -1) {
    throw new Error(
      `${source}.scopes[${invalidIndex}] must have string 'id'`,
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

  let rootConfig: VersionedScopeConfig;
  try {
    rootConfig = JSON.parse(rootJsonText) as VersionedScopeConfig;
  } catch (e) {
    throw new Error(`Failed to parse JSON from ${rootConfigUrl}: ${e instanceof Error ? e.message : e}`);
  }
  assertVersionedConfig(rootConfig, `Parsed config from ${rootConfigUrl}`);
  const rootIds = rootConfig.scopes.map((scope) => scope.id).sort();

  // Bundled config - separate file I/O and JSON parse error handling
  const bundledConfigUrl = new URL("./consent_scopes.json", import.meta.url);
  let bundledJsonText: string;
  try {
    bundledJsonText = await Deno.readTextFile(bundledConfigUrl);
  } catch (e) {
    throw new Error(`Failed to read file ${bundledConfigUrl}: ${e instanceof Error ? e.message : e}`);
  }

  let bundledConfig: VersionedScopeConfig;
  try {
    bundledConfig = JSON.parse(bundledJsonText) as VersionedScopeConfig;
  } catch (e) {
    throw new Error(`Failed to parse JSON from ${bundledConfigUrl}: ${e instanceof Error ? e.message : e}`);
  }
  assertVersionedConfig(bundledConfig, `Parsed config from ${bundledConfigUrl}`);
  const bundledIds = bundledConfig.scopes.map((scope) => scope.id).sort();

  // Ensure the deployed bundle stays in sync with SSOT.
  assertEquals(bundledIds, rootIds);

  // Ensure version numbers match
  assertEquals(bundledConfig.version, rootConfig.version);

  const backendIds = [...VALID_SCOPES].sort();
  assertEquals(backendIds, rootIds);
});
