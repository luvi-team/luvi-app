<!-- NOTE: This file is maintained in German for local/team use. -->
# Claude Code Permissions - LUVI

> Diese Datei dokumentiert alle vorab genehmigten Befehle in `settings.local.json`.
> Claude kann diese OHNE Nachfrage ausführen.

---

## Vibe-Coder Quick-Reference

| Du sagst... | Funktioniert ohne Nachfrage? | Permission |
|-------------|------------------------------|------------|
| "Führ flutter analyze aus" | ✅ Ja | `flutter analyze:*` |
| "Lauf die Tests" | ✅ Ja | `flutter test:*` |
| "Erstell einen Commit" | ✅ Ja | `git commit:*` |
| "Lösch die Datei" | ❌ Nein | `rm` nicht erlaubt |
| "Starte den iOS Simulator" | ✅ Ja | `xcrun simctl:*` |
| "Such nach TODO im Code" | ✅ Ja | `grep:*` |
| "Zeig mir die Archon Tasks" | ✅ Ja | `mcp__archon__find_tasks` |
| "Hol den Figma Screenshot" | ✅ Ja | `mcp__figma__get_screenshot` |

---

## Permissions nach Kategorie

### 1. Flutter/Dart (9 Permissions)

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `flutter analyze:*` | 🟢 | Code-Qualität prüfen | "Check ob Fehler da sind" |
| `flutter test:*` | 🟢 | Tests ausführen | "Lauf die Tests" |
| `flutter run:*` | 🟢 | App starten | "Starte die App" |
| `flutter clean:*` | 🟢 | Build-Cache leeren | "Clean das Projekt" |
| `flutter pub get:*` | 🟢 | Dependencies installieren | "Hol die Packages" |
| `flutter gen-l10n:*` | 🟢 | Lokalisierung generieren | "Generier L10n" |
| `flutter --version:*` | 🟢 | Version prüfen | "Welche Flutter Version?" |
| `dart --version:*` | 🟢 | Version prüfen | "Welche Dart Version?" |
| `dart run build_runner build:*` | 🟢 | Code-Generierung | "Generier die Freezed Klassen" |

### 2. Git (16 Permissions)

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `git status:*` | 🟢 | Repo-Status anzeigen | "Was ist geändert?" |
| `git diff:*` | 🟢 | Änderungen anzeigen | "Zeig die Diffs" |
| `git log:*` | 🟢 | History anzeigen | "Zeig letzte Commits" |
| `git add:*` | 🟢 | Dateien stagen | "Stage die Änderungen" |
| `git commit:*` | 🟡 | Commits erstellen | "Mach einen Commit" |
| `git branch:*` | 🟢 | Branches verwalten | "Welche Branches gibt es?" |
| `git checkout:*` | 🟡 | Branch wechseln (`--force`/`-f` blockiert) | "Wechsel zu main" |
| `git fetch:*` | 🟢 | Remote holen | "Hol die neuesten Änderungen" |
| `git merge:*` | 🟡 | Branches mergen | "Merge main rein" |
| `git stash:*` | 🟢 | Änderungen zwischenspeichern | "Stash das mal" |
| `git rm:*` | 🟡 | Dateien entfernen | "Entfern die Datei aus Git" |
| `git mv:*` | 🟢 | Dateien umbenennen | "Benenn die Datei um" |
| `git ls-tree:*` | 🟢 | Tree anzeigen | Internes Tooling |
| `git merge-base:*` | 🟢 | Common Ancestor finden | Internes Tooling |
| `git for-each-ref:*` | 🟢 | Refs iterieren | Internes Tooling |
| `git ls-remote:*` | 🟢 | Remote Refs anzeigen | Internes Tooling |

### 3. GitHub CLI (9 Permissions)

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `gh pr create:*` | 🟡 | PR erstellen | "Erstell einen PR" |
| `gh pr view:*` | 🟢 | PR anzeigen | "Zeig den PR" |
| `gh pr list:*` | 🟢 | PRs auflisten | "Welche PRs sind offen?" |
| `gh pr checks:*` | 🟢 | PR Checks anzeigen | "Sind die Checks durch?" |
| `gh issue create:*` | 🟡 | Issue erstellen | "Erstell ein Issue" |
| `gh issue list:*` | 🟢 | Issues auflisten | "Welche Issues gibt es?" |
| `gh issue view:*` | 🟢 | Issue anzeigen | "Zeig Issue #123" |
| `gh run view:*` | 🟢 | Workflow Run anzeigen | "Zeig den CI Run" |
| `gh label:*` | 🟢 | Labels verwalten | Internes Tooling |

### 4. MCP Archon (8 Permissions)

