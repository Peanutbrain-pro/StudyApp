import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:studyapp/data/database/app_database.dart';

class UiPreferencesRepository {
  final AppDatabase _db;

  UiPreferencesRepository({required AppDatabase db}) : _db = db;

  Future<void> saveColumnWidths(int notebookId, List<double> columnWidths) async {
    final row = await (_db.select(
      _db.uiPreferences,
    )..where((row) => row.notebookId.equals(notebookId))).getSingleOrNull();

    final Map<String, List<double>> preference = {'Index': columnWidths};

    final encoded = jsonEncode(preference);
    final updatedData = UiPreferencesCompanion.insert(notebookId: notebookId, preferences: Value(encoded));
    if (row != null) {
      await (_db.update(
        _db.uiPreferences,
      )..where((row) => row.notebookId.equals(notebookId))).write(updatedData);
    } else {
      await _db.into(_db.uiPreferences).insert(updatedData);
    }
  }

  Future<List<double>?> getColumnWidths(int notebookId, String page) async {
    final preference =
        await (_db.select(_db.uiPreferences)
              ..addColumns([_db.uiPreferences.preferences])
              ..where((row) => row.notebookId.equals(notebookId)))
            .map((row) => row.preferences)
            .getSingleOrNull();

    if (preference == null) {
      return null;
    }
    final Map<String, dynamic> decoded = jsonDecode(preference);
    return decoded.values.first.cast<double>();
  }
}
