import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _sb;
  AuthRepository(this._sb);

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _sb.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    await _sb.auth.signUp(email: email, password: password, data: data);
  }

  Future<void> signOut() => _sb.auth.signOut();

  Session? get currentSession => _sb.auth.currentSession;

  Stream<AuthState> authStateChanges() => _sb.auth.onAuthStateChange;
}
