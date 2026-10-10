import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/lost_case.dart';
import '../models/lost_case_dto.dart';
import 'lost_case_data_source.dart';

class SupabaseLostCaseDataSource implements LostCaseDataSource {
  const SupabaseLostCaseDataSource(this._client);
  final SupabaseClient _client;
  void _identity(String owner) {
    if (_client.auth.currentUser?.id != owner) {
      throw const CaseSourceFailure(CaseFailureKind.forbidden);
    }
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CaseSourceFailure {
      rethrow;
    } on PostgrestException catch (e) {
      throw CaseSourceFailure(switch (e.message) {
        'case_already_active' => CaseFailureKind.activeCase,
        'case_photos_unverified' => CaseFailureKind.photosUnverified,
        'case_pet_incomplete' => CaseFailureKind.incompletePet,
        _ => switch (e.code) {
          '42501' => CaseFailureKind.forbidden,
          '40001' => CaseFailureKind.conflict,
          '23514' => CaseFailureKind.invalid,
          '23505' => CaseFailureKind.conflict,
          _ => CaseFailureKind.unavailable,
        },
      });
    } catch (_) {
      throw const CaseSourceFailure(CaseFailureKind.unavailable);
    }
  }

  @override
  Future<LostCaseDto> publish(String owner, LostCaseDraft draft) =>
      _run(() async {
        _identity(owner);
        final rows = await _client.rpc(
          'publish_lost_case',
          params: {
            'p_id': draft.id,
            'p_pet_id': draft.petId,
            'p_pet_version': draft.petVersion,
            'p_occurred_at': draft.occurredAt.toUtc().toIso8601String(),
            'p_latitude': draft.latitude,
            'p_longitude': draft.longitude,
            'p_place_reference': draft.placeReference.trim(),
            'p_photo_ids': draft.photoIds,
          },
        );
        _identity(owner);
        return LostCaseDto(
          Map<String, dynamic>.from((rows as List).single as Map),
        );
      });
  @override
  Future<LostCaseDto?> readPublic(String id) => _run(() async {
    final rows =
        await _client.rpc('read_public_lost_case', params: {'p_id': id})
            as List;
    return rows.isEmpty
        ? null
        : LostCaseDto(Map<String, dynamic>.from(rows.single as Map));
  });
  @override
  Future<List<LostCaseDto>> listMine(String owner) => _run(() async {
    _identity(owner);
    final rows = await _client
        .from('lost_cases')
        .select('id,owner_id,pet_id,status,pet_name')
        .eq('owner_id', owner)
        .order('created_at', ascending: false);
    _identity(owner);
    return rows.map(LostCaseDto.new).toList();
  });
  @override
  Future<Uri?> photoUri(String path) async {
    try {
      return Uri.parse(
        await _client.storage
            .from('pet-photo-renditions')
            .createSignedUrl(path, 300),
      );
    } catch (_) {
      return null;
    }
  }
}
