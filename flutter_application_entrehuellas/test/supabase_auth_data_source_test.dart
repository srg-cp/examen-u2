import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/supabase_auth_data_source.dart';

void main() {
  late SupabaseClient client;

  setUp(() {
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
    );
  });
  tearDown(() => client.dispose());

  test('Adapter emits signed out when the SDK has no session', () async {
    expect(await SupabaseAuthDataSource(client).watchSession().first, isNull);
  });

  test(
    'Adapter projects restored SDK identity and subsequent auth events',
    () async {
      final source = SupabaseAuthDataSource(client);
      final nextIdentity = source
          .watchSession()
          .where((dto) => dto != null)
          .first;
      // Local SDK state only: this does not authenticate or call the backend.
      await client.auth.setInitialSession(
        jsonEncode({
          'access_token': 'fake-access-token',
          'refresh_token': 'fake-refresh-token',
          'token_type': 'bearer',
          'user': {
            'id': 'user-1',
            'aud': 'authenticated',
            'app_metadata': <String, Object?>{},
            'user_metadata': <String, Object?>{},
            'created_at': '2026-10-07T00:00:00Z',
          },
        }),
      );
      expect((await nextIdentity)?.userId, 'user-1');
      expect((await source.watchSession().first)?.userId, 'user-1');
    },
  );
}
