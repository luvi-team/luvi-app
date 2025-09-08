import 'package:supabase_flutter/supabase_flutter.dart';

class ConsentService {
  Future<void> accept({
    required String version,
    required List<String> scopes,
  }) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final response = await supabase.functions.invoke(
      'log_consent',
      body: {
        'user_id': userId,
        'version': version,
        'scopes': scopes,
        'granted': true,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to log consent: ${response.status}');
    }
  }
}
