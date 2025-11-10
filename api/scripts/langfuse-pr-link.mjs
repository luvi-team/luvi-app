// Create a small Langfuse trace and print a UI deep link.
// Prints lines:
//   TRACE_ID=<id>
//   TRACE_UI_URL=<url>
// Exits 0 even on failure to keep CI non-blocking.

import { Langfuse } from 'langfuse';

const pk = process.env.LANGFUSE_PUBLIC_KEY;
const sk = process.env.LANGFUSE_SECRET_KEY;
const rawHost = process.env.LANGFUSE_HOST ?? 'https://cloud.langfuse.com';

if (!pk || !sk) {
  console.log('SKIP: LANGFUSE_PUBLIC_KEY/SECRET_KEY not configured.');
  process.exit(0);
}

let host = 'https://cloud.langfuse.com';
try {
  const u = new URL(rawHost);
  if (u.protocol === 'https:' && !u.username && !u.password) {
    host = u.toString().replace(/\/$/, '');
  }
} catch {}

try {
  const lf = new Langfuse({
    publicKey: pk,
    secretKey: sk,
    baseUrl: host,
    flushAt: 1,
    flushInterval: 0,
    release: process.env.GITHUB_SHA,
    environment: 'ci',
  });

  const pr = process.env.GITHUB_PR_NUMBER;
  const repo = process.env.GITHUB_REPO;
  const trace = lf.trace({
    name: 'pr-ci-trace',
    userId: 'ci',
    input: { source: 'github-actions' },
    metadata: { repo, pr, commit: process.env.GITHUB_SHA },
  });

  // Minimal generation for visibility
  const gen = trace.generation({
    name: 'ci-sample',
    model: 'ci/dummy',
    input: 'ping',
    output: 'pong',
    usage: { promptTokens: 1, completionTokens: 1 },
  });
  await gen.end();

  // Try to get UI URL
  let uiUrl;
  const anyLf = /** @type {any} */ (lf);
  try {
    if (anyLf.api?.traceGet && (trace.id || trace.traceId)) {
      const t = await anyLf.api.traceGet(trace.id ?? trace.traceId);
      if (t?.htmlPath) uiUrl = host + t.htmlPath;
    }
  } catch {}

  if (typeof anyLf.flushAsync === 'function') {
    await anyLf.flushAsync();
  }
  if (typeof anyLf.shutdownAsync === 'function') {
    await anyLf.shutdownAsync();
  }

  console.log(`TRACE_ID=${trace.id ?? trace.traceId ?? ''}`);
  if (uiUrl) console.log(`TRACE_UI_URL=${uiUrl}`);
} catch (e) {
  console.log('SKIP: failed to create Langfuse trace:', e?.message || String(e));
  // non-blocking
}

