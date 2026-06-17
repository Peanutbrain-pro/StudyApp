import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:studyapp/data/database/app_database.dart';

// import '../../domain/models/notebook.dart';

class NotebookRepository {
  final String appSaveLocation;
  late Directory _notebooksDirectory;
  final AppDatabase _db;

  NotebookRepository({required AppDatabase db, required this.appSaveLocation}) : _db = db;

  Future<void> initialize() async {
    final directory = Directory(p.join(appSaveLocation, "Notebooks"));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    _notebooksDirectory = directory;
  }

  Future<List<Notebook>> getNotebooks() async {
    final rows = await _db.select(_db.notebooks).get();

    // in case any folder was deleted it will create it back (right now its empty folder)
    for (Notebook row in rows) {
      final Directory notebookDirectory = Directory(p.join(_notebooksDirectory.path, row.id.toString()));
      if (!await notebookDirectory.exists()) {
        await notebookDirectory.create(recursive: true);
      }
    }
    return rows;
  }

  Future<Notebook?> getNotebook(int id) async {
    final notebook = await (_db.select(_db.notebooks)..where((notebook) => notebook.id.equals(id))).getSingleOrNull();
    return notebook;
  }

  Future<Notebook> addNotebook(String name) async {
    // Database
    final newNotebook = NotebooksCompanion.insert(
      name: name,
    );
    final insertedNotebook = await _db.into(_db.notebooks).insertReturning(newNotebook);

    // Folder creation
    final Directory notebook =
        Directory(p.join(_notebooksDirectory.path, insertedNotebook.id.toString()));
    if (!await notebook.exists()) {
      await notebook.create(recursive: true);
    }
    print("Notebook repository updated: Added: ${notebook.path}");

    return insertedNotebook;
  }

  Future<bool> removeNotebook(int id) async {
    // Database
    final deletedNotebook = await (_db.delete(_db.notebooks)..where((t) => t.id.equals(id))).goAndReturn();
    final Directory directoryToDelete =
        Directory(p.join(_notebooksDirectory.path, deletedNotebook.first.id.toString()));

    // Folder deletion
    if (await directoryToDelete.exists()) {
      try {
        await directoryToDelete.delete(recursive: true);
      } catch (e) {
        print("an error occured. Couldn't delete notebook");
        return false;
      }
    } else {
      print("The folder doesn't exist which the user has now requested to delete.");
    }

    return true;
    // return deletedNotebook.first;
  }

  Future<void> renameNotebook(int id, String name) async {
    final updatedNotebook = NotebooksCompanion(id: Value(id), name: Value(name));

    // Database
    await _db.update(_db.notebooks).replace(updatedNotebook);
  }
  
  Future<bool> deleteNotebooksDirectory() async {
    if (await _notebooksDirectory.exists()) {
      print("Deleting the notebooks Directory now");
      try {
        await _notebooksDirectory.delete(recursive: true);
        print("No errors now! Notebooks directory got deleted");
        return true;
      } catch (e) {
        print("An error occured. Trying again after some time");
        return false;
      }
      // await _notebooksDirectory.delete(recursive: true);
    }
    print("The directory doesn't even exist");
    return true;
  }

  Future<void> resetDatabase() async {
    print("Trying to reset the database");
    print("This is the current notebooksdirectory btw : ${_notebooksDirectory.path}");
    await _db.close();

    final dbPath = p.join(appSaveLocation, "data", "appdb.sqlite");
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  }
}
