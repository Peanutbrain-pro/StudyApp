import 'package:drift/drift.dart';
import 'package:studyapp/data/database/app_database.dart';

class NoteRepository {
  final AppDatabase _db;

  NoteRepository({required AppDatabase db}) : _db = db;

  // Future<Note?> getNotes(int indexId, int notebookId) async {
  //   final note = await _db.managers.notes.filter((f) => f.notebookId.id(notebookId)).getSingleOrNull();
  //   return note;
  // }
  //
  // Future<void> saveNote({required int notebookId, required String markdown}) async {
  //   final existing = await _db.managers.notes.filter((f) => f.notebookId.id(notebookId)).getSingleOrNull();
  //   if (existing != null) {
  //     await _db.managers.notes
  //         .filter((f) => f.notebookId.id(notebookId))
  //         .update((o) => o(data: Value(markdown)));
  //   } else {
  //     await _db.into(_db.notes).insert(NotesCompanion.insert(notebookId: notebookId, data: markdown));
  //   }
  // }
}
