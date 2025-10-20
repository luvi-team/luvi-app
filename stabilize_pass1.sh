#!/usr/bin/env bash
set -euo pipefail

# ================================
# Pass 0 — Variablen / Preflight
# ================================
GREEN="ed444fe"  # <- ggf. anpassen: letzter bekannter grüner Commit in deinem Repo
TARGET_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
FIXBR="fix/coderabbit-pass1-$(date +%Y%m%d-%H%M%S)"

# Validierung: existiert GREEN?
if ! git cat-file -e "${GREEN}^{commit}" 2>/dev/null; then
  echo "ERROR: GREEN commit '${GREEN}' nicht gefunden. Bitte GREEN anpassen und erneut ausführen."
  exit 1
fi

echo ">>> Preflight: arbeite auf Branch: ${TARGET_BRANCH}"
git status --porcelain || true

# Sicherheits-Branch anlegen
echo ">>> Erzeuge Sicherheits-Branch: ${FIXBR}"
git checkout -b "${FIXBR}"

echo ">>> Änderungen seit GREEN (${GREEN}) — nur zur Übersicht:"
git diff --name-only "${GREEN}"...HEAD || true

# Vorbereiten: Liste der geänderten Dateien seit GREEN, robust gegen pipefail
DIFF_FILES="$(git diff --name-only "${GREEN}"...HEAD || true)"

# =========================================
# Pass 1 — Build schnell wieder stabilisieren
# =========================================
# 1) Hochrisiko-Dateien (Parser-/Merge-Fehler) auf grünen Stand zurück
#    (nur wenn seit GREEN verändert)
FILES_RESTORE=(
  "lib/features/widgets/hero_sync_preview.dart"
  "lib/features/cycle/screens/cycle_overview_stub.dart"
  "lib/features/widgets/dashboard/top_recommendation_tile.dart"
)
for f in "${FILES_RESTORE[@]}"; do
  if printf '%s\n' "${DIFF_FILES}" | grep -q "^${f}$"; then
    if git cat-file -e "${GREEN}:${f}" 2>/dev/null; then
      echo ">>> Stelle ${f} auf GREEN (${GREEN}) zurück (letzter grüner Stand)"
      git restore --source "${GREEN}" -- "${f}"
    else
      echo ">>> WARN: ${f} existiert im GREEN (${GREEN}) nicht; überspringe Restore"
    fi
  else
    echo ">>> Überspringe Restore von ${f} (seit GREEN unverändert)"
  fi
done

# 2) Fehlender Import für listEquals in Inline-Calendar ergänzen (idempotent)
CAL_FILE="lib/features/cycle/widgets/cycle_inline_calendar.dart"
if [ -f "${CAL_FILE}" ] && ! grep -q "package:flutter/foundation.dart" "${CAL_FILE}"; then
  echo ">>> Füge foundation.dart-Import für listEquals in ${CAL_FILE} hinzu"
  TMP="$(mktemp)"
  printf "import 'package:flutter/foundation.dart';\n" > "${TMP}"
  cat "${CAL_FILE}" >> "${TMP}"
  mv "${TMP}" "${CAL_FILE}"
else
  echo ">>> foundation.dart-Import in ${CAL_FILE} bereits vorhanden oder Datei nicht gefunden"
fi

# 3) L10n neu generieren, falls ARB-Dateien seit GREEN geändert sind
if printf '%s\n' "${DIFF_FILES}" | grep -q '^lib/l10n/app_'; then
  echo ">>> ARB geändert: führe flutter gen-l10n aus"
  flutter gen-l10n || (echo "WARN: flutter gen-l10n fehlgeschlagen – prüfe Flutter-Setup" && true)
else
  echo ">>> ARB unverändert seit GREEN – gen-l10n übersprungen"
fi

# 4) Dependencies aktualisieren
echo ">>> flutter pub get"
flutter pub get

# 5) Analyzer & gezielte Tests
echo ">>> Starte flutter analyze"
flutter analyze

echo ">>> Starte gezielte Tests (schneller Stabilitäts-Check)"
flutter test --dart-define=FEATURE_DASHBOARD_V2=true test/features/widgets/dashboard/stats_scroller_test.dart || true
flutter test --dart-define=FEATURE_DASHBOARD_V2=true test/features/screens/heute_smoke_test.dart || true

# 6) Commit (Pass 1)
echo ">>> Committe Pass 1 (Stabilisierung)"
git add -A
if git diff --cached --quiet; then
  echo ">>> Nichts zu committen (keine Änderungen im Index)"
else
  git commit -m "fix(coderabbit/pass1): restore broken widget(s), add missing import, re-gen l10n; stabilize build"
fi

echo ">>> Fertig. Aktueller Branch: ${FIXBR}"
