import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import '../../../../domain/models/notebook.dart';

class HomeState {
  final List<Notebook> notebooks;
  const HomeState({required this.notebooks});
}

class HomeCubit extends Cubit<HomeState> {
  final NotebookRepository notebookRepository;

  HomeCubit({required this.notebookRepository})
      : super(HomeState(notebooks: [])) {
        _initialize();
      }

  Future<void> _initialize() async {
    final notebooks = await notebookRepository.getNotebooks();
    emit(HomeState(notebooks: notebooks));
  }
  
  // void getNotebooks(int id) {
  //   print("id: $id");
  // }

  void addNotebook(String name) {
    print("Updating the cubit");
    final updatedNotebooks = [...state.notebooks];
    final newNotebook = Notebook(name: name);
    updatedNotebooks.add(newNotebook);
    notebookRepository.addNotebook(name);

    emit(HomeState(notebooks: updatedNotebooks));
    print("Cubit updated: ${state.notebooks.map((n) => n.name).toList()}");
  }
}
