import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:studyapp/data/database/app_database.dart';

class UiPreferences {
  final AppDatabase _db;

  UiPreferences({required AppDatabase db}) : _db = db;

  Future<void> saveColumnWidths(int notebookId, List<double> columnWidths) async {
    final Map<String, List<double>> preference = {'Index': columnWidths};

    final encoded = jsonEncode(preference);
    await _db
        .into(_db.uiPreferences)
        .insert(UiPreferencesCompanion.insert(notebookId: notebookId, preferences: Value(encoded)));
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
    final Map<String, List<double>> decoded = jsonDecode(preference);
    return decoded.values.first;
  }
}
