Role: Locale Auditor (read-only)

- Delegates: `MaterialApp.router` in `lib/main.dart` registriert:
  - `GlobalMaterialLocalizations.delegate`
  - `GlobalWidgetsLocalizations.delegate`
  - `GlobalCupertinoLocalizations.delegate`
  (Stand: 2025-10-01)
- supportedLocales: explizit gesetzt auf `[Locale('de'), Locale('en')]`; Deutsch ist damit vollständig unterstützt.
- CupertinoDatePicker: nutzt die globalen `CupertinoLocalizations` und zeigt dadurch die deutschen Monatsnamen korrekt an.
