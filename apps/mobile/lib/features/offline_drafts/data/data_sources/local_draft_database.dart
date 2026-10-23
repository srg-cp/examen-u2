import 'package:drift/drift.dart';

/// Schema 1: atomic payload (including evidence bytes) within private app storage.
/// No file references to the image picker's temporary directory survive here.
class LocalDraftDatabase extends GeneratedDatabase {
  LocalDraftDatabase(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      await customStatement('''CREATE TABLE report_drafts (
      owner TEXT NOT NULL, slot TEXT NOT NULL, id TEXT NOT NULL,
      payload TEXT NOT NULL, PRIMARY KEY(owner, slot)
    )''');
    },
  );

  Future<String?> readPayload(String owner, String slot) async {
    final row = await customSelect(
      'SELECT payload FROM report_drafts WHERE owner = ? AND slot = ?',
      variables: [Variable(owner), Variable(slot)],
    ).getSingleOrNull();
    return row?.read<String>('payload');
  }

  Future<List<String>> listPayloads(String owner) async => (await customSelect(
    'SELECT payload FROM report_drafts WHERE owner = ? ORDER BY slot',
    variables: [Variable(owner)],
  ).get()).map((row) => row.read<String>('payload')).toList();

  Future<void> put(
    String owner,
    String slot,
    String id,
    String payload,
  ) => customStatement(
    '''INSERT INTO report_drafts (owner, slot, id, payload) VALUES (?, ?, ?, ?)
       ON CONFLICT(owner, slot) DO UPDATE SET id = excluded.id, payload = excluded.payload''',
    [owner, slot, id, payload],
  );
  Future<void> remove(String owner, String slot, String id) => customStatement(
    'DELETE FROM report_drafts WHERE owner = ? AND slot = ? AND id = ?',
    [owner, slot, id],
  );
}
