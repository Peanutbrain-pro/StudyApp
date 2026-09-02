import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:studyapp/data/repositories/note_repository.dart';

class NoteState {
  final String markdown;
  final bool isLoading;

  NoteState({required this.markdown, this.isLoading = false});

  NoteState copyWith({String? markdown, bool? isLoading, int? indexId}) {
    return NoteState(markdown: markdown ?? this.markdown, isLoading: isLoading ?? this.isLoading);
  }
}

class NoteCubit extends Cubit<NoteState> {
  // ignore: unused_field
  final NoteRepository _noteRepository;
  final int notebookId;
  final String? saveLocation;

  NoteCubit({required NoteRepository noteRepository, required this.notebookId, this.saveLocation})
    : _noteRepository = noteRepository,
      super(NoteState(markdown: '')) {
    loadNote();
  }

  /// Returns the root directory path for the current notebook.
  /// e.g. C:/Users/.../Documents/StudyApp/Notebooks/1
  String notebookDirectory() {
    if (saveLocation == null) return '';
    return p.join(saveLocation!, 'Notebooks', notebookId.toString());
  }

  /// Returns the path to the note.md file for the current notebook.
  /// e.g. C:/Users/.../Documents/StudyApp/Notebooks/1/note.md
  String notePath() {
    return p.join(notebookDirectory(), 'note.md');
  }

  /// Returns the path to the Sources directory for images & attachments.
  /// e.g. C:/Users/.../Documents/StudyApp/Notebooks/1/Sources
  String sourcesDirectory() {
    return p.join(notebookDirectory(), 'Sources');
  }

  Future<void> loadNote([int? indexId]) async {
    emit(state.copyWith(isLoading: true, indexId: indexId));

    final mdPath = notePath();
    final file = File(mdPath);
    if (await file.exists()) {
      final content = await file.readAsString();
      emit(state.copyWith(markdown: content, isLoading: false, indexId: indexId));
      return;
    }

    emit(state.copyWith(markdown: '', isLoading: false, indexId: indexId));
  }

  Future<void> saveMarkdown(String markdown) async {
    emit(state.copyWith(markdown: markdown));
    final mdPath = notePath();
    await _writeToFile(mdPath, markdown);
  }

  Future<void> _writeToFile(String path, String content) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
    } catch (e) {
      // Silently ignore file write errors
    }
  }
}
