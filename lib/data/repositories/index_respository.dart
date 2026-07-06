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

  Future<({({int id, List<String?> data}) unit, int position})> addUnit(int notebookId, {int position = -1}) async {
    int nextPos = position;
    if (position == -1) {
      final rows = await _db.indexItems
          .count(where: (row) => row.notebookId.equals(notebookId))
          .getSingleOrNull();
      nextPos = rows ?? 0;
    } else {
      // Move all the next position rows by +1
      (_db.update(_db.indexItems)..where(
            (item) => item.notebookId.equals(notebookId) & item.position.isBiggerOrEqualValue(position),
          ))
          .write(IndexItemsCompanion.custom(position: _db.indexItems.position + const Variable(1)));
    }

    final addedResult = await _db
        .into(_db.indexItems)
        .insertReturning(IndexItemsCompanion.insert(notebookId: notebookId, position: nextPos));
    final row = indexItemToContent(addedResult);
    return (unit: row, position: nextPos);
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

  Future<int> deleteAllItems(int notebookId) async {
    return (_db.delete(_db.indexItems)..where((row) => row.notebookId.equals(notebookId))).go();
  }
}
