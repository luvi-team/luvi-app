# BMAD Global — Claude Code Edition

> Kondensierte Version für UI/Frontend-Tasks. Vollversion: `docs/bmad/global.md`

---

## 1. Was ist LUVI?

**Women-first Health & Longevity Companion** (Flutter/Dart, Supabase EU)

| Prinzip | Bedeutung |
|---------|-----------|
| Privacy First | EU-Only, DSGVO-first, keine Gesundheitsdaten in Push |
| Lifestyle-first | Kein Medizinprodukt, keine Diagnosen |
| Ultra-Personalisierung | Zyklus, Ziele, Equipment → individuelle Empfehlungen |

---

## 2. Screens (MVP)

```
│  HOME   │  │ ZYKLUS  │  │  COACH  │  │  BRAIN  │  │ PROFIL  │
```

| Screen | Hauptelemente |
|--------|---------------|
| Home | Daily Mindset Card, Smart Hero Card (Training) |
| Zyklus | Kalender, Phasen-Anzeige |
| Coach | Wochenübersicht, Progression-Diagramme |
| Brain | Content-Bibliothek, Suche |
| Profil | Account, Datenschutz |

---

## 3. Code-Standards (mit Beispielen)

### Design Tokens ✅

```dart
// ✅ RICHTIG
Container(
  color: DsColors.primary,
  padding: EdgeInsets.all(Spacing.m),
)

// ❌ FALSCH
Container(
  color: Color(0xFF6B4EFF),
  padding: EdgeInsets.all(16),
)
```

### L10n ✅

```dart
// ✅ RICHTIG
Text(AppLocalizations.of(context)!.welcomeTitle)

// ❌ FALSCH
Text('Willkommen')
```

### Navigation ✅

```dart
// ✅ RICHTIG
context.goNamed(RouteNames.home);

// ❌ FALSCH
Navigator.push(context, MaterialPageRoute(...));
```

### A11y ✅

```dart
// ✅ RICHTIG
Semantics(
  label: AppLocalizations.of(context)!.startWorkout,
  child: SizedBox(
    width: Sizes.touchTargetMin,  // 44dp
    height: Sizes.touchTargetMin,
    child: IconButton(...),
  ),
)
```

---

## 4. Kritische ADRs

| ADR | Regel | Für Claude Code relevant? |
|-----|-------|---------------------------|
| ADR-0002 | Kein `service_role` im Client | ⚠️ Ja |
| ADR-0003 | MIWF: Happy Path zuerst | ✅ Ja |
| ADR-0005 | Push: Keine Gesundheitsdaten | ⚠️ Awareness |
| ADR-0007 | Spacing: 24px statt 28px | ✅ Ja |
| ADR-0008 | Splash Gate Orchestration | ✅ Ja |

---

## 5. UI Definition of Done

### MUST (Pflicht)
- [ ] `flutter analyze` grün
- [ ] ≥1 Widget-Test mit `buildTestApp`
- [ ] Design Tokens (keine hardcoded Colors/Spacing)
- [ ] L10n Keys in `app_de.arb` + `app_en.arb`
- [ ] `Semantics` für interaktive Elemente
- [ ] Touch-Targets ≥44dp

### SHOULD (Empfohlen)
- [ ] Loading/Error/Empty States
- [ ] Greptile Review grün

---

## 6. Quick Links

| Was | Wo |
|-----|-----|
| Vollständiges BMAD | `docs/bmad/global.md` |
| UI Checklist | `docs/engineering/checklists/ui_claude_code.md` |
| Gold-Standard Workflow | `docs/engineering/field-guides/gold-standard-workflow.md` |
| Acceptance | `context/agents/_acceptance_v1.1.md` |
| Tech-Stack SSOT | `context/refs/tech_stack_current.yaml` |
