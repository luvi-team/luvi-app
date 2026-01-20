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
| `git checkout:*` | 🟡 | Branch wechseln | "Wechsel zu main" |
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

### 7. Scripts (3 Permissions)

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `./scripts/flutter_codex.sh:*` | 🟢 | Sandboxed Flutter | /analyze, /test Commands |
| `scripts/flutter_codex.sh:*` | 🟢 | Sandboxed Flutter | /analyze, /test Commands |
| `./scripts/run_dev.sh:*` | 🟡 | Dev-Server starten | "Starte den Dev-Server" |

### 8. Tools (4 Permissions)

| Permission | Risiko | Warum erlaubt? | Typische Nutzung |
|------------|--------|----------------|------------------|
| `xcrun simctl:*` | 🟢 | iOS Simulator | "Starte den Simulator" |
| `actionlint:*` | 🟢 | GitHub Actions Lint | "Check die Actions" |
| `ruby -ryaml -e:*` | 🟢 | YAML-Verarbeitung | Internes Tooling |
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

---

## Wildcard-Semantik

> **Wichtig:** Wildcards wie `git push:*` erlauben Subkommandos und Argumente.
>
> ⚠️ **Claude Code blockiert KEINE destruktiven Flags automatisch.**
>
> Schutz erfolgt NUR durch:
> 1. Explizite Einträge in "NICHT erlaubte Befehle"
> 2. Manuell konfigurierte Safety-Hooks
>
> **Nicht abgedeckt durch Wildcard-Blocking:**
> - (Entfernt: `bash -c:*`, `python3:*`, `source:*` sind aus Sicherheitsgründen deaktiviert)
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
| Tools | 4 |
| **Basis-Gesamt** | **68** |

> **Hinweis:** Claude Code fügt automatisch neue Permissions hinzu, wenn du sie während einer Session genehmigst (z.B. WebFetch, WebSearch). Diese werden hier nicht dokumentiert, da sie session-spezifisch sind.

---

*Letzte Aktualisierung: 2026-01-19*
*Bereinigt von: Claude Code*
