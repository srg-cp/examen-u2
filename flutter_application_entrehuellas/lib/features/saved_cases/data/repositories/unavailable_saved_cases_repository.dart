import '../../domain/entities/saved_case_mark.dart';
import '../../domain/entities/saved_case_ref.dart';
import '../../domain/failures/saved_case_failure.dart';
import '../../domain/repositories/saved_cases_repository.dart';

class UnavailableSavedCasesRepository implements SavedCasesRepository {
  const UnavailableSavedCasesRepository();
  @override
  Future<SavedCaseMark> read(String owner, SavedCaseRef target) async =>
      throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
  @override
  Future<SavedCaseMark> setSaved(
    String owner,
    SavedCaseRef target, {
    required bool saved,
    required int expectedVersion,
  }) async => throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
}
