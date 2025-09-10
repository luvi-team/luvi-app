#!/usr/bin/env bash
# One-shot fixer for CI comments:
# 1) withOpacity -> withValues(alpha: …)
# 2) Unused import (sizes.dart) aus welcome_shell.dart entfernen
# 3) Figma Node-IDs: '-' -> ':' in JSON + Backup
# 4) Button minimumSize: Size(double.infinity, h) -> Size.fromHeight(h)
# Danach: format, analyze (non-fatal), git add/commit

set -u
echo "▶︎ Starting one-shot fix…"

# 1) withOpacity -> withValues(alpha: …)
echo "→ Fix withOpacity deprecation"
sed -i.bak "s/withOpacity(\s*0\.2\s*)/withValues(alpha: 0.2)/g" \
  lib/features/consent/widgets/dots_indicator.dart 2>/dev/null || true

# 2) Unused import sizes.dart entfernen (nur wenn vorhanden)
echo "→ Drop unused import of sizes.dart in welcome_shell.dart (if unused)"
if grep -q "design_tokens/sizes.dart" lib/features/consent/widgets/welcome_shell.dart; then
  # Nur entfernen, wenn Datei keine 'Sizes.'-Nutzung mehr hat
  if ! grep -q "Sizes\." lib/features/consent/widgets/welcome_shell.dart; then
    gsutil=false
    # Entferne exakt die Importzeile
    gsed -i ";/design_tokens\/sizes\.dart/d" lib/features/consent/widgets/welcome_shell.dart 2>/dev/null || \
    sed  -i '' ";/design_tokens\/sizes\.dart/d" lib/features/consent/widgets/welcome_shell.dart 2>/dev/null || true
  fi
fi

# 3) Figma Node IDs: '-' -> ':' in beiden Dateien
echo "→ Normalize Figma node IDs in JSON (hyphen -> colon)"
for f in context/refs/figma_nodes_m4.json context/refs/figma_nodes_m4.backup.json; do
  [ -f "$f" ] || continue
  # Ersetze ausschließlich Ziffern-Bindestrich-Ziffern innerhalb von Strings durch Ziffern:Ziffern
  # Beispiel "67891-12347" -> "67891:12347"
  perl -0777 -pe "s/\"(\d+)-(\d+)\"/\"\$1:\$2\"/g" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

# 4) Button minimumSize fix in Theme
echo "→ Fix minimumSize to Size.fromHeight()"
perl -0777 -pe "s/minimumSize:\s*const\s*Size\(\s*double\.infinity\s*,\s*([A-Za-z0-9_\.]+)\s*\)/minimumSize: Size.fromHeight(\$1)/g" \
  lib/core/theme/app_theme.dart > lib/core/theme/app_theme.dart.tmp && mv lib/core/theme/app_theme.dart.tmp lib/core/theme/app_theme.dart

# Format (non-fatal)
echo "→ dart format"
(command -v dart >/dev/null && dart format .) || true

# Analyze (non-fatal, zeigt verbleibende Warnungen)
echo "→ flutter analyze (non-fatal)"
(command -v flutter >/dev/null && flutter analyze) || true

# Git diff preview
echo "→ Git diff preview:"
git --no-pager diff --staged >/dev/null
git --no-pager diff | sed -n '1,200p'

# Stage & commit
echo "→ git add"
git add -A

echo "→ git commit"
git commit -m "fix(ci): withValues(alpha), remove unused import, normalize Figma node IDs, use Size.fromHeight for buttons" || true

# Optional: push (auskommentiert lassen, falls du erst prüfen willst)
# echo "→ git push"
# git push

echo "✅ Done. Review analyzer output above. If clean, push the commit."
