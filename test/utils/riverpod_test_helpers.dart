/// Riverpod test utilities for type-safe provider overrides.
///
/// Riverpod's Override is a sealed class that is not publicly exported.
/// Using `List<Override>` is not possible because the Override type is sealed
/// and only internal Riverpod methods return it (e.g., provider.overrideWith()).
/// Type-safety is maintained at runtime since only valid Override instances
/// can be created through Riverpod's public API.
///
/// Usage:
/// ```dart
/// Widget buildTestApp({
///   RiverpodOverrides overrides = kEmptyOverrides,
/// }) {
///   return ProviderScope(
///     overrides: [
///       for (final o in overrides) o,
///     ],
///     child: MaterialApp(...),
///   );
/// }
/// ```
// ignore_for_file: always_specify_types
library;

/// Type alias for Riverpod overrides list.
/// Use this when building test apps with ProviderScope.
typedef RiverpodOverrides = List<dynamic>;

/// Empty overrides constant for tests without custom providers.
const RiverpodOverrides kEmptyOverrides = [];
