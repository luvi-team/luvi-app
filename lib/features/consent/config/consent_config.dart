class ConsentConfig {
  // Single source of truth for consent policy version used across app.
  static const String currentVersion = 'v1.0';

  // Minimal required scopes for consent acceptance.
  // Do not include optional/telemetry scopes here.
  static const List<String> requiredScopes = <String>[
    'terms',
    'privacy',
  ];
}

