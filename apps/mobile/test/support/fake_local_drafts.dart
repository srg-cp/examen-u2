import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/local_report_draft.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/repositories/local_draft_repository.dart';

class FakeLocalDrafts implements LocalDraftRepository {
  final drafts = <(String, String), LocalReportDraft>{};
  bool fail = false;
  @override
  Future<List<LocalReportDraft>> list(String owner) async {
    if (fail) throw const LocalDraftFailure();
    return drafts.values.where((draft) => draft.owner == owner).toList();
  }

  @override
  Future<LocalReportDraft?> read(String owner, String slot) async {
    if (fail) throw const LocalDraftFailure();
    return drafts[(owner, slot)];
  }

  @override
  Future<void> save(LocalReportDraft draft) async {
    if (fail) throw const LocalDraftFailure();
    drafts[(draft.owner, draft.slot)] = draft;
  }

  @override
  Future<void> remove(String owner, String slot, String id) async {
    if (fail) throw const LocalDraftFailure();
    if (drafts[(owner, slot)]?.id == id) drafts.remove((owner, slot));
  }
}
