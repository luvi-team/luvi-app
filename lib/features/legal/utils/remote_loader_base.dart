import 'dart:async';

/// Platform-agnostic API to fetch remote Markdown content.
/// 
/// Platform implementations:
/// - IO: See `remote_loader_io.dart`
/// - Web: See `remote_loader_web.dart`
/// 
/// Returns the Markdown content as a String, or null if:
/// - The fetch fails (network error, timeout, etc.)
/// - The platform implementation is missing
/// 
/// Platform implementations should:
/// - Respect the [timeout] duration
/// - Return null on any error (do not throw)
/// - Handle all HTTP status codes appropriately
/// 
/// Implemented by conditional imports for IO and Web.
Future<String?> fetchRemoteMarkdown(Uri uri, {Duration timeout = const Duration(seconds: 5)}) async {
  // Base stub to satisfy analyzer if a platform implementation is missing.
  // Real implementations are provided by conditional imports.
  return null;
}

