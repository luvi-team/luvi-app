export const config = { runtime: "edge", regions: ["fra1"] };

import { createLangfuse } from "../_lib/langfuse.js";

export default async function handler(req: Request): Promise<Response> {
  void req;
  const { safe, instance } = createLangfuse();
  const started = Date.now();
  let posted = false;
  let traceUrl: string | undefined;
  let err: string | undefined;

  if (safe && instance) {
    try {
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

      // Optionally finalize trace if SDK exposes end() on trace client
      if ('end' in trace && typeof trace.end === 'function') {
        await trace.end();
      }

      // Ausstehende Events sofort senden und Client ggf. schließen
      await (instance as any)?.flushAsync?.();
      await (instance as any)?.shutdownAsync?.();

      traceUrl = trace.getTraceUrl?.();
      posted = true;
    } catch (e) {
      console.error("langfuse trace-test error", e);
  const isProd = process.env.VERCEL_ENV === 'production';
  if (isProd && !safe) {
    return new Response(JSON.stringify({ ok: false }), { status: 503 });
  }

  const tookMs = Date.now() - started;
  return new Response(
    JSON.stringify({
      ok: safe && !err,
      safe,
      posted,
      ...(isProd ? {} : {
        env: process.env.VERCEL_ENV,
        host: process.env.LANGFUSE_HOST ?? "https://cloud.langfuse.com",
      }),
      tookMs,
      err,
      traceUrl,
    }),
    {
    status: safe && !err ? 200 : 500,
    headers: { "content-type": "application/json" },
    },
  );
}
    headers: { "content-type": "application/json" },
    },
  );
}
