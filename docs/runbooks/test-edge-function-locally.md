# Runbook: Test Edge Function Locally (Supabase)

**Zweck:** Supabase Edge Functions lokal testen (Development-Workflow, MIWF-konform).

**Wann verwenden:**
- Neue Edge Function erstellt (z.B. M5: AI-Gateway, Consent-Logging)
- Edge Function-Code geändert (Bugfix, neues Feature)
- Deployment vor Production testen (Smoke-Test)

**Voraussetzungen:**
- Supabase CLI installiert (`brew install supabase/tap/supabase`)
- Deno installiert (für Edge Functions: `brew install deno`)
- Supabase-Projekt linked (`supabase link --project-ref <project-id>`)

---

## Step 1: Edge Function erstellen/prüfen

### 1.1 Neue Edge Function erstellen

```bash
# Scaffold neue Function
supabase functions new <function-name>

# Beispiel: AI-Gateway
supabase functions new ai-gateway

# Erstellt:
# supabase/functions/ai-gateway/index.ts
```

**Minimale `index.ts`:**
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req: Request) => {
  try {
    const { prompt } = await req.json();

    // Business Logic hier
    const result = `Echo: ${prompt}`;

    return new Response(JSON.stringify({ result }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
  }
});
```

### 1.2 Bestehende Function prüfen

```bash
# Alle Functions auflisten
ls supabase/functions/

# Function-Code öffnen
cat supabase/functions/<function-name>/index.ts
```

---

## Step 2: Lokal starten (Supabase Local Development)

### 2.1 Supabase lokal starten

```bash
# Alle Services starten (DB, Auth, Storage, Functions)
supabase start

# Output prüfen:
# API URL: http://localhost:54321
# DB URL: postgresql://postgres:postgres@localhost:54322/postgres
# Studio URL: http://localhost:54323
# Inbucket URL: http://localhost:54324 (Email-Testing)
# anon key: eyJhb...
# service_role key: eyJhb... (NICHT im Client nutzen!)
```

**Wichtig:** Notiere `anon key` (für Tests).

### 2.2 Edge Function lokal serven

```bash
# Single Function serven
supabase functions serve <function-name>

# Beispiel: ai-gateway
supabase functions serve ai-gateway

# Output:
# Serving functions on http://localhost:54321/functions/v1/ai-gateway
```

**Multi-Function (alle Functions serven):**
```bash
supabase functions serve
```

### 2.3 Env-Vars setzen (Secrets)

**Lokal (`.env.local`):**
```bash
# Erstellen: supabase/.env.local
cat > supabase/.env.local <<EOF
OPENAI_API_KEY=sk-...
SUPABASE_SERVICE_ROLE_KEY=eyJhb...
EOF
```

**Function liest Env-Vars:**
```typescript
const openaiKey = Deno.env.get("OPENAI_API_KEY");
if (!openaiKey) {
  throw new Error("OPENAI_API_KEY not set");
}
```

**Supabase CLI lädt `.env.local` automatisch** (beim `supabase functions serve`).

---

## Step 3: Function testen (curl/Postman)

### 3.1 Basis-Test (anon-key)

```bash
# POST-Request mit anon-key
curl -X POST http://localhost:54321/functions/v1/<function-name> \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Test prompt"}'

# Erwartung: 200 OK + {"result": "Echo: Test prompt"}
```

**Falls 401 Unauthorized:**
- Anon-key falsch (siehe `supabase start` Output)
- Function erwartet auth-user (JWT mit user_id)

### 3.2 Auth-Test (mit User-JWT)

```bash
# Test-User erstellen (Supabase Studio → Auth → Users → Create User)
# Oder via CLI:
supabase auth signup --email test@example.com --password testpass123

# JWT holen (nach signup automatisch in Response)
# Oder via Dashboard: Users → ... → Copy JWT

# Request mit JWT
curl -X POST http://localhost:54321/functions/v1/<function-name> \
  -H "Authorization: Bearer <user-jwt>" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Auth test"}'

# In Function: User-ID extrahieren
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!,
  { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
);

const { data: { user }, error } = await supabase.auth.getUser();
if (error || !user) {
  return new Response("Unauthorized", { status: 401 });
}

console.log("User ID:", user.id);
```

### 3.3 Error-Handling Test

```bash
# Invalid JSON
curl -X POST http://localhost:54321/functions/v1/<function-name> \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d 'invalid-json'

# Erwartung: 400 Bad Request + {"error": "..."}

# Missing Field
curl -X POST http://localhost:54321/functions/v1/<function-name> \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{}'

# Erwartung: 400 + {"error": "prompt is required"}
```

---

## Step 4: DB-Zugriff testen (RLS-konform)

### 4.1 Function liest DB (anon-key → RLS aktiv)

```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
  );

  // RLS-Check: User kann nur eigene Daten sehen
  const { data, error } = await supabase
    .from("cycle_logs")
    .select("*");

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 });
  }

  return new Response(JSON.stringify({ data }), { status: 200 });
});
```

**Test:**
```bash
# Mit User-JWT (sollte nur eigene cycle_logs zeigen)
curl -X POST http://localhost:54321/functions/v1/<function-name> \
  -H "Authorization: Bearer <user-jwt>" \
  -H "Content-Type: application/json"

