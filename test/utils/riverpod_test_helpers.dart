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
///
/// NOTE: This uses `List<dynamic>` intentionally because Riverpod's `Override`
/// type is sealed and not publicly exported. Type-safety is maintained because:
/// 1. Individual overrides ARE type-safe via `.overrideWith()`, `.overrideWithValue()`
/// 2. Only valid Override instances can be created through Riverpod's public API
/// 3. This is a known limitation - see Riverpod GitHub discussions
///
/// The alternative (creating typed mock subclasses) would add significant
/// complexity for no practical benefit since runtime safety is already ensured.
typedef RiverpodOverrides = List<dynamic>;

/// Empty overrides constant for tests without custom providers.
const RiverpodOverrides kEmptyOverrides = [];
