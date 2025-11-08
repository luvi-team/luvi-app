/// Marker exception for Supabase initialization failures.
///
/// Thrown by supabase_service and supabase_init_controller when initialization
/// fails. Tests can detect this exception type instead of fragile string matching.
class SupabaseInitException implements Exception {
  final String message;
  final Object? originalError;

  SupabaseInitException(this.message, {this.originalError});

  @override
  String toString() => 'SupabaseInitException: $message';
}
