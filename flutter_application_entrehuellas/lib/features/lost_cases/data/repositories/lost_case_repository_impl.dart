import '../../domain/entities/lost_case.dart';
import '../../domain/repositories/lost_case_repository.dart';
import '../data_sources/lost_case_data_source.dart';

class LostCaseRepositoryImpl implements LostCaseRepository {
  const LostCaseRepositoryImpl(this._source);
  final LostCaseDataSource _source;
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CaseSourceFailure catch (e) {
      throw CaseFailure(e.kind);
    } on CaseFailure {
      rethrow;
    } catch (_) {
      throw const CaseFailure(CaseFailureKind.unavailable);
    }
  }

  @override
  Future<PublishedLostCase> publish(String owner, LostCaseDraft draft) =>
      _run(() async => (await _source.publish(owner, draft)).toPublished());
  @override
  Future<List<PublishedLostCase>> listMine(String owner) => _run(
    () async => (await _source.listMine(
      owner,
    )).map((dto) => dto.toPublished()).toList(),
  );
  @override
  Future<PublicLostCase?> readPublic(String id) async {
    return _run(() async {
      final dto = await _source.readPublic(id);
      if (dto == null) return null;
      final photos = <CasePhoto>[];
      for (final photo in dto.row['photos'] as List) {
        photos.add(
          CasePhoto(
            id: photo['id'] as String,
            uri: await _source.photoUri(photo['path'] as String),
          ),
        );
      }
      return dto.toPublic(photos);
    });
  }
}