> ⚠️ **Archon MCP Server muss laufen!**

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `mcp__archon__health_check` | 🟢 | Server-Status prüfen | Automatisch |
| `mcp__archon__find_tasks` | 🟢 | Tasks suchen | "Was sind meine Tasks?" |
| `mcp__archon__find_projects` | 🟢 | Projekte suchen | "Zeig die Projekte" |
| `mcp__archon__manage_task` | 🟡 | Tasks verwalten | "Markier Task als done" |
| `mcp__archon__manage_project` | 🟡 | Projekte verwalten | "Erstell ein Projekt" |
| `mcp__archon__rag_search_knowledge_base` | 🟢 | Docs durchsuchen | "Such in der Doku nach X" |
| `mcp__archon__rag_search_code_examples` | 🟢 | Code-Beispiele suchen | "Zeig Beispiele für X" |
| `mcp__archon__rag_get_available_sources` | 🟢 | Quellen auflisten | Internes Tooling |

### 5. MCP Figma (3 Permissions)

> ⚠️ **Figma MCP Server muss laufen!**

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `mcp__figma__get_design_context` | 🟢 | Design-Kontext holen | "Hol den Figma-Kontext" |
| `mcp__figma__get_screenshot` | 🟢 | Screenshot holen | "Hol den Screenshot" |
| `mcp__figma__get_variable_defs` | 🟢 | Variablen holen | "Welche Figma-Variablen?" |

### 6. Shell Utilities (16 Permissions)

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `grep:*` | 🟢 | Text suchen | "Such nach X im Code" |
| `find:*` | 🟢 | Dateien finden | "Find alle .dart Dateien" |
| `ls:*` | 🟢 | Verzeichnis listen | "Was ist im Ordner?" |
| `cat:*` | 🟢 | Datei anzeigen | Internes Tooling |
| `tail:*` | 🟢 | Datei-Ende anzeigen | "Zeig letzte Log-Zeilen" |
| `wc:*` | 🟢 | Zählen | "Wie viele Zeilen?" |
| `tree:*` | 🟢 | Verzeichnisbaum | "Zeig die Struktur" |
| `mkdir:*` | 🟢 | Ordner erstellen | "Erstell den Ordner" |
| `open:*` | 🟢 | Datei öffnen | "Öffne die Datei" |
| `echo:*` | 🟢 | Text ausgeben | Internes Tooling |
| `curl:*` | 🟡 | HTTP Requests | "Hol die URL" |
| `xargs:*` | 🟢 | Pipe-Verarbeitung | Internes Tooling |
| `tee:*` | 🟢 | Output splitten | Internes Tooling |
| `unzip:*` | 🟢 | Archive entpacken | "Entpack das ZIP" |
| `test:*` | 🟢 | Bedingungen prüfen | Internes Tooling |
| `sips:*` | 🟢 | Bild-Verarbeitung | Screenshot-Konvertierung |

> ⚠️ **Sicherheitshinweis zu `curl:*`:** Diese Permission erlaubt beliebige HTTP-Requests.
>
> **Risiken:**
> - Exfiltration von Secrets via POST an Angreifer-Endpoints
> - SSRF (Server-Side Request Forgery) zu internen Services
> - Unbeabsichtigte Änderungen an Produktions-Ressourcen
>
> **Mitigations:**
> - Nur für lokale APIs und bekannte Endpoints nutzen
> - Produktive APIs: Wrapper-Script mit Allowlist erwägen
> - Rate-Limiting und Audit-Logs aktivieren
> - Alternative: Permission entfernen und bei Bedarf einzeln genehmigen

### 7. Scripts (3 Permissions)

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `./scripts/flutter_codex.sh:*` | 🟢 | Sandboxed Flutter | /analyze, /test Commands |
| `scripts/flutter_codex.sh:*` | 🟢 | Sandboxed Flutter | /analyze, /test Commands |
| `./scripts/run_dev.sh:*` | 🟡 | Dev-Server starten | "Starte den Dev-Server" |

### 8. Tools (3 Permissions)

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `xcrun simctl:*` | 🟢 | iOS Simulator | "Starte den Simulator" |
| `actionlint:*` | 🟢 | GitHub Actions Lint | "Check die Actions" |
| `ffprobe:*` | 🟢 | Media-Analyse | Video/Audio-Metadaten |

---

## Risiko-Legende

| Symbol | Bedeutung | Empfehlung |
|--------|-----------|------------|
| 🟢 | Sicher | Keine Bedenken |
| 🟡 | Vorsicht | Claude fragt nicht nach, aber Effekt prüfen |
| 🔴 | Gefährlich | Nur wenn du weißt was du tust |

---

## NICHT erlaubte Befehle (bewusst)

| Befehl | Warum NICHT erlaubt? |
|--------|---------------------|
| `rm` | Dateien löschen ist destruktiv |
| `sudo` | Root-Zugriff ist gefährlich |
| `chmod` | Berechtigungen ändern ist riskant |
| `git push --force` | History-Zerstörung |
| `git reset --hard` | Änderungen unwiderruflich verlieren |
| `git rebase` | History umschreiben ist gefährlich |
| `pkill` | Prozesse beenden ist destruktiv |
| `ruby -ryaml -e:*` | Arbitrary Ruby execution - nutze Python PyYAML stattdessen |

