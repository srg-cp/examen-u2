import '../../domain/entities/local_report_draft.dart';
import '../../domain/repositories/local_draft_repository.dart';
import '../data_sources/local_draft_database.dart';
import '../models/local_report_draft_dto.dart';

class LocalDraftRepositoryImpl implements LocalDraftRepository {
  LocalDraftRepositoryImpl(this.database);
  final LocalDraftDatabase database;
  Future<void> _tail = Future.value();

  @override
  Future<List<LocalReportDraft>> list(String owner) => _ordered(() async {
    try {
      final drafts = (await database.listPayloads(
        owner,
      )).map(LocalReportDraftDto.decode).toList();
      if (drafts.any((d) => !_owned(d, owner))) throw const LocalDraftFailure();
      return List.unmodifiable(drafts);
    } catch (_) {
      throw const LocalDraftFailure();
    }
  });

  bool _owned(LocalReportDraft d, String owner) =>
      d.owner == owner &&
      (d.pet == null || d.pet!.ownerId == owner) &&
      d.pets.every((p) => p.ownerId == owner) &&
      d.petPhotos.every((p) => p.ownerId == owner);

  // Order edits, receipts and reads even when a widget is disposed mid-write.
  Future<T> _ordered<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  @override
  Future<LocalReportDraft?> read(String owner, String slot) =>
      _ordered(() async {
        try {
          final payload = await database.readPayload(owner, slot);
          if (payload == null) return null;
          final draft = LocalReportDraftDto.decode(payload);
          if (draft.owner != owner ||
              draft.slot != slot ||
              draft.pets.any((p) => p.ownerId != owner) ||
              (draft.pet != null && draft.pet!.ownerId != owner) ||
              draft.petPhotos.any((p) => p.ownerId != owner)) {
            throw const LocalDraftFailure();
          }
          return draft;
        } catch (_) {
          throw const LocalDraftFailure();
        }
      });
  @override
  Future<void> save(LocalReportDraft draft) {
    // Capture bytes now, before the caller edits the next revision.
    final String payload;
    try {
      if (!_owned(draft, draft.owner)) throw const LocalDraftFailure();
      payload = LocalReportDraftDto.encode(draft);
    } catch (_) {
      return Future.error(const LocalDraftFailure());
    }
    return _ordered(() async {
      try {
        await database.put(draft.owner, draft.slot, draft.id, payload);
      } catch (_) {
        throw const LocalDraftFailure();
      }
    });
  }

  @override
  Future<void> remove(String owner, String slot, String id) =>
      _ordered(() async {
        try {
          await database.remove(owner, slot, id);
        } catch (_) {
          throw const LocalDraftFailure();
        }
      });
}
