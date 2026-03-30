import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:studyapp/data/database/app_database.dart';

// import '../../domain/models/notebook.dart';

class NotebookRepository {
  final String appSaveLocation;
  late Directory _notebooksDirectory; 
  late final AppDatabase _db;

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
        notebookDirectory.create(recursive: true);
      }
    }
    return rows;
  }

  Future<Notebook> addNotebook(String name) async {
    // Database
    final new_notebook = NotebooksCompanion.insert(
      name: name,
    );
    final inserted_notebook = await _db.into(_db.notebooks).insertReturning(new_notebook);

    // Folder creation
    final Directory newNotebook = Directory(p.join(_notebooksDirectory.path, inserted_notebook.id.toString())); 
    if (!await newNotebook.exists()) {
      newNotebook.create(recursive: true);
    }
    print("Notebook repository updated: Added: ${newNotebook.path}");
    
    return inserted_notebook;
  }
  
  Future<void> removeNotebook(int id) async {
    // Database
    final deletedNotebook = await (_db.delete(_db.notebooks)..where((t) => t.id.equals(id))).goAndReturn();
    final Directory directoryToDelete = Directory(p.join(_notebooksDirectory.path, deletedNotebook.first.id.toString()));
    
    // Folder creation
    if (await directoryToDelete.exists()) await directoryToDelete.delete(recursive: true);
    // return deletedNotebook.first;
  }
  
}
