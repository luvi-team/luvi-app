---
name: widget-test
description: Erstellt Widget-Tests für neue Screens/Komponenten. Auto-invoke bei: "Test erstellen", "Widget Test", neuer Screen implementiert.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# Widget Test Skill

## Bei neuem Screen/Widget:

1. **Test-Datei erstellen** unter `test/features/{feature}/`
2. **buildTestApp nutzen** aus `test/support/test_app.dart`
3. **Lokalisierung laden** mit `AppLocalizations.delegate`
4. **Semantics prüfen** mit `tester.ensureSemantics()`

## Test ausführen:
```bash
scripts/flutter_codex.sh test test/features/{feature}/{test_file}.dart
```

## Wichtige Patterns:

### buildTestApp (aus test/support/test_app.dart)
```dart
await tester.pumpWidget(
  buildTestApp(child: const MyScreen()),
);
await tester.pumpAndSettle();
```

### Semantics prüfen
```dart
final handle = tester.ensureSemantics();
// ... test
handle.dispose();
```

### Finder
```dart
find.byType(MyWidget)
find.text('Expected Text')
find.bySemanticsLabel('Semantic Label')
```

## Alle Tests ausführen:
```bash
scripts/flutter_codex.sh test -j 1
```
