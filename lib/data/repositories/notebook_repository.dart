import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/models/notebook.dart';

class NotebookRepository {
  late Directory _notebooksDirectory; 

  Future<void> initialize(String appSaveLocation) async {
    final directory = Directory(p.join(appSaveLocation, "Notebooks"));
    if (!await directory.exists()) {
      await directory.create(recursive: true);      
    }
    _notebooksDirectory = directory;
  }

  Future<List<Notebook>> getNotebooks() async {
    List<Notebook> notebooks = [];
    List<Directory> notebookDirectories = [];

    await for (final entity in _notebooksDirectory.list(recursive: false, followLinks: false)) {
      if (entity is Directory) {
        notebookDirectories.add(entity);
      }
    }

    for (Directory dir in notebookDirectories) {
      final Notebook notebook = Notebook(name: p.basename(dir.path));
      notebooks.add(notebook);
    }

    return notebooks;
  }

  Future<void> addNotebook(String name) async {
    final Directory newNotebook = Directory(p.join(_notebooksDirectory.path, name)); 
    if (!await newNotebook.exists()) {
      newNotebook.create(recursive: true);
    }
    print("Notebook repository updated: Added: ${newNotebook.path}");
  }
}
