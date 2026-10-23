import '../entities/local_report_draft.dart';
import '../repositories/local_draft_repository.dart';

class ListLocalDrafts {
  const ListLocalDrafts(this.repository);
  final LocalDraftRepository repository;
  Future<List<LocalReportDraft>> call(String owner) {
    if (owner.isEmpty) throw const LocalDraftFailure();
    return repository.list(owner);
  }
}

class ReadLocalDraft {
  const ReadLocalDraft(this.repository);
  final LocalDraftRepository repository;
  Future<LocalReportDraft?> call(String owner, String slot) {
    if (owner.isEmpty || slot.isEmpty) throw const LocalDraftFailure();
    return repository.read(owner, slot);
  }
}

class SaveLocalDraft {
  const SaveLocalDraft(this.repository);
  final LocalDraftRepository repository;
  Future<void> call(LocalReportDraft draft) {
    if (draft.owner.isEmpty || draft.slot.isEmpty || draft.id.isEmpty) {
      throw const LocalDraftFailure();
    }
    return repository.save(draft);
  }
}

class RemoveLocalDraft {
  const RemoveLocalDraft(this.repository);
  final LocalDraftRepository repository;
  Future<void> call(String owner, String slot, String id) =>
      repository.remove(owner, slot, id);
}
