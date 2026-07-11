import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:studyapp/data/database/app_database.dart';

class NotebookRepository {
  final String appSaveLocation;
  late Directory _notebooksDirectory;
  final AppDatabase _db;

  NotebookRepository({
    required AppDatabase db,
    required this.appSaveLocation,
  }) : _db = db;

  Future<void> initialize() async {
    final directory = Directory(p.join(appSaveLocation, "Notebooks"));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    _notebooksDirectory = directory;
  }

  Future<List<Notebook>> getNotebooks() async {
    final rows = await _db.managers.notebooks.get();

    // Recreate folders if missing
    for (final row in rows) {
      final notebookDirectory = Directory(
        p.join(_notebooksDirectory.path, row.id.toString()),
      );
      if (!await notebookDirectory.exists()) {
        await notebookDirectory.create(recursive: true);
      }
    }
    return rows;
  }

  Future<Notebook?> getNotebook(int id) async {
    return await _db.managers.notebooks
        .filter((f) => f.id(id))
        .getSingleOrNull();
  }

  Future<Notebook> addNotebook(String name) async {
    final insertedId = await _db.managers.notebooks.create(
      (o) => o(name: name),
    );

    final insertedNotebook = await _db.managers.notebooks
        .filter((f) => f.id(insertedId))
        .getSingle();

    // Folder creation
    final notebookDir = Directory(
      p.join(_notebooksDirectory.path, insertedNotebook.id.toString()),
    );

    if (!await notebookDir.exists()) {
      await notebookDir.create(recursive: true);
    }

    print("Notebook repository updated: Added: ${notebookDir.path}");
    return insertedNotebook;
  }

  Future<bool> removeNotebook(int id) async {
    final deletedCount = await _db.managers.notebooks
        .filter((f) => f.id(id))
        .delete();

    if (deletedCount == 0) {
      return false;
    }

    // Delete folder
    final directoryToDelete = Directory(
      p.join(_notebooksDirectory.path, id.toString()),
    );

    if (await directoryToDelete.exists()) {
      try {
        await directoryToDelete.delete(recursive: true);
      } catch (e) {
        print("An error occurred. Couldn't delete notebook folder");
        return false;
      }
    } else {
      print("The folder doesn't exist which the user has now requested to delete.");
    }

    return true;
  }

  Future<void> renameNotebook(int id, String name) async {
    await _db.managers.notebooks
        .filter((f) => f.id(id))
        .update((o) => o(name: Value(name)));
  }

  Future<bool> deleteNotebooksDirectory() async {
    if (await _notebooksDirectory.exists()) {
      print("Deleting the notebooks Directory now");
      try {
        await _notebooksDirectory.delete(recursive: true);
        print("No errors now! Notebooks directory got deleted");
        return true;
      } catch (e) {
        print("An error occurred. Trying again after some time");
        return false;
      }
    }
    print("The directory doesn't even exist");
    return true;
  }

  Future<void> resetDatabase() async {
    print("Trying to reset the database");
    print("Current notebooks directory: ${_notebooksDirectory.path}");

    await _db.close();

    final dbPath = p.join(appSaveLocation, "data", "appdb.sqlite");
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  }
}