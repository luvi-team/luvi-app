export const config = { runtime: "edge", regions: ["fra1"] };

import { createLangfuse } from "../_lib/langfuse.js";
import type { Langfuse } from "langfuse";

// Extended Langfuse types for methods that may not be in official typings
// Using subset instead of extends to avoid type conflicts with official API
type LangfuseExtended = Langfuse & {
  flushAsync?: () => Promise<void>;
  shutdownAsync?: () => Promise<void>;
};

interface LangfuseTrace {
  id?: string;
  traceId?: string;
  end?: () => void | Promise<void>;
  getTraceUrl?: () => string;
  generation: (options: {
    name: string;
    model: string;
    input: string;
    output: string;
    usage: { promptTokens: number; completionTokens: number };
  }) => LangfuseGeneration;
}

interface LangfuseGeneration {
  end: () => void | Promise<void>;
}

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
          const extendedInstance = instance as LangfuseExtended;
          const trace = instance.trace({
            name: "trace-test",
            userId: "dev-check",
            input: { source: "manual-test" },
            metadata: { route: "/api/ai/trace-test", env: process.env.VERCEL_ENV ?? "unknown" },
          }) as unknown as LangfuseTrace;

          const gen = trace.generation({
            name: "sample-generation",
            model: "test/dummy",
            input: "ping",
            output: "pong",
            usage: { promptTokens: 1, completionTokens: 1 },
          });

          await gen.end();

          // End optional trace (not all types export .end)
          if (trace.end) {
            await trace.end();
          }

          // Send pending events
          if (extendedInstance.flushAsync) {
            await extendedInstance.flushAsync();
          }

          // Resolve project-scoped UI path (if available)
          try {
            const traceId = trace.id ?? trace.traceId;
            const apiAny = extendedInstance as any; // API types vary by version
            if (traceId && apiAny.api?.traceGet) {
              const t = await apiAny.api.traceGet(traceId);
              const host = process.env.LANGFUSE_HOST ?? "https://cloud.langfuse.com";
              if (t?.htmlPath) uiUrl = host + t.htmlPath;
            }
          } catch (_) {
            // uiUrl is optional
          }

          // Close client if present
          if (extendedInstance.shutdownAsync) {
            await extendedInstance.shutdownAsync();
          }

          if (trace.getTraceUrl) {
            traceUrl = trace.getTraceUrl();
          }
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
      ok: posted && !err,
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
      status: err ? 500 : 200,
      headers: { "content-type": "application/json" },
    },
  );
}
