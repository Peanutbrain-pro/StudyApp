import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:studyapp/data/database/app_database.dart';

class UiPreferencesRepository {
  final AppDatabase _db;

  UiPreferencesRepository({required AppDatabase db}) : _db = db;

  Future<void> saveColumnWidths(int notebookId, String page, List<double> widths) async {
    final existing = await _db.managers.uiPreferences
        .filter((f) => f.notebookId.id(notebookId))
        .getSingleOrNull();

    final preferences = existing?.preferences == null
        ? <String, dynamic>{}
        : jsonDecode(existing!.preferences!) as Map<String, dynamic>;

    preferences[page] = widths;

    final encoded = jsonEncode(preferences);

    if (existing == null) {
      await _db.managers.uiPreferences.create((o) => o(notebookId: notebookId, preferences: Value(encoded)));
    } else {
      await _db.managers.uiPreferences
          .filter((f) => f.notebookId.id(notebookId))
          .update((o) => o(preferences: Value(encoded)));
    }
  }

  Future<List<double>?> getColumnWidths(int notebookId, String page) async {
    final preference = await _db.managers.uiPreferences
        .filter((f) => f.notebookId.id(notebookId))
        .getSingleOrNull();

    final json = preference?.preferences;
    if (json == null) return null;

    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return List<double>.from(decoded[page]);
  }

  Future<void> addColumn(int notebookId) async {
    final preference = await _db.managers.uiPreferences
        .filter((f) => f.notebookId.id(notebookId))
        .map((row) => jsonDecode(row.preferences ?? "[]") as Map<String, dynamic>)
        .getSingle();
    preference['Index'].add(100.0);

    await _db.managers.uiPreferences
        .filter((f) => f.notebookId.id(notebookId))
        .update((o) => o(preferences: Value(jsonEncode(preference))));
  }
}
