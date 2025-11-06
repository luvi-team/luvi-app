# ADR: Legal Front-Matter Schema (Autoritativ)

Dieses Dokument definiert das verbindliche YAML‑Front‑Matter‑Schema für alle rechtlich relevanten Markdown‑Dokumente unter `docs/privacy/*.md`. Die CI validiert exakt gegen diese Spezifikation.

## Schema
- required fields:
  - `version` (string)
    - Format: SemVer‑artig; Regex: `^v?\d+\.\d+(?:\.\d+)?(?:-[0-9A-Za-z.-]+)?$`
    - Beispiele: `1.0`, `v1.2.3`, `1.2.0-beta.1`
  - `date` (string)
    - Format: ISO‑Datum `YYYY-MM-DD` (z. B. `2025-11-06`)
  - `title` (string)
    - Nicht‑leer; Klartext‑Titel des Dokuments
  - `author` (string)
    - Nicht‑leer; verantwortliche Person/Rolle oder Team
- optional fields:
  - `draft` (boolean)
    - Standard: `false`; `true` kennzeichnet unveröffentlichte/prüfende Versionen

## Platzierung
- Der YAML‑Block steht am Anfang der Datei, eingerahmt von `---` (Start) und `---` (Ende), gefolgt von einer Leerzeile und dem Markdown‑Inhalt.

## Validierung (CI‑Regeln)
- `version` muss dem obigen Regex entsprechen und über alle rechtlichen Dateien im Release konsistent sein (oder pro Datei gemäß Produktvorgabe; CI konfiguriert die Vergleichsstrategie).
- `date` muss ein gültiges ISO‑Datum sein und darf nicht in der Zukunft liegen (UTC).
- `draft: true` ist in Release‑Builds nicht erlaubt; in PR‑Previews erlaubt.
- Der CI‑Check gleicht `version` zusätzlich mit `SENTRY_RELEASE`/Git‑Tag ab, sofern die Release‑Policy dies verlangt.

## Beispiel
```yaml
---
version: "1.2.0"
date: "2025-11-06"
title: "Privacy Policy"
author: "Legal/Compliance Team"
draft: false
---

# Privacy Policy

Inhalt …
```

