# Flutter Analyze

Führe Flutter-Analyse aus und behebe alle Fehler.

```bash
scripts/flutter_codex.sh analyze
```

## Bei Fehlern:
1. Lies die Fehlermeldung
2. Navigiere zur betroffenen Datei
3. Behebe den Fehler
4. Wiederhole bis keine Fehler mehr

## Häufige Fixes:
- `unused_import` → Import entfernen
- `prefer_const_constructors` → `const` hinzufügen
- `missing_required_param` → Parameter hinzufügen
