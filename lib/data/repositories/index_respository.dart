import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:studyapp/data/database/app_database.dart';

class IndexRepository {
  final AppDatabase _db;

  IndexRepository({required AppDatabase db}) : _db = db;

  Future<List<IndexItem>> getUnits(int notebookId) {
    return _db.managers.indexItems
        .filter((f) => f.notebookId.id(notebookId))
        .orderBy((o) => o.position.asc())
        .get();
  }

  Future<({List<String?> headers, int noOfColumns})> getHeaders(int notebookId) async {
    final headers = await _db.managers.notebooks
        .filter((f) => f.id.equals(notebookId))
        .map(
          (row) => (
            headers: List<String?>.from(jsonDecode(row.headers ?? "[]") as List<dynamic>),
            noOfColumns: row.noOfColumns,
          ),
        )
        .getSingle();

    return headers;
  }

  Future<int> editHeader(int notebookId, int columnIndex, String? title) async {
    var headers = await getHeaders(notebookId);
    headers.headers[columnIndex] = title;

    return _db.managers.notebooks
        .filter((f) => f.id(notebookId))
        .update((o) => o(headers: Value(jsonEncode(headers.headers))));
  }

  Future<int> removeHeader(int notebookId, int columnIndex) async {
    // TODO: removeHeader function
    return Future.value();
  }

  // Stream<List<IndexItem>> watchUnits(int notebookId) {
  //   return _db.managers.indexItems
  //       .filter((f) => f.notebookId.id(notebookId))
  //       .orderBy((o) => o.position.asc())
  //       .watch();
  // }

  Future<IndexItem?> getUnit(int id) {
    return _db.managers.indexItems.filter((f) => f.id(id)).getSingleOrNull();
  }

  Future<int> countUnits(int notebookId) {
    return _db.managers.indexItems.filter((f) => f.notebookId.id(notebookId)).count();
  }

  Future<IndexItem> addUnit(int notebookId, {int position = -1}) async {
    return _db.transaction(() async {
      int newPosition = position;

      if (position == -1) {
        newPosition = await _db.managers.indexItems.filter((f) => f.notebookId.id(notebookId)).count();
      } else {
        // position += 1 for all rows from given position
        await (_db.update(_db.indexItems)
              ..where((t) => t.notebookId.equals(notebookId) & t.position.isBiggerOrEqualValue(position)))
            .write(IndexItemsCompanion.custom(position: _db.indexItems.position + const Constant(1)));
      }

      await _db.managers.indexItems.create((o) => o(notebookId: notebookId, position: newPosition));

      return await _db.managers.indexItems
          .filter((f) => f.notebookId.id(notebookId) & f.position(newPosition))
          .orderBy((o) => o.id.desc())
          .getSingle();
    });
  }

  Future<int> deleteUnit(int id) {
    return _db.managers.indexItems.filter((f) => f.id(id)).delete();
  }

  Future<int> deleteAllItems(int notebookId) {
    return _db.managers.indexItems.filter((f) => f.notebookId.id(notebookId)).delete();
  }

  Future<int> updateUnit(int id, String? data, int columnIndex) async {
    if (columnIndex == 0) {
      return updateTitle(id, data);
    } else if (columnIndex == 1) {
      return updateDescription(id, data);
    } else {
      final rawExtraInfo = await _db.managers.indexItems
          .filter((f) => f.id(id))
          .map((row) => row.extraInfo)
          .getSingle();
      var extraInfo = List<String?>.from(jsonDecode(rawExtraInfo ?? "[]"));
      final index = columnIndex - 2;
      extraInfo[index] = data;
      final encoded = jsonEncode(extraInfo);

      return _db.managers.indexItems.filter((f) => f.id(id)).update((o) => o(extraInfo: Value(encoded)));
    }
  }

  Future<int> updateTitle(int id, String? title) {
    return _db.managers.indexItems
        .filter((f) => f.id(id))
        .update((o) => o(title: Value(title), modifiedAt: Value(DateTime.now())));
  }

  Future<int> updateDescription(int id, String? description) {
    return _db.managers.indexItems
        .filter((f) => f.id(id))
        .update((o) => o(description: Value(description), modifiedAt: Value(DateTime.now())));
  }

  Future<int> updateExtraInfo(int id, List<String?> extra) {
    return _db.managers.indexItems
        .filter((f) => f.id(id))
        .update((o) => o(extraInfo: Value(jsonEncode(extra)), modifiedAt: Value(DateTime.now())));
  }
}
