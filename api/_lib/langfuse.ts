import { Langfuse } from "langfuse";

export type SafeLangfuse = { instance?: Langfuse; safe: boolean };

export function createLangfuse(): SafeLangfuse {
  const pk = process.env.LANGFUSE_PUBLIC_KEY;
  const sk = process.env.LANGFUSE_SECRET_KEY;
  const host = process.env.LANGFUSE_HOST ?? "https://cloud.langfuse.com";

  if (!pk || !sk) {
    // Fallback: keine ENV gesetzt -> Stub, damit App nicht crasht
    return { safe: false, instance: undefined };
  }

  try {
    const lf = new Langfuse({
      publicKey: pk,
      secretKey: sk,
      baseUrl: host,
      // sofort senden & Kontext
      flushAt: 1,
      flushInterval: 0,
      release: process.env.VERCEL_GIT_COMMIT_SHA,
      environment: process.env.VERCEL_ENV,
    });

    // Debug-Ausgabe aktivieren, falls verfügbar
    // Option 1: Check if method exists with proper typing
    if ('debug' in lf && typeof (lf as any).debug === 'function') {
      try {
        (lf as any).debug(true);
      } catch (error) {
        // Silently ignore - debug is optional
      }
  } catch (error) {
    // Defensiv: nie throwen in Edge-Handlern
    console.error("Failed to initialize Langfuse:", {
      error,
      host,
      hasPublicKey: !!pk,
      hasSecretKey: !!sk,
    });
    return { safe: false, instance: undefined };
  }
    // Defensiv: nie throwen in Edge-Handlern
    console.error("Failed to initialize Langfuse:", error);
    return { safe: false, instance: undefined };
  }
}
