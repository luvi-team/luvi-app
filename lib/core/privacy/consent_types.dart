// ignore_for_file: constant_identifier_names
/// Canonical consent scopes and required-set used across the app.
///
/// This enum must match `config/consent_scopes.json` exactly (IDs + `required`).
/// Always make changes in the JSON file first, then update this code + tests.
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
/// GDPR: "Accept all" must ONLY set these visible scopes, not hidden ones!
/// Other optional scopes (ai_journal, marketing, model_training) will only
/// be shown in future UI versions.
const Set<ConsentScope> kVisibleOptionalScopes = <ConsentScope>{
  ConsentScope.analytics,
};
