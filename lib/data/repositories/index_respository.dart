import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:studyapp/data/database/app_database.dart';

class IndexRepository {
  final AppDatabase _db;

  IndexRepository({required AppDatabase db}) : _db = db;

  ({int id, List<String?> data}) indexItemToContent(IndexItem item) {
    final extra = (item.extraInfo != null) ? jsonDecode(item.extraInfo!) : [];
    final ({int id, List<String?> data}) unit = (id: item.id, data: [item.title, item.description, ...extra]);
    return unit;
  }

  Future<({int id, List<String?> data})> addUnit(int notebookId) async {
    final rows = await _db.indexItems
        .count(where: (row) => row.notebookId.equals(notebookId))
        .getSingleOrNull();
    final nextPos = (rows ?? -1) + 1;

    final addedResult = await _db
        .into(_db.indexItems)
        .insertReturning(IndexItemsCompanion.insert(notebookId: notebookId, position: nextPos));
    final row = indexItemToContent(addedResult);
    return row;
  }

  Future<List<({int id, List<String?> data})>> getUnits(int notebookId) async {
    final rows =
        await (_db.select(_db.indexItems)
              ..where((row) => row.notebookId.equals(notebookId))
              ..orderBy([(row) => .asc(row.position)]))
            .get();
    List<({int id, List<String?> data})> units = [];
    for (var row in rows) {
      units.add(indexItemToContent(row));
    }

    return units;
  }

  Future<void> deleteUnit(int notebookId, int unitId) async {
    // TODO: do it
  }
}
