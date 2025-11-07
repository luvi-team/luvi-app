export const config = { runtime: "edge", regions: ["fra1"] };

import { createLangfuse } from "../_lib/langfuse.js";

export default async function handler(req: Request): Promise<Response> {
  void req;
  const { safe, instance } = createLangfuse();
  const started = Date.now();
  let posted = false;
  let traceUrl: string | undefined;
  let uiUrl: string | undefined;
  let err: string | undefined;

  if (safe && instance) {
    try {
      const LANGFUSE_TIMEOUT_MS = 8000;
      const timeoutPromise = new Promise<never>((_, reject) =>
        setTimeout(() => reject(new Error("Langfuse operation timeout")), LANGFUSE_TIMEOUT_MS),
      );

      await Promise.race([
        (async () => {
          const trace = instance.trace({
            name: "trace-test",
            userId: "dev-check",
            input: { source: "manual-test" },
            metadata: { route: "/api/ai/trace-test", env: process.env.VERCEL_ENV ?? "unknown" },
          });

          const gen = trace.generation({
            name: "sample-generation",
            model: "test/dummy",
            input: "ping",
            output: "pong",
            usage: { promptTokens: 1, completionTokens: 1 },
          });

          await gen.end();

          // Trace optional beenden (nicht alle Typen exportieren .end)
          if ((trace as any)?.end) {
            await (trace as any).end();
          }

          // Ausstehende Events senden
          await (instance as any)?.flushAsync?.();

          // Projektgebundenen UI‑Pfad ermitteln (falls verfügbar)
          try {
            const traceId: string | undefined = (trace as any)?.id ?? (trace as any)?.traceId;
            if (traceId && (instance as any)?.api?.traceGet) {
              const t = await (instance as any).api.traceGet(traceId);
              const host = process.env.LANGFUSE_HOST ?? "https://cloud.langfuse.com";
              if (t?.htmlPath) uiUrl = host + t.htmlPath;
            }
          } catch (_) {
            // uiUrl ist optional
          }

          // Client ggf. schließen
          await (instance as any)?.shutdownAsync?.();

          traceUrl = (trace as any)?.getTraceUrl?.();
          posted = true;
        })(),
        timeoutPromise,
      ]);
    } catch (e) {
      console.error("langfuse trace-test error", e);
      err = e instanceof Error ? e.message : String(e);
    }
  }

  const tookMs = Date.now() - started;
  return new Response(
    JSON.stringify({
      ok: true,
      safe,
      posted,
      env: process.env.VERCEL_ENV,
      host: process.env.LANGFUSE_HOST ?? "https://cloud.langfuse.com",
      tookMs,
      err,
      traceUrl,
      uiUrl,
    }),
    {
      status: 200,
      headers: { "content-type": "application/json" },
    },
  );
}
