import 'dart:async';

/// Platform-agnostic API to fetch remote Markdown content.
/// Implemented by conditional imports for IO and Web.
Future<String?> fetchRemoteMarkdown(Uri uri, {Duration timeout = const Duration(seconds: 5)}) async {
  // Base stub to satisfy analyzer if a platform implementation is missing.
  // Real implementations are provided by conditional imports.
  return null;
}

