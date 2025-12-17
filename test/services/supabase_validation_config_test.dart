import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_services/supabase_service.dart';

void main() {
  test('SupabaseValidationConfig defaults enforce cycle_data age bounds (16–120)', () {
    const config = SupabaseValidationConfig();
    expect(config.minAge, 16);
    expect(config.maxAge, 120);
  });
}