# Erwartung: {"data": [{"id": "...", "user_id": "<user-id>", ...}]}
```

### 4.2 Function schreibt DB (service_role → RLS-Bypass, ABER nur server-side!)

```typescript
// ⚠️ NUR in Edge Function erlaubt, NIEMALS im Client!
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, // Bypass RLS
);

// Beispiel: Admin-Operation (z.B. Audit-Log schreiben)
const { error } = await supabase
  .from("audit_logs")
  .insert({ action: "ai_request", user_id: user.id });
```

**Regel:** Service-Role nur für:
- Audit-Logs (schreiben ohne User-Context)
- Admin-Operationen (z.B. Batch-Updates)
- **NIEMALS** für User-Daten-Zugriff (nutze anon-key + JWT)

---

## Step 5: Logs & Debugging

### 5.1 Function-Logs anzeigen

```bash
# Terminal 1: Function serven
supabase functions serve <function-name>

# Terminal 2: Logs live sehen (automatisch)
# Logs erscheinen in Terminal 1

# Logs in Function schreiben:
console.log("Debug:", { user_id: user.id });
console.error("Error:", error);
```

### 5.2 Deno Debugger (VS Code)

**`.vscode/launch.json`:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Edge Function",
      "type": "pwa-node",
      "request": "launch",
      "cwd": "${workspaceFolder}/supabase/functions/<function-name>",
      "runtimeExecutable": "deno",
      "runtimeArgs": ["run", "--inspect-brk", "--allow-all", "index.ts"],
      "attachSimplePort": 9229
    }
  ]
}
```

**Breakpoints setzen** → F5 (Start Debugging) → curl-Request → Breakpoint triggert.

### 5.3 Supabase Studio (lokale DB-Ansicht)

```bash
# Studio öffnen (läuft automatisch bei `supabase start`)
open http://localhost:54323

# → Table Editor: cycle_logs, consent_logs, etc.
# → SQL Editor: Queries ausführen
# → Auth: Users verwalten
```

---

## Step 6: Rate-Limits & Guards testen

### 6.1 Rate-Limit (Edge Function-intern)

**Beispiel: Max 5 Requests/Minute pro User**

```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const rateLimitCache = new Map<string, { count: number; resetAt: number }>();

serve(async (req: Request) => {
  const user = ...; // auth.getUser()

  const now = Date.now();
  const limit = rateLimitCache.get(user.id) || { count: 0, resetAt: now + 60000 };

  if (now > limit.resetAt) {
    limit.count = 0;
    limit.resetAt = now + 60000;
  }

  if (limit.count >= 5) {
    return new Response("Rate limit exceeded", { status: 429 });
  }

  limit.count++;
  rateLimitCache.set(user.id, limit);

  // Business Logic...
});
```

**Test:**
```bash
# 6× Request in 1 Minute
for i in {1..6}; do
  curl -X POST http://localhost:54321/functions/v1/<function-name> \
    -H "Authorization: Bearer <user-jwt>" \
    -H "Content-Type: application/json" \
    -d '{"prompt": "Test"}';
  echo "";
done

# Erwartung:
# Request 1-5: 200 OK
# Request 6: 429 Rate limit exceeded
```

