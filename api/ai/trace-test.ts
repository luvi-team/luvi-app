export const config = { runtime: "edge", regions: ["fra1"] };

import { createLangfuse } from "../_lib/langfuse.js";

export default async function handler(req: Request): Promise<Response> {
  void req;
  const { safe, instance } = createLangfuse();

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
    } catch (e) {
      console.error("langfuse trace-test error", e);
    }
  }

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { "content-type": "application/json" },
  });
}
