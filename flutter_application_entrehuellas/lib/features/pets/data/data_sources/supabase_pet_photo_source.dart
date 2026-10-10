import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pet_photo_data_source.dart';
import '../models/pet_photo_dto.dart';

class SupabasePetPhotoSource implements PetPhotoDataSource {
  const SupabasePetPhotoSource(this._client);
  final SupabaseClient _client;
  void _owner(String id) {
    if (_client.auth.currentUser?.id != id) {
      throw const PetPhotoSourceFailure(PetPhotoSourceFailureKind.forbidden);
    }
  }

  Future<T> _run<T>(String owner, Future<T> Function() action) async {
    _owner(owner);
    try {
      final result = await action();
      _owner(owner);
      return result;
    } on PetPhotoSourceFailure {
      rethrow;
    } on PostgrestException catch (e) {
      throw PetPhotoSourceFailure(
        e.code == '42501'
            ? PetPhotoSourceFailureKind.forbidden
            : e.message == 'photo_limit'
            ? PetPhotoSourceFailureKind.limit
            : PetPhotoSourceFailureKind.unavailable,
      );
    } catch (_) {
      throw const PetPhotoSourceFailure(PetPhotoSourceFailureKind.unavailable);
    }
  }

  String _path(String owner, String pet, String id) => '$owner/$pet/$id.jpg';
  Future<PetPhotoDto> _signed(
    Map<String, dynamic> row,
    String owner,
    String pet,
  ) async {
    _owner(owner);
    if (row['owner_id'] != owner || row['pet_id'] != pet) {
      throw const PetPhotoSourceFailure(PetPhotoSourceFailureKind.forbidden);
    }
    Uri? uri;
    if (row['status'] == 'published') {
      final link = await _client.storage
          .from('pet-photos')
          .createSignedUrl(_path(owner, pet, row['id'] as String), 3600);
      final parsed = Uri.parse(link);
      uri = parsed.replace(
        queryParameters: {
          ...parsed.queryParameters,
          'v': '${DateTime.now().microsecondsSinceEpoch}',
        },
      );
    }
    return PetPhotoDto.fromMap(row, uri: uri);
  }

  @override
  Future<List<PetPhotoDto>> list(String owner, String pet) =>
      _run(owner, () async {
        final rows = await _client
            .from('pet_photos')
            .select('id,pet_id,owner_id,status')
            .eq('pet_id', pet)
            .eq('owner_id', owner)
            .order('created_at')
            .order('id');
        final photos = <PetPhotoDto>[];
        for (var row in rows) {
          if (row['status'] == 'pending') {
            _owner(owner);
            try {
              final response = await _client.rpc(
                'publish_pet_photo',
                params: {'p_id': row['id']},
              );
              row = Map<String, dynamic>.from((response as List).single as Map);
            } on PostgrestException catch (e) {
              if (e.code != 'P0002') rethrow;
            }
          }
          photos.add(await _signed(row, owner, pet));
        }
        return photos;
      });
  @override
  Future<PetPhotoDto> upload(
    String owner,
    String pet,
    String id,
    Uint8List bytes,
  ) => _run(owner, () async {
    await _client.rpc(
      'reserve_pet_photo',
      params: {'p_id': id, 'p_pet_id': pet},
    );
    _owner(owner);
    await _client.storage
        .from('pet-photos')
        .uploadBinary(
          _path(owner, pet, id),
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
            cacheControl: '0',
          ),
        );
    _owner(owner);
    final response = await _client.rpc(
      'publish_pet_photo',
      params: {'p_id': id},
    );
    return _signed(
      Map<String, dynamic>.from((response as List).single as Map),
      owner,
      pet,
    );
  });
  @override
  Future<void> remove(String owner, String pet, String id) =>
      _run(owner, () async {
        try {
          await _client.storage.from('pet-photos').remove([
            _path(owner, pet, id),
          ]);
        } on StorageException catch (e) {
          if (e.statusCode != '404') rethrow;
        }
        _owner(owner);
        await _client.rpc('remove_pet_photo', params: {'p_id': id});
      });
}
