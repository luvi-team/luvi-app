// ignore_for_file: constant_identifier_names
/// Canonical consent scopes and required-set used across the app.
///
/// Diese Enum muss exakt zu `config/consent_scopes.json` passen
/// (IDs + `required`). Änderungen immer zuerst in der JSON-Datei
/// durchführen und anschließend diesen Code + Tests aktualisieren.
/// This file provides a single source of truth to avoid drift between
/// config, state, and UI when determining which consents are mandatory.
enum ConsentScope {
  terms,
  health_processing,
  ai_journal,
  analytics,
  marketing,
  model_training,
}

/// Required consent scopes. Keep this list minimal and legally necessary only.
/// Update tests and server enforcement in lock-step with any changes here.
const Set<ConsentScope> kRequiredConsentScopes = <ConsentScope>{
  ConsentScope.terms,
  ConsentScope.health_processing,
};

/// Visible optional scopes in MVP UI.
/// DSGVO: "Alles akzeptieren" darf NUR diese Scopes setzen, nicht versteckte!
/// Andere optionale Scopes (ai_journal, marketing, model_training) werden
/// erst in zukünftigen Versionen im UI angezeigt.
const Set<ConsentScope> kVisibleOptionalScopes = <ConsentScope>{
  ConsentScope.analytics,
};
