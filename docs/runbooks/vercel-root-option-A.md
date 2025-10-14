# Was ist Option A
Root-Verzeichnis bleibt `/`, Funktionen liegen unter `/api`, `vercel.json` nutzt Pfade wie `api/health.ts` und `api/ai/**`.

# So stellst du es im Dashboard ein
Vercel → Project → Settings → General → Root Directory auf `/` setzen, speichern und anschließend einen Redeploy anstoßen.

# Fehlerbilder & Fix
Falls das Log `api/api/**` meldet, war das Root fälschlich auf `api/` gestellt; auf `/` ändern und erneut deployen.

