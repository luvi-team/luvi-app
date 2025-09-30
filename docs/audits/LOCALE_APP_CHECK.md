Role: Locale Auditor (read-only)

- Delegates: `MaterialApp.router` in `lib/main.dart:34` konfiguriert keine `Global*`-Delegates; damit greifen nur die Flutter-Defaults (`DefaultMaterial`, `DefaultWidgets`, `DefaultCupertino`).
- supportedLocales: kein Override vorhanden → Flutter-Default `[Locale('en', 'US')]`; `Locale('de')` fehlt.
- CupertinoDatePicker: Nein. Ohne `GlobalCupertinoLocalizations` + `Locale('de')` bleibt die Datumsausgabe Englisch.
- Optionen:
  - App-level: die drei `Global*Localizations.delegate` ergänzen und `supportedLocales` um `Locale('de')` erweitern.
  - Screen-level: betroffene Views via `Localizations.override` mit den `Global*`-Delegates und `Locale('de')` versehen.
