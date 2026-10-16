import '../../domain/entities/saved_case_mark.dart';
import '../../domain/entities/saved_case_ref.dart';
import '../../domain/failures/saved_case_failure.dart';
import '../../domain/repositories/saved_cases_repository.dart';
import '../data_sources/saved_cases_data_source.dart';
import '../models/saved_case_mark_dto.dart';

class SavedCasesRepositoryImpl implements SavedCasesRepository {
  const SavedCasesRepositoryImpl(this._source);
  final SavedCasesDataSource _source;
  Future<SavedCaseMark> _map(Future<SavedCaseMarkDto> Function() action) async {
    try {
      return (await action()).toEntity();
    } on SavedCaseSourceFailure catch (error) {
      throw SavedCaseFailure(switch (error.kind) {
        SavedCaseSourceIssue.forbidden => SavedCaseFailureKind.forbidden,
        SavedCaseSourceIssue.conflict => SavedCaseFailureKind.conflict,
        SavedCaseSourceIssue.hidden => SavedCaseFailureKind.hidden,
        SavedCaseSourceIssue.unavailable => SavedCaseFailureKind.unavailable,
      });
    } catch (_) {
      throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
    }
  }

  @override
  Future<SavedCaseMark> read(String owner, SavedCaseRef target) =>
      _map(() => _source.read(owner, target.source.name, target.id));
  @override
  Future<SavedCaseMark> setSaved(
    String owner,
    SavedCaseRef target, {
    required bool saved,
    required int expectedVersion,
  }) => _map(
    () => _source.setSaved(
      owner,
      target.source.name,
      target.id,
      saved: saved,
      expectedVersion: expectedVersion,
    ),
  );
}
