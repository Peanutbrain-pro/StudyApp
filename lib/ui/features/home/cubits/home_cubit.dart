import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/shared/utilities/dialog_helper.dart';
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

  Future<void> deleteNotebook(BuildContext context, int id) async {
    print("Deleting notebook with id : $id");
    final deleted = await notebookRepository.removeNotebook(id);
    if (!deleted) {
      await DialogHelper.showError(context, "Unable to delete notebook", "Couldn't delete the notebook. Please make sure that no other application is using the folder used by this notebook you are about to delete");
      return;
    }
    final updatedNotebooks = [...state.notebooks];
    updatedNotebooks.removeWhere((notebook) => notebook.id == id);
    emit(HomeReady(notebooks: updatedNotebooks)); 
  }

  Future<void> renameNotebook(int id, String name) async {
    print("Renaming a notebook with id:$id");
    await notebookRepository.renameNotebook(id, name);
    print("Successfully renamed to $name");
    final updatedNotebooks = [...state.notebooks];
    int index = updatedNotebooks.indexWhere((t) => t.id == id);
    Notebook newNotebook = updatedNotebooks[index].copyWith(name: name);
    updatedNotebooks.removeAt(index);
    updatedNotebooks.insert(index, newNotebook);
    emit(HomeReady(notebooks: updatedNotebooks));
  }
}