> **Unterschied `rm` vs `git rm`:**
> - `rm` (Shell): Löscht Dateien permanent und unwiderruflich
> - `git rm` (Version Control): Entfernt Dateien aus Git-Tracking, aber:
>   - Änderung ist im Git-History sichtbar
>   - Kann via `git checkout` oder `git revert` rückgängig gemacht werden
> - Daher: `rm` blockiert, `git rm:*` erlaubt

### Explizit blockierte Befehle (deny-Liste)

| Befehl | Warum blockiert? |
|--------|-----------------|
| `git commit --amend` | Verhindert versehentliches History-Rewriting |
| `git push --force` / `-f` | Verhindert Remote-History-Zerstörung |
| `git reset --hard` | Verhindert unwiderruflichen Datenverlust |
| `git checkout --force` / `-f` | Verhindert Force-Checkout mit Datenverlust |

> **Hinweis:** Diese Befehle sind auf Policy-Ebene in `settings.local.json` blockiert.
> Claude kann sie auch auf explizite Anfrage nicht ausführen.
> Falls nötig, muss der Benutzer sie manuell im Terminal ausführen.

---

## Wildcard-Semantik

> **Wichtig:** Wildcards wie `git commit:*` erlauben alle Subkommandos und Argumente.
>
> ### Aktive Wildcards und deren Mitigationen
>
> | Wildcard | Risiko-Flag | Mitigation |
> |----------|-------------|------------|
> | `git commit:*` | `--amend` | **Blockiert via deny-Liste** |
> | `git checkout:*` | `--force`, `-f` | **Blockiert via deny-Liste** |
> | `git merge:*` | `--no-ff` | Akzeptabel für Feature-Branches |
>
> ### Nicht aktivierte Wildcards (Referenz)
>
> | Wildcard | Warum nicht aktiviert? |
> |----------|------------------------|
> | `git push:*` | Zu gefährlich - `--force` würde Remote-History zerstören |
> | `git reset:*` | Zu gefährlich - `--hard` würde lokale Änderungen verlieren |
>
> **Hinweis:** Diese Wildcards sind bewusst NICHT in `settings.local.json` aktiviert.
> Die Deny-Einträge (`git push --force`, `git reset --hard`) dienen als Fallback-Schutz.
>
> ### Bestehender Runtime-Schutz
> - Claude Code's eingebaute Safety-Rules verhindern:
>   - `git push --force` auf main/master
>   - `git reset --hard` ohne explizite Anfrage
> - Pre-commit hooks im Repo können zusätzlich schützen
> - Git History ist auditierbar via `git reflog`
>
> **Empfehlung:** Destruktive Befehle explizit blocken oder gefährliche
> Wildcards entfernen.

---

## Wartungshinweise

1. **Keine session-spezifischen Befehle hinzufügen**
   - Keine Commit-Hashes (z.B. `git show abc123`)
   - Keine Branch-Namen (z.B. `git log feat/xyz..main`)
   - Keine absoluten Pfade zu Features

2. **Bei neuen Permissions:**
   - Diese Datei aktualisieren
   - Risiko-Level dokumentieren
   - Typische Nutzung angeben

3. **MCP-Dependencies:**
   - Archon MCP muss laufen für Task-Management
   - Figma MCP muss laufen für Design-Import

---

## Verifikation und Fehlerbehebung

### Settings-Konsistenz prüfen
1. Vergleiche `settings.local.json` mit dieser Dokumentation
2. Bei Abweichungen: Doku aktualisieren oder JSON anpassen

### MCP Server Healthchecks

| Server | Prüfaufruf |
|--------|------------|
| Archon | `mcp__archon__health_check` |
| Figma | `mcp__figma__get_design_context` |

### Troubleshooting
1. **Server-Logs prüfen:** Check MCP server output in Terminal
2. **Neustart:** Restart MCP services bei Verbindungsproblemen
3. **Permission-Audit:** Vergleiche Zugriffslogs mit dieser Doku

### Permission-Nutzung auditieren
- Claude Code loggt alle Tool-Aufrufe
- Regelmäßig prüfen ob Permissions noch benötigt werden
- Ungenutzte Permissions entfernen

---

## Statistik

| Kategorie | Anzahl |
|-----------|--------|
| Flutter/Dart | 9 |
| Git | 16 |
| GitHub CLI | 9 |
| MCP Archon | 8 |
| MCP Figma | 3 |
| Shell Utilities | 16 |
| Scripts | 3 |
| Tools | 3 |
| **Basis-Gesamt** | **67** |

> **Hinweis:** Claude Code fügt automatisch neue Permissions hinzu, wenn du sie während einer Session genehmigst (z.B. WebFetch, WebSearch). Diese werden hier nicht dokumentiert, da sie session-spezifisch sind.

---

*Letzte Aktualisierung: 2026-01-23*
*Bereinigt von: Claude Code*
