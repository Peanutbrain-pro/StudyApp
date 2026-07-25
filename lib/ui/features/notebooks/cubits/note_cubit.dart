import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';

class NoteState {
  final List<dynamic> data;

  NoteState({required this.data});
}

class NoteCubit extends Cubit<NoteState> {
  final NotebookRepository _notebookRepository;

  NoteCubit({required NotebookRepository notebookRepository})
    : _notebookRepository = notebookRepository,
      super(NoteState(data: []));
}
