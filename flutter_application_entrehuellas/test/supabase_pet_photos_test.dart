import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/supabase_pet_photo_source.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/pet_photo_data_source.dart';

void main() {
  for (final denied in [false, true]) {
    test(
      'Private pet JPEG requires reservation, upload, publish and signed read; denied=$denied',
      () async {
        final bytes = img.encodeJpg(img.Image(width: 10, height: 10));
        final calls = <String>[];
        final row = {
          'id': 'photo',
          'pet_id': 'pet',
          'owner_id': 'owner',
          'status': 'published',
        };
        final mock = MockClient((request) async {
          Object? body;
          var status = 200;
          final path = request.url.path;
          if (path == '/auth/v1/token') {
            body = {
              'access_token':
                  'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJvd25lciIsImV4cCI6MjAwMDAwMDAwMH0.fake',
              'refresh_token': 'fake-refresh',
              'token_type': 'bearer',
              'expires_in': 3600,
              'user': {
                'id': 'owner',
                'aud': 'authenticated',
                'app_metadata': {},
                'user_metadata': {},
                'created_at': '2026-10-09T00:00:00Z',
              },
            };
          } else {
            calls.add(path);
            if (path == '/rest/v1/rpc/reserve_pet_photo') {
              expect(jsonDecode(request.body), {
                'p_id': 'photo',
                'p_pet_id': 'pet',
              });
              body = [
                {...row, 'status': 'pending'},
              ];
            } else if (path ==
                '/storage/v1/object/pet-photos/owner/pet/photo.jpg') {
              expect(request.headers['x-upsert'], 'true');
              expect(
                latin1.decode(request.bodyBytes).toLowerCase(),
                contains('content-type: image/jpeg'),
              );
              expect(
                latin1.decode(request.bodyBytes),
                contains(latin1.decode(bytes)),
              );
              body = {'Key': 'pet-photos/owner/pet/photo.jpg'};
            } else if (path == '/rest/v1/rpc/publish_pet_photo') {
              expect(jsonDecode(request.body), {'p_id': 'photo'});
              body = [row];
            } else {
              expect(
                path,
                '/storage/v1/object/sign/pet-photos/owner/pet/photo.jpg',
              );
              status = denied ? 403 : 200;
              body = denied
                  ? {
                      'statusCode': '403',
                      'error': 'Forbidden',
                      'message': 'private detail',
                    }
                  : {
                      'signedURL':
                          '/object/sign/pet-photos/owner/pet/photo.jpg?token=fake',
                    };
            }
          }
          return http.Response(
            jsonEncode(body),
            status,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        });
        final sdk = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: mock,
        );
        addTearDown(() async {
          await sdk.dispose();
          mock.close();
        });
        final source = SupabasePetPhotoSource(sdk);
        await expectLater(
          source.upload('owner', 'pet', 'photo', bytes),
          throwsA(isA<PetPhotoSourceFailure>()),
        );
        expect(calls, isEmpty);
        await sdk.auth.signInWithPassword(
          email: 'test@example.invalid',
          password: 'fake',
        );
        if (denied) {
          await expectLater(
            source.upload('owner', 'pet', 'photo', bytes),
            throwsA(isA<PetPhotoSourceFailure>()),
          );
        } else {
          final photo = await source.upload('owner', 'pet', 'photo', bytes);
          expect(photo.toEntity().ready, true);
          expect(
            photo.toEntity().uri!.path,
            contains('/pet-photos/owner/pet/photo.jpg'),
          );
        }
        expect(calls, [
          '/rest/v1/rpc/reserve_pet_photo',
          '/storage/v1/object/pet-photos/owner/pet/photo.jpg',
          '/rest/v1/rpc/publish_pet_photo',
          '/storage/v1/object/sign/pet-photos/owner/pet/photo.jpg',
        ]);
      },
    );
  }
}
