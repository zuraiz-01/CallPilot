import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_service.dart';

class AuthRepository {
  AuthRepository(this._service);

  final SupabaseService _service;

  SupabaseClient get _client => _service.client;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
