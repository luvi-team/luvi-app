import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsentService {
  Future<void> accept({
    required String version,
    required List<String> scopes,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'log_consent',
      body: {'version': version, 'scopes': scopes},
    );

    if (response.status != 200) {
      throw Exception('Failed to log consent: ${response.status}');
    }
  }
}

/// Riverpod provider for [ConsentService] to support DI and testability.
final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService();
});
