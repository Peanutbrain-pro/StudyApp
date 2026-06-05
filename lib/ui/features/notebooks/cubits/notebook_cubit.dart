import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';

class NotebookState {
  final String notebookName;
  final int notebookId;
  final bool loaded;
  NotebookState({required this.notebookId, required this.notebookName, this.loaded = false});
}

class NotebookCubit extends Cubit<NotebookState> {
  // final int notebookId;
  final NotebookRepository notebookRepository;

  NotebookCubit({required int notebookId, required this.notebookRepository})
    : super(NotebookState(notebookId: notebookId, notebookName: ""));

  Future<void> initialize() async {
    final Notebook? notebook = await notebookRepository.getNotebook(state.notebookId);
    if (notebook == null) {
      return;
    }
    emit(NotebookState(notebookId: notebook.id, loaded: true, notebookName: notebook.name));
  }

  // Future<String> getNotebookName(int id) async {
  //   Notebook notebook = await notebookRepository.getNotebook(id);
  //   return notebook.name;
  // }
}
