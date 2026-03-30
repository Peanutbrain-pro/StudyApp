import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
// import '../../../../domain/models/notebook.dart';

class HomeState {
  final List<Notebook> notebooks;
  const HomeState({required this.notebooks});
}

class HomeLoading extends HomeState {
  HomeLoading({required super.notebooks});
}

class HomeReady extends HomeState {
  HomeReady({required super.notebooks});
}

class HomeCubit extends Cubit<HomeState> {
  final NotebookRepository notebookRepository;

  HomeCubit({required this.notebookRepository})
      : super(HomeLoading(notebooks: [])) {
        _initialize();
      }

  Future<void> _initialize() async {
    notebookRepository.initialize();
    final notebooks = await notebookRepository.getNotebooks();
    emit(HomeReady(notebooks: notebooks));
  }
  
  Future<List<Notebook>> getNotebooks() async {
    return notebookRepository.getNotebooks();
  }

  Future<void> addNotebook(String name) async {
    print("Updating the cubit");
    final updatedNotebooks = [...state.notebooks];
    final newNotebook = await notebookRepository.addNotebook(name);
    updatedNotebooks.add(newNotebook);

    emit(HomeReady(notebooks: updatedNotebooks));
    print("Cubit updated: ${state.notebooks.map((n) => n.name).toList()}");
  }

  Future<void> deleteNotebook(int id) async {
    print("Deleting notebook with id : $id");
    await notebookRepository.removeNotebook(id);
    final updatedNotebooks = [...state.notebooks];
    updatedNotebooks.removeWhere((notebook) => notebook.id == id);
    emit(HomeReady(notebooks: updatedNotebooks)); 
  }
}
