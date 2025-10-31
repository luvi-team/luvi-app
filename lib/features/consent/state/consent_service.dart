import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/analytics/analytics.dart';

class ConsentService {
  Future<void> accept({
    required String version,
    required List<String> scopes,
    required Ref ref,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'log_consent',
      body: {'version': version, 'scopes': scopes},
    );

    if (response.status != 200) {
      throw Exception('Failed to log consent: ${response.status}');
    }

    // Fire analytics event only after successful server persistence
    final a = ref.read(analyticsProvider);
    a.track('consent_accepted', {
      'policy_version': version,
      'required_ok': true,
      'scopes_count': scopes.length,
      'scopes': scopes,
    });
  }
}