### 6.2 Circuit-Breaker (externe API-Calls)

```typescript
let failureCount = 0;
const CIRCUIT_OPEN_THRESHOLD = 3;

async function callExternalAPI(prompt: string) {
  if (failureCount >= CIRCUIT_OPEN_THRESHOLD) {
    throw new Error("Circuit breaker open");
  }

  try {
    const response = await fetch("https://api.openai.com/v1/...", {...});
    failureCount = 0; // Reset on success
    return response;
  } catch (error) {
    failureCount++;
    throw error;
  }
}
```

---

## Step 7: Deployment (Remote)

### 7.1 Deploy zu Supabase (Staging/Production)

```bash
# Alle Functions deployen
supabase functions deploy

# Einzelne Function deployen
supabase functions deploy <function-name>

# Secrets setzen (Production)
supabase secrets set OPENAI_API_KEY=sk-...
```

### 7.2 Remote-Test (Production)

```bash
# Production URL (aus Dashboard: Settings → API → URL)
curl -X POST https://<project>.supabase.co/functions/v1/<function-name> \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Production test"}'
```

### 7.3 Logs (Production)

```bash
# Supabase Dashboard → Functions → <function-name> → Logs
# ODER via CLI:
supabase functions logs <function-name>
```

---

## Checkliste (Copy-Paste für PR-Kommentar)

```markdown
## Edge Function Test ✅

- [ ] **Step 1:** Function Code reviewed (`supabase/functions/<name>/index.ts`)
- [ ] **Step 2:** Lokal gestartet (`supabase functions serve <name>`)
- [ ] **Step 3.1:** Anon-key Test → 200 OK
- [ ] **Step 3.2:** Auth-JWT Test → 200 OK + user_id extrahiert
- [ ] **Step 3.3:** Error-Handling → 400/401 korrekt
- [ ] **Step 4.1:** DB-Read (anon-key) → RLS aktiv (nur eigene Daten)
- [ ] **Step 4.2:** Service-Role (falls nötig) → nur server-side, dokumentiert
- [ ] **Step 5:** Logs sauber (kein PII in Logs!)
- [ ] **Step 6.1:** Rate-Limit getestet → 429 nach Threshold
- [ ] **Step 6.2:** Circuit-Breaker (falls externe API) → getestet
- [ ] **Step 7:** Deployed + Remote-Test → 200 OK

**Evidence:**
[curl-Output, Screenshots hier einfügen]
```

---

## Häufige Fehler & Fixes

### "Cannot find module"
**Symptom:** `error: Module not found "https://esm.sh/..."`

**Fix:**
```typescript
// Deno Cache leeren
deno cache --reload supabase/functions/<name>/index.ts
```

### "OPENAI_API_KEY not set"
**Symptom:** Function wirft Error bei API-Call

**Fix:**
```bash
# .env.local prüfen
cat supabase/.env.local

# Falls leer → Key hinzufügen
echo "OPENAI_API_KEY=sk-..." >> supabase/.env.local

# Function neu starten
supabase functions serve <name>
```

### "RLS policy violation"
**Symptom:** Function kann nicht in DB schreiben (400/403)

**Fix:**
- Prüfe: Nutzt Function `anon-key` + User-JWT? (RLS aktiv)
- Oder: Nutzt Function `service_role`? (RLS-Bypass, nur für Admin-Ops!)
- Siehe: `docs/runbooks/debug-rls-policy.md`

---

## Weiterführende Links

- **Supabase Edge Functions Docs:** https://supabase.com/docs/guides/functions
- **Deno Docs:** https://deno.land/manual
- **ADR-0003 (MIWF):** `context/ADR/0003-dev-tactics-miwf.md`
- **BMAD-Template (Edge Function):** `context/templates/bmad-template.md#architektur`

---

## Changelog

**v1.0 (2025-10-03):**
- Initial Runbook (7 Steps: Create → Serve → Test → DB → Logs → Guards → Deploy)
- Aligned mit ADR-0002 (RLS), MIWF, DoD
