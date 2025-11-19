# Onboarding 02 – Code Layout Audit

## Strukturübersicht
- `lib/features/screens/onboarding_02.dart:49` Scaffold → `SafeArea` → `SingleChildScrollView` → horizontal `Padding` (`Spacing.l`) around a stretch-aligned `Column`.
- `lib/features/screens/onboarding_02.dart:60` First row: left `IconButton` (customized back arrow), right step counter `Text('2/7')` wrapped in `Semantics` label.
- `lib/features/screens/onboarding_02.dart:89` Title `Text` marked as semantic header, centered below header row.
- `lib/features/screens/onboarding_02.dart:101` Instruction `Text` centered; followed by formatted date readout and divider.
- `lib/features/screens/onboarding_02.dart:130` Info callout `Container` with icon + copy in a `Row` inside `Semantics` wrapper.
- `lib/features/screens/onboarding_02.dart:168` Primary CTA `ElevatedButton` (pushes to `/onboarding/03`) sits above the `CupertinoDatePicker` housed in a fixed-height `SizedBox`.

## Abstände rund um Kernelemente (SizedBox/Padding)
- Gesamter Screen: `Padding.symmetric(horizontal: Spacing.l)` (`lib/features/screens/onboarding_02.dart:54`).
- Oberer Screenrand → Header: `SizedBox(height: Spacing.l)` (`lib/features/screens/onboarding_02.dart:58`).
- Header → Titel: `SizedBox(height: Spacing.l)` (`lib/features/screens/onboarding_02.dart:87`).
- Titel → Instruction: `SizedBox(height: Spacing.l * 2)` (`lib/features/screens/onboarding_02.dart:99`).
- Instruction → Datum: `SizedBox(height: Spacing.l)` (`lib/features/screens/onboarding_02.dart:108`).
- Datum → Unterstreichung (Divider): `SizedBox(height: Spacing.s)` (`lib/features/screens/onboarding_02.dart:120`).
- Divider → Callout: `SizedBox(height: Spacing.l)` (`lib/features/screens/onboarding_02.dart:128`).
- Callout Innenabstand: `Container.padding = EdgeInsets.all(Spacing.m)` (`lib/features/screens/onboarding_02.dart:135`).
- Callout Icon → Text: `SizedBox(width: Spacing.s)` (`lib/features/screens/onboarding_02.dart:151`).
- Callout → CTA: `SizedBox(height: Spacing.l * 2)` (`lib/features/screens/onboarding_02.dart:166`).
- CTA → DatePicker: `SizedBox(height: Spacing.l)` (`lib/features/screens/onboarding_02.dart:174`).
- DatePicker Höhe: `SizedBox(height: 200)` (`lib/features/screens/onboarding_02.dart:176`).
- DatePicker → Screenende: `SizedBox(height: Spacing.l)` (`lib/features/screens/onboarding_02.dart:190`).

## Picker-Container & Datumsausgabe
- Eltern-Widget: `SizedBox(height: 200)` um `CupertinoDatePicker` (`lib/features/screens/onboarding_02.dart:176`). Keine explizite Breitenbegrenzung; nutzt Column-`crossAxisAlignment.stretch`.
- Picker-Konfiguration: `CupertinoDatePickerMode.date`, `minimumYear: 1900`, `maximumYear: DateTime.now().year`, initial `_date = DateTime(2002, 5, 5)` (`lib/features/screens/onboarding_02.dart:178`).
- Locale & Monatsanzeige: `_formatDateGerman` liefert manuell eine deutsche Monatsliste (`lib/features/screens/onboarding_02.dart:8`). Anzeigeformat: `'{Tag} {Monat} {Jahr}'`, Beispiel `'5 Mai 2002'` (`lib/features/screens/onboarding_02.dart:23`).
- Semantische Annotation: Datumsausgabe als `Semantics(label: 'Ausgewähltes Datum')` (`lib/features/screens/onboarding_02.dart:110`).

## Navigation
- Back: `IconButton` ruft `context.pop()` auf (`lib/features/screens/onboarding_02.dart:65`). Im Repo existiert das wiederverwendbare `BackButtonCircle` (`lib/features/widgets/back_button.dart:5`), hier jedoch nicht genutzt.
- CTA: `ElevatedButton` triggert `context.push('/onboarding/03')` (`lib/features/screens/onboarding_02.dart:168`). Route `/onboarding/03` ist in `lib/core/navigation/routes.dart` nicht konfiguriert; Routing-Übergang verlässt aktuellen Stack über GoRouter.

## Token-Nutzung & Abweichungen
- Spacing: nutzt ausschließlich `Spacing`-Tokens (`Spacing.l`, `.m`, `.s`) für vertikale und horizontale Abstände (`lib/features/screens/onboarding_02.dart:54-190`).
- Radii: Callout `BorderRadius.circular(Sizes.radiusM)` (`lib/features/screens/onboarding_02.dart:138`). Back-Icon verwendet `CircleBorder()` statt Token.
- Farben: konsequente Nutzung von `colorScheme` (primary, surface, onSurface) (`lib/features/screens/onboarding_02.dart:67-156`); Divider-Transparenz via `OpacityTokens.inactive` (`lib/features/screens/onboarding_02.dart:125`).
- Typografie: alle Texte basieren auf `textTheme` (`headlineMedium`, `bodyMedium`, `bodySmall`) mit `copyWith`. Abweichungen: Datum-Callout-Text erzwingt `fontSize: 14` (`lib/features/screens/onboarding_02.dart:156`), Icon `size: 20` (`lib/features/screens/onboarding_02.dart:149`), Divider `thickness: 1` und Border `width: 1` (Hardcodes).
- CTA-ButtonStyle: keine explizite Anpassung; nutzt Theme-Voreinstellungen.
- Back-Button-Stil: lokal definierter `IconButton` mit `IconButton.styleFrom` & `CircleBorder` statt zentralem Widget; Iconfarbe `colorScheme.onSurface` vs. `BackButtonCircle`-Default `onPrimary`.
