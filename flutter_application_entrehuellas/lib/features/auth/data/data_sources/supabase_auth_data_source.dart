import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_session_dto.dart';
import 'auth_remote_data_source.dart';

final class SupabaseAuthDataSource implements AuthRemoteDataSource {
  SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthSessionDto?> watchSession() async* {
    yield _projectSession(_client.auth.currentSession);
    yield* _client.auth.onAuthStateChange.map(
      (event) => _projectSession(event.session),
    );
  }

  AuthSessionDto? _projectSession(Session? session) =>
      session == null ? null : AuthSessionDto(userId: session.user.id);
}
