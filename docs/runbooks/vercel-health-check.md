# Vercel Health-Check (Preview & Production)

**Zweck (1–2 Sätze):**  
Kurz erklären: Wir prüfen, ob unser Gateway (Edge Function) live ist. Ziel: 200 OK + JSON von `/api/health`.

---

## TL;DR – Schnelltest

- **Preview (PR):** In GitHub PR → *Vercel — Preview* → **View deployment** → Domain öffnen → **`/api/health`** anhängen.  
  Erwartung: `{"ok": true, "timestamp":"…"}` (HTTP 200)
- **Production:** **https://luvi-app.vercel.app/api/health** → Erwartung: 200 + JSON

---

## Vorab-Prüfungen (müssen stimmen)

- **Code:** `api/health.ts`  
  - `export const config = { runtime: 'edge' }` *(ohne `as const`)*  
  - ESM-Imports mit **`.js`**:  
    `import { buildCorsHeaders } from './utils/cors.js'`  
    `import logger from './utils/logger.js'`
- **TypeScript (`api/tsconfig.json`):**  
  `"module": "NodeNext"`, `"moduleResolution": "nodenext"`, `"target": "ES2022"`, `"lib": ["ES2022","DOM"]`
- **Vercel Config (`vercel.json` im Repo-Root):**  
  `{ "regions": ["fra1"] }` *(keine `functions`, kein `runtime`)*
- **.vercelignore:** darf **`api/` nicht** ausschließen
- **Ablauf:** Erst Preview prüfen → dann Merge → dann Production prüfen

---

## So testest du Preview korrekt

1. GitHub PR öffnen → **Vercel — Preview** → **View deployment** klicken  
2. Es öffnet die **Preview-Domain** (zufällige Subdomain).  
3. In der Adressleiste **`/api/health`** anhängen und öffnen.  
4. Erwartung: HTTP 200 und JSON  
5. **Nie** alte/abgetippte Domains verwenden → immer den Button **„View deployment“**

---

## So testest du Production

- **URL:** `https://luvi-app.vercel.app/api/health`  
- **Erwartung:** HTTP 200 und JSON

---

## Logs & Diagnose (wenn’s nicht 200 ist)

> **Immer erst**: In der Vercel Deployment-Seite prüfen, dass *Source* der **richtige Branch + Commit-SHA** ist.

### 404 Varianten
- **`404 NOT_FOUND` (Root):** Domain ohne Pfad → `/api/health` anhängen.  
- **`404 DEPLOYMENT_NOT_FOUND`:** Veraltete Preview-Domain → im PR **View deployment** nutzen.

### 500 Varianten (häufigste Ursachen & Fixes)
- **`ERR_MODULE_NOT_FOUND` (…/api/utils/cors):**  
  → ESM-Import ohne `.js` → Imports in `api/*` auf `*.js` umstellen.
- **`req.headers.get is not a function`:**  
  → Function läuft als Node, Code nutzt Fetch/Edge → in `api/health.ts`  
    `export const config = { runtime: 'edge' }` setzen (kein `as const`).
- **`Unhandled type: "AsExpression" 'edge' as const`:**  
  → Vercel-Parser stolpert über TS-Assertion → `as const` im `config.runtime` entfernen.
- **„Legacy runtime“-/Pattern-Fehler im Build:**  
  → `vercel.json` auf **regions-only** reduzieren; keine Einträge für nicht existierende Pfade (z. B. `api/ai/**`).

### Wo finde ich die Infos?
- **Build Logs:** Fehlermeldung beim Bauen (z. B. „AsExpression …”).  
- **Runtime Logs:** Fehler beim Ausführen (z. B. `req.headers.get …`).  
- **Resources → Functions:** prüfe, dass `/api/health` als **Edge** gelabelt ist.

---

## Checkliste vor dem Merge (Preview)

- [ ] Preview-Domain über **View deployment** geöffnet  
- [ ] `/api/health` gibt **200 + JSON**  
- [ ] Keine roten Einträge in Build- und Runtime-Logs  
- [ ] Code enthält: `config.runtime='edge'` (ohne `as const`), ESM mit `.js`

---

## Checkliste nach dem Merge (Production)

- [ ] `https://luvi-app.vercel.app/api/health` → **200 + JSON**  
- [ ] Runtime Logs sauber  
- [ ] (Optional) Node LTS in `api/package.json` pinnen → `"engines": { "node": "20.x" }`

---

## Häufige Stolpersteine (Kurzreferenz)

- Alte Preview-Domain → **DEPLOYMENT_NOT_FOUND** → immer **View deployment** nutzen  
- JSON-Runtime in `vercel.json` → Legacy-Fehler → regions-only lassen  
- ESM ohne `.js` → Modul nicht gefunden  
- `as const` in `config.runtime` → Build parser error  
- Node vs Edge → `req.headers.get` crasht → `config.runtime='edge'`

---

Commit
- Commit message: `docs(runbook): add Vercel health-check runbook (Preview & Production)`

Acceptance
- File `docs/runbooks/vercel-health-check.md` exists with the exact structure above.
- Uses concise checklists and includes Preview/Prod steps, log diagnostics, and common error→fix pairs.
- No other files changed.

