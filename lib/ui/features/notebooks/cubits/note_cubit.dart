import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/note_repository.dart';

class NoteState {
  final String markdown;
  final bool isLoading;
  final int? indexId;

  NoteState({
    required this.markdown,
    this.isLoading = false,
    this.indexId,
  });

  NoteState copyWith({
    String? markdown,
    bool? isLoading,
    int? indexId,
  }) {
    return NoteState(
      markdown: markdown ?? this.markdown,
      isLoading: isLoading ?? this.isLoading,
      indexId: indexId ?? this.indexId,
    );
  }
}

class NoteCubit extends Cubit<NoteState> {
  final NoteRepository _noteRepository;
  final int notebookId;

  NoteCubit({
    required NoteRepository noteRepository,
    required this.notebookId,
  }) : _noteRepository = noteRepository,
       super(NoteState(markdown: '# Notes\n\nWelcome to your study notes! Type `/` for commands or use the toolbar to insert formulas, images, and source documents.'));

  Future<void> loadNote(int indexId) async {
    emit(state.copyWith(isLoading: true, indexId: indexId));
    final note = await _noteRepository.getNotes(indexId, notebookId);
    if (note != null && note.data.isNotEmpty) {
      emit(state.copyWith(markdown: note.data, isLoading: false, indexId: indexId));
    } else {
      emit(state.copyWith(isLoading: false, indexId: indexId));
    }
  }

  Future<void> saveMarkdown(String markdown) async {
    emit(state.copyWith(markdown: markdown));
    if (state.indexId != null) {
      await _noteRepository.saveNote(
        notebookId: notebookId,
        indexId: state.indexId!,
        markdown: markdown,
      );
    }
  }
}
