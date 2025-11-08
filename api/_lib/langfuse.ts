import { Langfuse } from "langfuse";

export type SafeLangfuse = { instance?: Langfuse; safe: boolean };

export function createLangfuse(): SafeLangfuse {
  const pk = process.env.LANGFUSE_PUBLIC_KEY;
  const sk = process.env.LANGFUSE_SECRET_KEY;
  const rawHost = process.env.LANGFUSE_HOST ?? "https://cloud.langfuse.com";
  // Mitigation: enforce https and a clean base URL; fall back to default if invalid
  let host = "https://cloud.langfuse.com";
  try {
    const parsed = new URL(rawHost);
    if (parsed.protocol === "https:" && !parsed.username && !parsed.password) {
      host = parsed.toString().replace(/\/$/, "");
    }
  } catch {
    // ignore; keep default host
  }

  if (!pk || !sk) {
    // Fallback: no ENV set -> stub so app doesn't crash
    return { safe: false, instance: undefined };
  }

  try {
    const lf = new Langfuse({
      publicKey: pk,
      secretKey: sk,
      baseUrl: host,
      // Send immediately & capture context
      flushAt: 1,
      flushInterval: 0,
      release: process.env.VERCEL_GIT_COMMIT_SHA,
      environment: process.env.VERCEL_ENV,
    });

    // Enable debug output if available (optional feature)
    // Note: debug() may not be in official types, hence the type cast
    if ('debug' in lf && typeof (lf as any).debug === 'function') {
      try {
        (lf as any).debug(true);
      } catch (error) {
        // Silently ignore - debug is optional
      }
    }

    return { safe: true, instance: lf };
  } catch (error) {
    // Defensive: never throw in Edge handlers
    console.error("Failed to initialize Langfuse:", {
      error,
      host,
      hasPublicKey: !!pk,
      hasSecretKey: !!sk,
    });
    return { safe: false, instance: undefined };
  }
}
