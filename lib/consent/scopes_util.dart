List<String> normalizeScopes(List<String> scopes) {
  return scopes
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}