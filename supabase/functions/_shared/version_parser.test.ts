import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { parseVersion, isValidVersionFormat } from "./version_parser.ts";

Deno.test("parseVersion: valid v{major} format", () => {
  const result1 = parseVersion("v1");
  assertEquals(result1.valid, true);
  assertEquals(result1.major, 1);
  assertEquals(result1.minor, 0);

  const result2 = parseVersion("v10");
  assertEquals(result2.valid, true);
  assertEquals(result2.major, 10);
  assertEquals(result2.minor, 0);
});

Deno.test("parseVersion: valid v{major}.{minor} format", () => {
  const result1 = parseVersion("v1.0");
  assertEquals(result1.valid, true);
  assertEquals(result1.major, 1);
  assertEquals(result1.minor, 0);

  const result2 = parseVersion("v2.5");
  assertEquals(result2.valid, true);
  assertEquals(result2.major, 2);
  assertEquals(result2.minor, 5);
});

Deno.test("parseVersion: invalid formats", () => {
  const invalid = ["1.0", "version1", "v1.0.1", "", "v", "bad"];
  for (const input of invalid) {
    const result = parseVersion(input);
    assertEquals(result.valid, false);
    assertEquals(result.error !== undefined, true);
  }
});

Deno.test("isValidVersionFormat: validates correctly", () => {
  assertEquals(isValidVersionFormat("v1"), true);
  assertEquals(isValidVersionFormat("v1.0"), true);
  assertEquals(isValidVersionFormat("v10.99"), true);

  assertEquals(isValidVersionFormat("1.0"), false);
  assertEquals(isValidVersionFormat("version1"), false);
  assertEquals(isValidVersionFormat("v1.0.1"), false);
  assertEquals(isValidVersionFormat(""), false);
});
