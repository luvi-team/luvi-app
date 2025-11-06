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
      if ((trace as any)?.end) {
        await (trace as any).end();
      }

      traceUrl = trace.getTraceUrl?.();
      posted = true;
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
    }),
    {
    status: 200,
    headers: { "content-type": "application/json" },
    },
  );
}
