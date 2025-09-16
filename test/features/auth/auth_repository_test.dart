import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luvi_app/features/data/auth_repository.dart';

class _MockGoTrueClient extends Mock implements GoTrueClient {}
class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late _MockSupabaseClient sb;
  late _MockGoTrueClient auth;

  setUp(() {
    sb = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    // Stub the SupabaseClient.auth getter to return our mocked GoTrueClient
    when(() => sb.auth).thenReturn(auth);
  });

  test('signInWithPassword calls supabase with given credentials', () async {
    when(() => auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => AuthResponse(session: null, user: null));

    final repo = AuthRepository(sb);
    await repo.signInWithPassword(email: 'a@b.c', password: 'pw');

    verify(() => auth.signInWithPassword(
          email: 'a@b.c',
          password: 'pw',
        )).called(1);
  });
}
